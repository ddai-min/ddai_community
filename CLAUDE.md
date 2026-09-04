# CLAUDE.md

이 저장소에서 작업하는 Claude Code(및 신규 개발자)를 위한 안내서.
사용자 대상 소개·설치 안내는 `README.md` 를 참고한다.

## 프로젝트 개요

`ddai_community` — Flutter + **Supabase** 커뮤니티 앱. 게시판, 실시간 채팅, 인증(이메일/익명),
신고·차단 기능을 제공한다. 상태 관리는 Riverpod, 라우팅은 go_router 를 사용한다.

> 원래 Firebase(Auth · Firestore · Remote Config) 기반이었으나 Supabase 로 전환했다.
> 전환 배경과 스키마·RLS 전문은 `docs/supabase-migration.md` 에 있다.

## 명령어

이 프로젝트는 **FVM** 으로 Flutter 버전(3.44.9, `.fvmrc`, 번들 Dart 3.12.2)을 고정한다. 항상 `fvm` 접두사를 사용한다.

```bash
fvm flutter pub get                # 의존성 설치
fvm dart run build_runner build    # *.g.dart 재생성 (모델/provider 변경 후 필수)
fvm flutter analyze                # 정적 분석 (현재 기준 0 issue 유지)
fvm flutter run                    # 실행
```

Edge Function 배포는 Supabase CLI 로 한다. **반드시 프로젝트 루트에서** 실행한다.

```bash
supabase functions deploy delete-account --project-ref <ref>
```

`test/` 디렉터리는 아직 없다. 테스트를 추가하려면 디렉터리를 만들고 `fvm flutter test` 를 사용한다.

## 아키텍처

**feature-first + 계층(layer)** 구조. 각 기능은 `features/<feature>/` 아래에서
`data` / `domain` / `presentation` 3계층을 반복하고, 공통 자산은 `core/` 에 모은다.

```
presentation/screens ──watch/read──▶ presentation/providers ──▶ data/repository ──▶ Supabase
        ▲                                      │
        └──────────────── state ───────────────┘
```

```
lib/
├── main.dart                  # 진입점 (Bootstrap 실행 → App 실행)
│
├── app/                       # 앱 전역 조립
│   ├── app.dart               #   App 루트 위젯 (인증 동기화 · 라우터/차단 화면 분기)
│   ├── app_update.dart        #   강제 업데이트 확인 (UI 없는 순수 로직)
│   └── bootstrap.dart         #   .env 로드 + Supabase 초기화
│
├── core/                      # 기능에 종속되지 않는 공통 자산
│   ├── constants/             #   colors · supabase_env · turnstile_env · app_links
│   ├── data/                  #   supabase_client(전역 getter) · PaginationRepository · AppConfigRepository
│   │                          #   · CaptchaRepository · SecureLocalStorage
│   ├── models/                #   ModelWithId · PaginationModel · PaginationCursor
│   ├── providers/             #   PaginationMixin · sessionUidProvider
│   ├── router/                #   go_router 라우트 정의
│   ├── theme/                 #   AppTheme
│   ├── utils/                 #   DataUtils · RegUtils · LinkUtils · logger
│   └── widgets/               #   DefaultLayout · Default* 공통 위젯
│
└── features/                  # 기능(도메인) 모듈
    ├── auth/                  #   로그인 · 회원가입 · EULA · 차단
    ├── board/                 #   게시글 · 댓글
    ├── chat/                  #   실시간 채팅
    ├── home/                  #   홈 탭 (게시판/채팅/프로필)
    └── user/                  #   프로필 · 신고 · 전역 유저 상태 · 라이선스

supabase/
├── config.toml                # Supabase CLI 설정
└── functions/                 # Edge Function (Deno)
    ├── delete-account/        #   계정 삭제 (비밀번호 재확인 후 admin 삭제)
    └── notify-report/         #   신고 접수 알림 (Database Webhook 이 호출)

asset/
├── fonts/                     # NotoSans (앱 전역 폰트)
└── img/splash.png             # 네이티브 스플래시 원본 (런타임 에셋 아님)
```

각 feature 내부는 항상 동일한 3계층이다. (해당 계층이 없으면 폴더도 만들지 않는다)

```
features/<feature>/
├── data/                      # repository — Supabase(Postgres/Auth) 송수신
├── domain/                    # 모델(`*_model.dart`) · 요청 파라미터(`*_parameter.dart`)
└── presentation/
    ├── providers/             # Riverpod provider (@riverpod)
    ├── screens/               # 화면 위젯 (routeName 노출)
    └── widgets/               # 화면을 구성하는 재사용 위젯
```

- 의존 방향은 `presentation → domain ← data`, 그리고 `features → core` 단방향이다.
  **역참조 예외는 없다.** (예전에는 `pagination_provider` 가 차단 필터용 uid 때문에
  `features/user` 의 `userMeProvider` 를 참조했으나, 차단이 RLS 로 옮겨가면서 해소됐다.
  목록 재생성 트리거는 core 안의 `sessionUidProvider` 가 담당한다)
- 진입점: `main.dart` → `app/bootstrap.dart`(`.env` 로드 + `Supabase.initialize`)
  → `app/app_update.dart`(강제 업데이트 확인) → `app/app.dart`
