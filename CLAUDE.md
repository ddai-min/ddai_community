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
│   ├── app.dart               #   App 루트 위젯 (인증 상태 동기화 + MaterialApp.router)
│   └── bootstrap.dart         #   .env 로드 + Supabase 초기화
│
├── core/                      # 기능에 종속되지 않는 공통 자산
│   ├── constants/             #   colors · supabase_env
│   ├── data/                  #   supabase_client(전역 getter) · PaginationRepository
│   ├── models/                #   ModelWithId · PaginationModel · PaginationCursor
│   ├── providers/             #   PaginationMixin · sessionUidProvider
│   ├── router/                #   go_router 라우트 정의
│   ├── theme/                 #   AppTheme
│   ├── utils/                 #   DataUtils · RegUtils · logger
│   └── widgets/               #   DefaultLayout · Default* 공통 위젯
│
└── features/                  # 기능(도메인) 모듈
    ├── auth/                  #   로그인 · 회원가입 · EULA · 차단
    ├── board/                 #   게시글 · 댓글
    ├── chat/                  #   실시간 채팅
    ├── home/                  #   홈 탭 (게시판/채팅/프로필)
    ├── splash/                #   스플래시 + 강제 업데이트(app_config 조회)
    └── user/                  #   프로필 · 신고 · 전역 유저 상태 · 라이선스

supabase/
├── config.toml                # Supabase CLI 설정
└── functions/delete-account/  # 계정 삭제 Edge Function (Deno)
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
- 진입점: `main.dart` → `app/bootstrap.dart`(`.env` 로드 + `Supabase.initialize`) → `app/app.dart`
  → `MaterialApp.router`(초기 경로 `/splash`)

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
- **화면 공통 레이아웃**: `DefaultLayout`(공통 Scaffold). `title` 을 주면 브랜드 색 AppBar 가 렌더된다.
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
- **`.env` 필수**: 없으면 시작 시 크래시(`dotenv.env[...]!`). 코드가 읽는 키는
  `SUPABASE_URL` · `SUPABASE_PUBLISHABLE_KEY` 2개뿐이다.
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
- **강제 업데이트**: `app_config` 테이블의 `version_name` 과 앱 버전(major/minor)을 비교한다. (`splash_screen.dart`)
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
- **차단 로직**: 유저 차단 시 `block_user` 에 기록되고, 이후 목록 조회에서 RLS 가 자동 제외한다.
  Firestore 의 `whereNotIn` 10개 제한도 이로써 사라졌다.
- **실시간 채팅**: `chat` 테이블이 `supabase_realtime` publication 에 있어야 한다.
  누락되면 **오류 없이 조용히** 멈춘다.
- **계정 삭제**: 클라이언트는 유저를 지울 수 없다. Edge Function `delete-account` 가
  비밀번호 재확인 후 삭제하며, 연관 행은 FK CASCADE 로 함께 지워진다.
- **Android Studio**: Flutter 프로젝트는 **루트를 열어야 한다.** `android/` 만 따로 열면
  `android/.idea/` 설정이 프로젝트와 따로 놀며 Gradle/JDK 불일치 오류가 난다.

## 주요 파일

| 파일 | 역할 |
| --- | --- |
| `lib/main.dart` | 진입점 (`Bootstrap.run()` 후 `App` 실행) |
| `lib/app/app.dart` | 앱 루트 위젯 — `onAuthStateChange` 동기화, 라우터/테마 주입 |
| `lib/app/bootstrap.dart` | `.env` 로드 + `Supabase.initialize` |
| `lib/core/data/supabase_client.dart` | 전역 `supabase` 클라이언트 getter |
| `lib/core/router/router.dart` | 전체 라우트 정의 |
| `lib/core/theme/app_theme.dart` | 앱 전역 테마 |
| `lib/core/data/pagination_repository.dart` | 제네릭 목록 조회 (keyset 커서 · 실시간 스트림) |
| `lib/core/providers/pagination_provider.dart` | 목록 공통 로직 (`PaginationMixin`) |
| `lib/core/providers/session_provider.dart` | 세션 uid — 목록 재생성 트리거 |
| `lib/features/auth/data/auth_repository.dart` | 회원가입/로그인/로그아웃/탈퇴/차단 · `AuthExceptionCode` |
| `lib/features/splash/data/app_config_repository.dart` | `app_config` 조회 (강제 업데이트) |
| `lib/features/splash/presentation/screens/splash_screen.dart` | 강제 업데이트 확인 + 초기 라우팅 분기 |
| `lib/features/home/presentation/screens/home_tab.dart` | 게시판/채팅/프로필 3탭 메인 화면 |
| `lib/features/user/presentation/providers/user_me_provider.dart` | 전역 로그인 유저 상태 (`userMeProvider`) |
| `lib/core/widgets/default_layout.dart` | 공통 Scaffold (`DefaultLayout`) |
| `supabase/functions/delete-account/index.ts` | 계정 삭제 Edge Function |
| `docs/supabase-migration.md` | 전환 기록 — 스키마 · RLS · 단계별 검증 결과 |