- **스플래시 화면(Dart)은 없다.** 시작에 필요한 판단은 `runApp()` **이전에** 끝내고,
  첫 화면을 곧바로 목적지(`/` 또는 `/login`)로 띄운다. 그동안 보이는 것은 네이티브 스플래시다.

### 핵심 패턴: 제네릭 페이지네이션

목록(게시판/채팅/댓글)은 모두 공통 모듈을 통해 처리된다. 새 목록 기능을 추가할 때 이 패턴을 따른다.

- `core/data/pagination_repository.dart` — `PaginationRepository<T extends ModelWithId>`
  - `fetchData(...)`: **`created_at desc, id desc` keyset 커서** 페이지네이션.
    동률 시각은 `and(created_at.eq, id.lt)` 로 타이브레이크해 페이지 경계에서 누락/중복이 없다.
  - `streamData(...)`: 실시간 스트림(채팅용). `.stream()` 은 **매번 목록 전체**를 내보내므로
    수신 측은 증분 병합 없이 교체하면 된다.
  - `TablePath` enum 의 `name` 이 실제 Postgres 테이블 이름이다.
  - **차단 필터 코드는 없다.** RLS 정책 `is_blocked()` 가 서버에서 강제한다.
- `core/providers/pagination_provider.dart` — `PaginationMixin<T>` (공통 목록 로직 mixin, `on $Notifier<PaginationModel<T>>`)
  - 각 목록은 `@riverpod class BoardList extends _$BoardList with PaginationMixin<BoardModel>` 처럼 만들고,
    **`paginationRepository` 만 override** 한다. (어느 테이블을 볼지는 repository 자신이 안다)
  - 댓글처럼 부모 행으로 좁혀야 하면 `parentId` 를 추가로 override 한다.
    좁힐 컬럼(`board_id`)은 repository 의 `parentColumn` 이 들고 있다.
  - `build()` 는 `initialState()` 를 반환한다. 채팅은 `build()` 에서 `subscribeStream()` 을 추가 호출(실시간).
  - `mergeStreamData(rows)` — 스트림이 내보낸 서버 목록을 상태에 넣기 **전에** 가공하는 훅.
    기본은 그대로 통과. 스트림은 매번 목록 전체를 내보내므로, 이 훅 없이 로컬 항목을 얹으면
    다음 emit 에 지워진다. `ChatList` 가 낙관적 렌더링용으로 override 한다.
  - 스크롤 시 `fetchData()`, 새로고침/작성·삭제 후 `refresh()` 를 호출한다. (mixin 이 제공)
  - family(댓글)는 `build(String boardId)` 로 인자를 받고, codegen 이 `commentListProvider(boardId)` 를 생성한다.
- 각 도메인 repository 는 `PaginationRepository` 를 **상속**해 `table` 과 `fromJson`(+ 필요 시 `parentColumn`)만 지정한다.
  (예: `BoardRepository`, `CommentRepository`, `ChatRepository`)

## 관례 (Conventions)

- **언어**: 코드 주석·다이얼로그 문구·문서는 **한국어**로 작성한다.
- **Supabase 접근**: `core/data/supabase_client.dart` 의 전역 getter `supabase` 를 쓴다.
  (`Supabase.instance.client` 를 직접 부르지 않는다)
- **Repository**: 단건 조회/생성/삭제는 `static` 메서드. 성공 여부는 `bool`, 조회는 `Model?`(실패 시 `null`) 반환.
  모든 메서드는 `try/catch` 로 감싸고 실패 시 전역 `logger`(`core/utils/logger.dart`)로 로깅 후 안전한 기본값을 반환한다.
- **쓰기 페이로드**: 모델의 `toJson()` 이 아니라 `*Params` 에서 **명시적 map** 을 만들어 insert 한다.
  `id` 와 `created_at` 은 DB 기본값(`gen_random_uuid()` / `now()`)에 맡긴다.
- **Provider(codegen) 네이밍**: 모든 provider 는 `@riverpod` 로 생성한다.
  - 함수형(`getBoard`/`addBoard`/`report` 등) → `getBoardProvider` 등(autoDispose Future) 자동 생성.
  - 목록 Notifier(`BoardList`/`ChatList`/`CommentList`) → `boardListProvider` 등 자동 생성.
  - repository(`boardRepository` 등)와 전역 상태(`UserMe` · `SessionUid`)는 `@Riverpod(keepAlive: true)`.
- **Model**: `@JsonSerializable(fieldRename: FieldRename.snake)` + `part '*.g.dart'`.
  Postgres 는 snake_case, Dart 는 camelCase 라 이 한 줄로 맞춘다.
  날짜 필드는 `@JsonKey(name: 'created_at')` 를 붙인다. (변환기는 필요 없다 — ISO8601 문자열을
  `json_serializable` 이 `DateTime.parse` 로 처리한다)
  목록 대상 모델은 `ModelWithId`(행 `id` 노출)를 구현한다.
- **요청 파라미터**: `*_parameter.dart` 의 별도 클래스(예: `AddBoardParams`)로 전달한다.
- **전역 유저 상태**: `@Riverpod(keepAlive: true) class UserMe` → `userMeProvider`. `id == ''` 이면 비로그인.
  갱신은 `ref.read(userMeProvider.notifier).update((state) => ...)` 로 하며, 주로 `app/app.dart` 의
  `supabase.auth.onAuthStateChange` 리스너에서 이루어진다.
  Supabase `User` → `UserModel` 변환은 **`AuthRepository.userModelFrom()` 한 곳**에만 둔다.
  - **초기값은 `build()` 가 `supabase.auth.currentUser` 로 직접 만든다.** 위 리스너는 스트림이라
    한 박자 뒤에 오는데, 그 사이 비어 있으면 세션이 살아 있는데도 화면이 비로그인으로 판단한다.
    `sessionUidProvider` 도 같은 이유로 `currentUser` 를 먼저 읽는다. 비우지 말 것.
  - **화면에서는 `watch` 로 읽는다.** `build` 안에서 `read` 를 쓰면 구독하지 않아 나중에 값이
    채워져도 화면이 그대로 굳는다. (`HomeTab` 이 실제로 이 버그를 겪었다 — 익명 로그인 후
    앱을 다시 켜면 로그인 안내가 뜨고 hot reload 를 해야 풀렸다)
    `itemBuilder` 는 build 가 아니라 레이아웃 중에 불리므로, 그 안에서 watch 하지 말고
    `build` 첫 줄에서 값을 꺼내 넘긴다. 버튼 콜백 등 이벤트 핸들러에서는 `read` 가 맞다.
- **화면 공통 레이아웃**: `DefaultLayout`(공통 Scaffold). `title` 을 주면 브랜드 색 AppBar 가 렌더된다.
  본문 여백도 여기서 준다 — `padding` 파라미터, 기본값 `DefaultLayout.contentPadding`(가로 24 · 세로 16).
  **화면에서 `Padding` 을 덧씌우지 않는다.** 더해져서 화면끼리 어긋난다. 다르게 줘야 하면 `padding` 으로 넘긴다.
  말풍선·다이얼로그처럼 위젯 **안쪽** 여백은 별개이고, 리스트 아이템은 세로 간격만 갖는다.
  - **`HomeTab` 은 `padding: EdgeInsets.zero` 다.** 게시판·채팅 목록이 화면 끝까지 닿아야 하는데
    세 탭이 레이아웃 하나를 공유하기 때문이다. 그래서 **`ProfileScreen` 만** `DefaultLayout.contentPadding` 을
    직접 쓴다. 탭을 추가할 때 여백이 필요하면 같은 방식으로 그 화면이 직접 준다.
  - **본문 스크롤도 여기서 준다.** `isScrollable` 기본값이 `true` 라 본문이 자동으로
    `SingleChildScrollView` 에 담긴다. **화면에서 스크롤뷰를 덧씌우지 않는다** — 중첩되면
    안쪽이 높이를 못 받는다. `clipBehavior` 기본값은 `Clip.none` 이고, 페이지네이션처럼
    스크롤 위치가 필요하면 `scrollController` 를 넘긴다. (게시글 상세가 그렇게 쓴다)
  - **`isScrollable: false` 로 꺼야 하는 화면이 있다.** 스크롤뷰 안에서는 높이 제약이
    무한이라 아래 셋은 터지거나 뭉개진다. 새 화면을 만들 때 먼저 확인할 것.
    | 조건 | 해당 화면 |
    | --- | --- |
    | 자체 스크롤 위젯 (`ListView`·`TabBarView`·웹뷰) | `HomeTab` · `BlockUserScreen` · `PrivacyPolicyScreen` |
    | `Expanded`·`Spacer` 로 남은 높이를 나눠 가짐 | `SignUpScreen` · `ProfileEditScreen` |
    | 세로 가운데 정렬 (`Center` · `MainAxisAlignment.center`) | `HomeTab`(비로그인) · `BoardDetailScreen`(로딩·오류) |
- **모서리 둥글기**: 다이얼로그와 버튼은 `AppTheme.borderRadius`(10) 하나를 공유한다.
  값은 `AppTheme.light` 의 `dialogTheme` · `elevatedButtonTheme` · `textButtonTheme` 이 주므로
  **위젯에서 `shape` 를 지정하지 않는다.** 비워 두면 테마가 적용된다.
  (예전에는 버튼만 6 을 박아 두고 다이얼로그는 Material 기본값 28 이라, 다이얼로그 안의
  버튼과 테두리가 나란히 어긋나 보였다) 예외는 EULA 하단의 각진 버튼 하나뿐이다.
- **라우팅**: go_router 명명 라우트. 각 화면은 `static get routeName` 을 노출한다.
  값 전달은 path parameter(`:id`)와 query parameter(`isAnonymous`, `userName` 등) 사용.
- **인증 예외**: `AuthExceptionCode` enum 으로 매핑하고, 미분류 예외는 `unknownError` 로 처리한다.
  문자열은 `AuthException.code` 값과 맞춘다.
- **import 정렬**: `dart:` → `package:` 순으로 그룹을 나누고 그룹 안에서는 알파벳순으로 정렬한다.
  (파일을 옮기면 경로가 바뀌어 정렬이 깨지므로 이동 후 반드시 다시 정렬한다)
- **문서 주석**: 모든 공개 최상위 선언(위젯·모델·repository·provider)에 `///` 주석을 단다.
  "무엇을 하는지"보다 "왜/언제 쓰는지"와 주의점을 적는다.

## 주의사항 (Gotchas)

- **secret 키 금지**: `sb_secret_...`(구 `service_role`)는 RLS 를 우회한다.
  **앱·`.env`·저장소 어디에도 두지 않는다.** 서버 권한이 필요한 작업은 Edge Function 에서만 한다.
- **`.env` 필수**: 없으면 시작 시 크래시(`dotenv.env[...]!`). **필수 키는
  `SUPABASE_URL` · `SUPABASE_PUBLISHABLE_KEY` 2개**다.
  `TURNSTILE_SITE_KEY` · `TURNSTILE_BASE_URL` 은 **선택**이며 없으면 CAPTCHA 를 쓰지 않는다.
  (`IOS_BUNDLE_ID` · `ANDROID_PACKAGE_NAME` 은 참조되지 않는 잔여 키)
- **`anonKey` 대신 `publishableKey`**: `supabase_flutter` 2.17.2 에서 `anonKey` 는 `@Deprecated` 다.
- **RLS 는 조용히 0행을 만든다**: PostgREST 는 권한이 없어도 예외를 던지지 않는다.
  삭제/수정이 실제로 일어났는지 확인하려면 `.select()` 로 영향받은 행을 되받아야 한다.
  (`BoardRepository.deleteBoard` 참고 — Firestore 는 예외를 던졌지만 여기서는 아니다)
- **생성 파일 직접 수정 금지**: `*.g.dart` (모델/provider 변경 후 `build_runner` 실행).
- **Riverpod 패턴(codegen)**: provider 는 `@riverpod`/`@Riverpod` 애너테이션 + `riverpod_generator` 로 작성한다.
  구형 `StateNotifier`·`StateProvider`(legacy)는 사용하지 않는다.
- **codegen ↔ Flutter 버전**: `@riverpod` codegen 은 **Flutter ≥ 3.44 (Dart ≥ 3.12, meta ≥ 1.18)** 에서만 resolve 된다.
  이전 버전(예: 3.41.6/meta 1.17)에서는 analyzer 충돌로 설치 불가하니 Flutter 를 낮추지 말 것.
- **build_runner**: 최신 버전에서 `--delete-conflicting-outputs` 플래그는 제거됐고 기본 동작이다.
- **정적 분석**: `analysis_options.yaml` 에서 `use_build_context_synchronously` 를 `ignore` 로 설정해 두었다.
- **포매터**: 같은 파일에 `formatter: trailing_commas: preserve` 를 켜 두었다.
  Dart 3.7 부터 포매터가 trailing comma 를 무시하고 한 줄에 들어가면 접어버리는데,
  이 설정이 없으면 저장할 때마다 위젯 트리가 뭉개진다.
- **강제 업데이트**: `app_config` 테이블의 `version_name` 과 앱 버전(major/minor)을 비교한다. (`app/app_update.dart`)
  patch 차이는 허용하며, **조회나 파싱이 실패하면 안내 후 `exit(0)`** 으로 앱을 종료한다.
  즉 `app_config` 에 `version_name` 행이 없으면 앱이 뜨지 않는다.
  `app_config` 의 SELECT 정책은 **`anon` 롤에도 열려 있어야 한다** — 스플래시가 로그인 전에 읽는다.
- **앱 버전의 단일 출처는 `pubspec.yaml` 이다.** 네이티브 쪽에 버전을 적지 않는다.
  - iOS: `Info.plist` 가 `$(FLUTTER_BUILD_NAME)` / `$(FLUTTER_BUILD_NUMBER)` 를 참조하고,
    Flutter 가 `Generated.xcconfig` 에 pubspec 값을 써 넣는다.
    **`project.pbxproj` 에 `FLUTTER_BUILD_NAME` · `MARKETING_VERSION` 등을 넣지 말 것** —
    프로젝트 빌드 설정이 xcconfig 를 이겨서 pubspec 이 무시된다.
    (Xcode General 탭에서 버전을 고치면 정확히 이 상태가 된다. 실제로 한 번 겪었다)
  - Android: `flutter.versionCode` / `flutter.versionName` 을 그대로 쓴다.
    값이 없으면 조용히 틀린 버전으로 빌드하지 않고 Gradle 이 실패한다.
  - 버전을 올릴 때는 **`pubspec.yaml` 한 줄만** 고치고, 필요하면 `app_config.version_name` 을 맞춘다.
- **세션은 보안 저장소에 넣는다**: `app/bootstrap.dart` 가 `Supabase.initialize` 에
  `SecureLocalStorage` 를 주입한다. supabase_flutter 기본값(`SharedPreferencesLocalStorage`)은
  세션 JSON 을 iOS `NSUserDefaults` plist · Android SharedPreferences XML 에 **평문으로** 남긴다.
  비밀번호는 앱에 저장하지 않지만, 이 refresh token 이 사실상 지속되는 자격증명이다.
  - **저장 키(`sb-<host 첫 라벨>-auth-token`)를 바꾸지 말 것.** supabase_flutter 기본 구현이 쓰던
    키이고, 이걸로 예전 세션을 찾아 한 번 옮겨온다. 키를 바꾸면 업데이트하는 순간 기존 로그인이
    전부 풀리는데, **익명 계정은 되찾을 방법이 없어 계정과 쓴 글이 통째로 사라진다.**
  - iOS 는 `KeychainAccessibility.first_unlock`. `*_this_device` 변형은 기기 백업으로 넘어가지
    않아서, 폰을 바꾼 익명 유저가 계정을 잃는다.
  - **Android 는 기기를 바꾸면 로그아웃된다.** 자동 백업이 암호화 파일만 옮기고 Keystore 키는
    안 옮겨 복호화가 깨진다. `resetOnError` 기본값(true)이 예외 대신 값을 비워서 앱이 죽지는
    않는다. 예전(평문 SharedPreferences)에는 유지됐던 동작이다.
  - 읽기(`accessToken`·`hasAccessToken`)만 예외를 삼킨다. 여기서 던지면 `Supabase.initialize` 가
    실패해 앱이 아예 안 켜진다. 반면 쓰기·삭제는 삼키지 않는다 — 조용히 실패하면 로그아웃했는데
    세션이 디스크에 남는다.
  - PKCE code verifier(`pkceAsyncStorage`)는 여전히 SharedPreferences 다. 이 앱은 OAuth·매직링크를
    쓰지 않아 값이 실제로 들어가지 않는다.
- **작성자 표시 이름은 서버가 정한다**: `board`/`chat`/`comment`/`report`/`block_user` 의 `user_name`
  계열 컬럼은 `BEFORE INSERT` 트리거(`private.set_author_name` · `private.set_report_names` ·
  `private.set_blocked_user_name`)가 `profile` 값으로
  덮어쓴다. 클라이언트가 보낸 값은 **무시된다.** 정책이 `user_uid = auth.uid()` 만 검사해서,
  REST 를 직접 부르면 아무 이름으로나 글을 쓸 수 있었기 때문이다.
  - 여전히 payload 에 `user_name` 을 담아 보내는 건 무해하다(덮어써진다). 빼도 된다.
  - 닉네임을 바꿔도 **이미 쓴 글의 이름은 안 바뀐다.** 비정규화된 스냅샷이다.
  - `AuthRepository.updateUserName` 은 **`profile` 을 먼저** 쓰고 `user_metadata` 를 나중에 쓴다.
    순서를 뒤집으면 앞이 실패했을 때 화면 이름만 바뀌고 글쓴이 이름은 옛날 값으로 남는다.
- **`profile` 은 앱 입장에서 사실상 쓰기 전용이다**: SELECT 는 본인 행만, UPDATE 는 `user_name`
  컬럼만 허용된다(컬럼 단위 grant). 목록에 필요한 닉네임은 각 테이블에 비정규화돼 있어서
  앱은 `profile` 을 읽지 않는다. **profile 에 컬럼을 추가하고 앱에서 읽으려 하면 막힌다** —
  정책과 grant 를 함께 손봐야 한다.
- **길이 제한이 DB 에도 있다**: `board.title` 30 · `board.content` 500 · `chat`/`comment` 100 ·
  `profile.user_name` 2~12 · `report.report_reason` 500. **UI 의 `maxLength` 와 같은 값이므로
  UI 를 바꾸면 CHECK 제약도 같이 바꿔야 한다.** 어긋나면 입력은 되는데 저장만 실패해서
  원인을 찾기 어렵다.
- **`report` 는 SELECT 정책이 없다**: 그래서 insert 뒤에 `.select()` 를 붙이면
  `INSERT ... RETURNING` 이 403 으로 막힌다. 지금처럼 `.select()` 없이 넣어야 한다.
  - 앱에서 신고를 **읽을 수 없는 것은 의도된 설계다.** 대신 Database Webhook 이
    Edge Function `notify-report` 를 불러 운영자 메일로 알린다. 확인·조치는 대시보드에서 한다.
    이 함수는 호출자가 사람이 아니라 웹훅이라 **`--no-verify-jwt` 로 배포**하고,
    `x-webhook-secret` 헤더 하나가 유일한 관문이다. 주소를 아는 누구나 부를 수 있으니
    비밀값을 짧게 잡지 말 것.
- **개인정보처리방침 본문은 앱이 아니라 웹에 있다**: 원본은 `docs/privacy-policy.html`,
  공개 주소는 GitHub Pages(`https://ddai-min.github.io/ddai_community/privacy-policy.html`).
  이용 약관과 달리 수집 항목·수탁자가 바뀔 때마다 고쳐야 하는 문서인데, 앱에 본문을 넣으면
  문구 한 줄에 스토어 심사와 강제 업데이트가 필요해지기 때문이다.
  - **보여주는 것은 앱 안이다.** `PrivacyPolicyScreen` 이 `privacyPolicyUrl`
    (`core/constants/app_links.dart`)을 웹뷰로 띄운다. 브라우저로 넘기면 앱을 벗어난다.
    웹뷰 안에서는 **방침 문서 자신만** 열고, 문서 안쪽의 바깥 링크(수탁자 방침 · `mailto:`)는
    `shouldOverrideUrlLoading` 이 잡아 `LinkUtils` 로 기본 앱에 넘긴다.
    안 그러면 방침 화면인 채로 아무 사이트나 돌아다니게 되고 되돌아올 방법도 없다.
  - **`/privacy_policy` 는 최상위 라우트이고 `pushNamed` 로 연다.** 프로필 탭(`/` 하위)과
    EULA 화면(`/login` 하위) 양쪽에서 열리므로 어느 한쪽에 넣으면 반대쪽에서 갈 수 없다.
    `goNamed` 로 열면 스택이 갈려서 AppBar 뒤로 가기가 사라진다.
  - **링크 지점 2곳을 지우지 말 것** — 프로필 탭 목록과 EULA 화면 11조. 스토어(App Store
    지침 5.1.1(i) · Play Console)가 **스토어 메타데이터와 앱 안** 양쪽을 요구한다.
    EULA 쪽이 필요한 이유는 가입 전에는 프로필 화면에 갈 수 없어서다.
  - **문서 HTML 에 다크 모드를 넣지 말 것.** 앱에 다크 테마가 없어서, 기기가 다크 모드면
    이 화면만 검게 떠 앞뒤 화면과 어긋난다.
  - **주소를 바꾸면 App Store Connect · Play Console 의 URL 필드도 같이 바꾼다.**
  - **보존 기간은 네 곳이 같은 값이어야 한다** — 방침 제3조·제4조, EULA 14조,
    그리고 Supabase 의 `purge-old-reports` pg_cron 작업(현재 신고 기록 3년).
    `report` 는 `on delete set null` 이라 탈퇴해도 행이 남으므로 이 작업이 없으면
    "3년 후 파기" 가 사실이 아니게 된다. (`docs/supabase-migration.md` 의 "별건 — 개인정보처리방침 공개")
- **Android `INTERNET` 권한은 직접 넣어야 한다**: Flutter 템플릿은 이 권한을
  `debug`/`profile` 매니페스트에만 넣어 준다. 개발 중에는 hot reload 용으로 자동으로 붙어
  멀쩡해 보이지만 **릴리즈 빌드에는 붙지 않고**, 그러면 Supabase 호출이 전부 조용히 실패한다.
  의존 플러그인 중 이 권한을 선언하는 것이 하나도 없어서 `android/app/src/main/AndroidManifest.xml`
  에 직접 넣어 두었다. **지우지 말 것.**
  - 같은 파일의 `<queries>` 안 `VIEW`(`https`) · `SENDTO`(`mailto`) intent 도 필요하다.
    Android 11+ 는 다른 앱이 기본으로 보이지 않아, 없으면 `url_launcher` 가 링크를 열지 못한다.
    새 스킴을 쓰려면 여기에도 추가한다.
- **릴리즈 서명**: `android/key.properties` 가 있어야 릴리즈 빌드가 된다. 없으면
  **디버그 키로 조용히 서명하지 않고 Gradle 이 실패한다** (`android/app/build.gradle` 의
  `taskGraph.whenReady` 검사). 템플릿은 `android/key.properties.example`.
  - 디버그 키는 모든 개발 머신이 똑같이 갖고 있는 공개된 키다. 그걸로 서명한 산출물은
    스토어도 거부한다. 예전엔 `signingConfig = signingConfigs.debug` 가 그대로 있었다.
  - **keystore 를 잃어버리면 같은 앱으로 업데이트를 올릴 수 없다.** 반드시 백업한다.
  - `key.properties` 와 `*.jks` · `*.keystore` 는 `android/.gitignore` 에 등록되어 있다.
- **`blockUser` 의 `ignoreDuplicates: true` 를 빼지 말 것**: 기본 upsert 는
  `ON CONFLICT DO UPDATE` 로 나가는데 `block_user` 에는 UPDATE 정책이 없어서
  **이미 차단한 유저를 다시 차단하면 403** 으로 막힌다. (주석은 "실패하지 않는다" 였지만
  실제로는 실패하고 있었다) `ignoreDuplicates` 는 `ON CONFLICT DO NOTHING` 이라 통과한다.
- **차단 로직**: 유저 차단 시 `block_user` 에 기록되고, 이후 목록 조회에서 RLS 가 자동 제외한다.
  Firestore 의 `whereNotIn` 10개 제한도 이로써 사라졌다.
  - 해제는 프로필 탭의 `BlockUserScreen` 에서 한다. **개인정보처리방침 제3조가 차단 기록
    보유 기간을 "해제하거나 탈퇴할 때까지" 로 적고 있으므로 이 화면을 없애면 문구도 고쳐야 한다.**
  - **해제한 뒤에는 목록을 다시 받아야 한다.** 차단 여부는 RLS 가 조회 시점에 거르므로,
    이미 받아 둔 목록에는 반영되지 않는다. 게시판은 `refresh()`, 채팅은 `ref.invalidate` 다 —
    채팅은 스트림 구독을 다시 맺어야 이전 메시지까지 새 판정으로 받아온다.
  - **`block_user` 는 `(blocker_uid, blocked_uid)` 복합 PK 라 `id` 컬럼이 없다.**
    `created_at desc, id desc` 커서를 쓰는 `PaginationRepository` 를 태울 수 없어
    차단 목록만 한 번에 가져온다. `BlockUserModel` 이 `ModelWithId` 를 구현하지 않는 이유다.
  - 목록의 닉네임은 `blocked_user_name` 에 비정규화돼 있다. `profile` 은 본인 행만
    조회할 수 있어서 uid 로 이름을 되찾을 수 없기 때문이다.
- **댓글·채팅 삭제는 정책이 있어야 동작한다**: `comment_delete_own` · `chat_delete_own` 과
  각 테이블의 DELETE grant 가 필요하다. 둘 다 처음에는 회수돼 있었다.
  없으면 **오류 없이 0행**이 지워지므로, repository 가 `.select('id')` 로 되받아 확인한다.
- **SECURITY DEFINER 함수는 `private` 스키마에 둔다**: `is_blocked()` · `handle_new_user()` 는
  `public` 이 아니라 `private` 에 있다. `public` 에 있으면 PostgREST 가 `/rest/v1/rpc/<name>` 으로
  노출해서 Security Advisor 가 경고한다. 새 헬퍼 함수도 `private` 에 만든다.
  - **EXECUTE 를 회수해서 막으면 안 된다.** `is_blocked()` 는 `board_select`·`chat_select`·
    `comment_select` 정책 안에서 **호출자 롤(`authenticated`) 권한으로** 평가되므로,
    회수하면 게시판·채팅·댓글 조회가 통째로 `permission denied for function is_blocked` 로 죽는다.
  - 정책·트리거는 함수를 이름이 아니라 **OID** 로 붙들고 있어 스키마를 옮겨도 그대로 동작한다.
    `private` 에 usage 를 주지 않아도 정책 평가는 된다 (이름 해석을 하지 않으므로).
- **익명 로그인 경고는 의도된 것**: Advisor 의 `auth_allow_anonymous_sign_ins` 는 익명 유저가
  영구 유저와 같은 `authenticated` 롤을 쓴다는 사실을 잡는다. 익명 로그인이 이 앱의 기능이므로
  정책에 `is_anonymous` 조건을 넣으면 안 된다. dismiss 대상이다.
  (분류 전문은 `docs/supabase-migration.md` 의 "별건 — Security Advisor 경고 정리")
- **실시간 채팅**: `chat` 테이블이 `supabase_realtime` publication 에 있어야 한다.
  누락되면 **오류 없이 조용히** 멈춘다.
  - **내가 보낸 메시지는 낙관적으로 먼저 그린다.** insert 왕복은 30ms 인데 그 행이
    Realtime 을 타고 돌아오는 데 **평균 450ms** 가 걸려서, 기다렸다 그리면 눌러도
    반응이 없는 것처럼 보인다. `ChatList.sendChat` 이 임시 말풍선을 먼저 넣고
    `addChat` 이 `.select()` 로 되받은 진짜 행으로 바꿔치기한다.
  - 임시 말풍선은 **스트림이 그 행을 실어 올 때까지** 남는다. insert 응답만 받고
    지우면, 그 사이 다른 사람 메시지가 도착하는 순간 내 말풍선이 사라졌다 다시 나타난다.
  - `chat` 에는 **DELETE 정책이 없다.** 클라이언트에서 `delete()` 를 불러도 조용히 0행이다.
    테스트 데이터를 심었다면 계정 삭제(FK CASCADE)나 SQL 에디터로 지워야 한다.
- **계정 삭제**: 클라이언트는 유저를 지울 수 없다. Edge Function `delete-account` 가
  비밀번호 재확인 후 삭제하며, 연관 행은 FK CASCADE 로 함께 지워진다.
  - 비밀번호 재확인용 클라이언트(`checkClient`)는 **secret 키로 만들어야 한다.**
    anon 키로 만들면 CAPTCHA 를 켰을 때 이 `signInWithPassword` 가 captcha 보호에 걸려
    비밀번호 있는 계정의 탈퇴가 통째로 막힌다. (익명 유저는 이 단계를 건너뛰므로
    익명으로만 테스트하면 안 잡힌다) secret 키는 captcha 검증만 건너뛰고
    비밀번호 대조는 그대로 수행한다 — 틀린 비밀번호는 여전히 거절된다.
  - 반면 ① 신원 확인용 `userClient` 는 **anon 키 + 호출자 JWT** 그대로 두어야 한다.
    "누가 부르는지"를 서버가 판정하는 자리라 secret 키로 바꾸면 의미가 없어진다.
- **CAPTCHA(Cloudflare Turnstile)**: 서버 스위치는 Supabase 대시보드
  (Authentication → Attack Protection)에 있고 **프로젝트 전역**이다. 브랜치·환경별 토글이 없다.
  - 앱은 `TURNSTILE_SITE_KEY` 가 `.env` 에 있을 때만 토큰을 만든다.
    **켜는 순서는 "앱 배포 → 확산 → 서버 스위치"** 다. 순서를 뒤집으면 토큰을 안 보내는
    기존 빌드의 가입·로그인이 전부 막힌다. (이미 로그인된 세션은 갱신이 captcha 대상이
    아니라서 무사하다) 필요하면 `app_config.version_name` 강제 업데이트로 확산을 강제한다.
  - 토큰 발급은 headless WebView 라 **1.8~2.7초** 걸린다(시뮬레이터 debug 기준).
    로그인·가입·익명 3개 경로가 그만큼 느려지지만 기존 로딩 오버레이 안에 들어간다.
  - **토큰은 1회용이다.** `CaptchaRepository` 가 호출마다 인스턴스를 새로 만드는 이유다.
    재사용하면 두 번째 요청이 `timeout-or-duplicate` 로 거절되는데, 화면에는
    "비밀번호가 맞는데 로그인이 안 됨" 으로 보여서 원인을 찾기 어렵다.
  - 패키지의 `getToken()` 은 **스스로 타임아웃하지 않는다.** 감싸지 않으면 로딩 오버레이가
    영영 안 걷힌다. `CaptchaRepository._timeout` 이 그 방어막이다.
  - Edge Function `delete-account` 도 영향을 받는다 — 위 "계정 삭제" 항목 참고.
- **iOS 는 SPM + CocoaPods 하이브리드다.** 대부분의 플러그인과 Flutter 프레임워크는
  Swift Package 로 공급되지만, `flutter_inappwebview_ios`(CAPTCHA 용) 는 podspec 만 제공해서
  CocoaPods 도 함께 쓴다. `Podfile` · `Podfile.lock` · `Pods/` 가 있는 것이 정상이다.
  - 빌드할 때마다 `The following plugins do not support Swift Package Manager for ios`
    경고가 뜨는데 **정상이다.** 업스트림(플러그인 저자)이 SPM 을 채택해야 사라진다.
  - `Podfile` 은 Flutter 가 만든 **표준 템플릿 그대로 두어야 한다.** 한 줄이라도 손대면
    Flutter 가 바이트 단위 비교로 "non-standard Podfile" 이라 판단해 수동 마이그레이션을
    안내한다. 배포 타깃은 `project.pbxproj` 의 `IPHONEOS_DEPLOYMENT_TARGET` 이 정한다.
  - 한때 CocoaPods 를 완전히 걷어냈던 적이 있다(`6292137`). 그때는 팟이 `Flutter` 하나뿐이라
    순수 오버헤드였지만, 지금은 실제 의존성이 있어 되돌렸다.
- **Android Studio**: Flutter 프로젝트는 **루트를 열어야 한다.** `android/` 만 따로 열면
  `android/.idea/` 설정이 프로젝트와 따로 놀며 Gradle/JDK 불일치 오류가 난다.
- **스플래시는 네이티브뿐이다.** Dart 쪽에 스플래시 화면도, `/splash` 라우트도 없다.
  - `main()` 이 `FlutterNativeSplash.preserve()` 로 붙잡고, `App` 이 **첫 프레임 이후**
    `remove()` 한다. **`remove()` 를 빠뜨리면 앱이 스플래시에서 멈춘다.**
  - 시작 화면은 `supabase.auth.currentSession` 으로 정한다. `Supabase.initialize` 가
    저장된 세션 복원까지 마친 뒤라 이 값은 이미 정확하다.
    (`userMeProvider` 도 같은 값에서 초기 상태를 만든다 — 위 "전역 유저 상태" 참고)
  - 이미지/색을 바꾸면 `fvm dart run flutter_native_splash:create` 로 네이티브 리소스를 재생성한다.
    Android 12+ 는 아이콘이 원으로 마스킹되므로 1152px 캔버스의 중앙 768px 안에 내용이 있어야 한다.

## 주요 파일

| 파일 | 역할 |
| --- | --- |
| `lib/main.dart` | 진입점 (`Bootstrap.run()` 후 `App` 실행) |
| `lib/app/app.dart` | 앱 루트 위젯 — `onAuthStateChange` 동기화, 라우터/테마 주입 |
| `lib/app/bootstrap.dart` | `.env` 로드 + `Supabase.initialize` (세션 저장소 주입) |
| `lib/core/data/supabase_client.dart` | 전역 `supabase` 클라이언트 getter |
| `lib/core/router/router.dart` | 전체 라우트 정의 |
| `lib/core/theme/app_theme.dart` | 앱 전역 테마 |
| `lib/core/data/pagination_repository.dart` | 제네릭 목록 조회 (keyset 커서 · 실시간 스트림) |
| `lib/core/providers/pagination_provider.dart` | 목록 공통 로직 (`PaginationMixin`) |
| `lib/core/providers/session_provider.dart` | 세션 uid — 목록 재생성 트리거 |
| `lib/features/auth/data/auth_repository.dart` | 회원가입/로그인/로그아웃/탈퇴/차단 · `AuthExceptionCode` |
| `lib/core/data/app_config_repository.dart` | `app_config` 조회 (강제 업데이트) |
| `lib/core/data/captcha_repository.dart` | Turnstile CAPTCHA 토큰 발급 |
| `lib/core/data/secure_local_storage.dart` | 세션 저장소 — Keychain/Keystore + 구버전 이전 |
| `lib/core/constants/turnstile_env.dart` | Turnstile sitekey · baseUrl (선택 설정) |
| `lib/core/constants/app_links.dart` | 개인정보처리방침 공개 주소 |
| `lib/features/user/presentation/screens/privacy_policy_screen.dart` | 방침 웹뷰 화면 (최상위 라우트) |
| `lib/features/user/presentation/screens/block_user_screen.dart` | 차단한 사용자 목록 · 차단 해제 |
| `docs/privacy-policy.html` | 개인정보처리방침 원본 (GitHub Pages 로 공개) |
| `lib/app/app_update.dart` | 강제 업데이트 판정 (`AppUpdateStatus`) |
| `lib/features/home/presentation/screens/home_tab.dart` | 게시판/채팅/프로필 3탭 메인 화면 |
| `lib/features/user/presentation/providers/user_me_provider.dart` | 전역 로그인 유저 상태 (`userMeProvider`) |
| `lib/core/widgets/default_layout.dart` | 공통 Scaffold (`DefaultLayout`) |
| `supabase/functions/delete-account/index.ts` | 계정 삭제 Edge Function |
| `supabase/functions/notify-report/index.ts` | 신고 접수 알림 Edge Function (웹훅 호출) |
| `docs/supabase-migration.md` | 전환 기록 — 스키마 · RLS · 단계별 검증 결과 |
