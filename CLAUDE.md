# CLAUDE.md

이 저장소에서 작업하는 Claude Code(및 신규 개발자)를 위한 안내서.
사용자 대상 소개·설치 안내는 `README.md` 를 참고한다.

## 프로젝트 개요

`ddai_community` — Flutter + Firebase 커뮤니티 앱. 게시판, 실시간 채팅, 인증(이메일/익명),
신고·차단 기능을 제공한다. 상태 관리는 Riverpod, 라우팅은 go_router 를 사용한다.

## 명령어

이 프로젝트는 **FVM** 으로 Flutter 버전(3.44.9, `.fvmrc`, 번들 Dart 3.12.2)을 고정한다. 항상 `fvm` 접두사를 사용한다.

```bash
fvm flutter pub get                # 의존성 설치
fvm dart run build_runner build    # *.g.dart 재생성 (모델 변경 후 필수)
fvm flutter analyze                # 정적 분석 (현재 기준 0 issue 유지)
fvm flutter run                    # 실행
```

`test/` 디렉터리는 아직 없다. 테스트를 추가하려면 디렉터리를 만들고 `fvm flutter test` 를 사용한다.

## 아키텍처

**feature-first + 계층(layer)** 구조. 각 기능은 `features/<feature>/` 아래에서
`data` / `domain` / `presentation` 3계층을 반복하고, 공통 자산은 `core/` 에 모은다.

```
presentation/screens ──watch/read──▶ presentation/providers ──▶ data/repository ──▶ Firebase
        ▲                                      │
        └──────────────── state ───────────────┘
```

```
lib/
├── main.dart                  # 진입점 (Bootstrap 실행 → App 실행)
├── firebase_options.dart      # FlutterFire 생성 (.env 참조하도록 커스터마이징)
│
├── app/                       # 앱 전역 조립
│   ├── app.dart               #   App 루트 위젯 (인증 상태 동기화 + MaterialApp.router)
│   └── bootstrap.dart         #   .env 로드 + Firebase 초기화
│
├── core/                      # 기능에 종속되지 않는 공통 자산
│   ├── constants/             #   colors · firebase_env
│   ├── converters/            #   TimestampConverter
│   ├── data/                  #   PaginationRepository (제네릭 Firestore 조회)
│   ├── models/                #   ModelWithId · PaginationModel
│   ├── providers/             #   PaginationMixin
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
    ├── splash/                #   스플래시 + 강제 업데이트
    └── user/                  #   프로필 · 신고 · 전역 유저 상태 · 라이선스
```

각 feature 내부는 항상 동일한 3계층이다. (해당 계층이 없으면 폴더도 만들지 않는다)

```
features/<feature>/
├── data/                      # repository — Firebase(Firestore/Auth) 송수신
├── domain/                    # 모델(`*_model.dart`) · 요청 파라미터(`*_parameter.dart`)
└── presentation/
    ├── providers/             # Riverpod provider (@riverpod)
    ├── screens/               # 화면 위젯 (routeName 노출)
    └── widgets/               # 화면을 구성하는 재사용 위젯
```

- 의존 방향은 `presentation → domain ← data`, 그리고 `features → core` 단방향이 원칙이다.
  - **알려진 예외**: `core/providers/pagination_provider.dart` 가 차단 필터에 필요한 로그인 uid 때문에
    `features/user/.../user_me_provider.dart` 를 참조한다. (`core → features` 역방향)
- 진입점: `main.dart` → `app/bootstrap.dart`(`.env` 로드 + Firebase 초기화) → `app/app.dart`
  → `MaterialApp.router`(초기 경로 `/splash`)

### 핵심 패턴: 제네릭 페이지네이션

목록(게시판/채팅/댓글)은 모두 공통 모듈을 통해 처리된다. 새 목록 기능을 추가할 때 이 패턴을 따른다.

- `core/data/pagination_repository.dart` — `PaginationRepository<T extends ModelWithId>`
  - `fetchData(...)`: 커서(`startAfterDocument`) 기반 페이지네이션. **차단 유저 글 자동 제외**(`whereNotIn`).
  - `streamData(...)`: 실시간 스트림(채팅용).
  - `CollectionPath` enum 의 `name` 이 실제 Firestore 컬렉션 경로다.
- `core/providers/pagination_provider.dart` — `PaginationMixin<T>` (공통 목록 로직 mixin, `on $Notifier<PaginationModel<T>>`)
  - 각 목록은 `@riverpod class BoardList extends _$BoardList with PaginationMixin<BoardModel>` 처럼 만들고,
    `paginationRepository`(`ref.read`)·`collectionPath`·(필요 시) `subCollectionPath` 만 override 한다.
  - `build()` 는 `initialState()` 를 반환한다. 채팅은 `build()` 에서 `subscribeStream()` 을 추가 호출(실시간).
  - 스크롤 시 `fetchData()`, 새로고침/작성·삭제 후 `refresh()` 를 호출한다. (mixin 이 제공)
  - family(댓글)는 `build(String boardId)` 로 인자를 받고, codegen 이 `commentListProvider(boardId)` 를 생성한다.
- 각 도메인 repository 는 `PaginationRepository` 를 **상속**해 `collectionPath` 와 `fromJson` 만 지정한다.
  (예: `BoardRepository`, `CommentRepository`, `ChatRepository`)

## 관례 (Conventions)

- **언어**: 코드 주석·다이얼로그 문구·문서는 **한국어**로 작성한다.
- **Repository**: 단건 조회/생성/삭제는 `static` 메서드. 성공 여부는 `bool`, 조회는 `Model?`(실패 시 `null`) 반환.
  모든 메서드는 `try/catch` 로 감싸고 실패 시 전역 `logger`(`core/utils/logger.dart`)로 로깅 후 안전한 기본값을 반환한다.
- **Provider(codegen) 네이밍**: 모든 provider 는 `@riverpod` 로 생성한다.
  - 함수형(`getBoard`/`addBoard`/`report` 등) → `getBoardProvider` 등(autoDispose Future) 자동 생성.
  - 목록 Notifier(`BoardList`/`ChatList`/`CommentList`) → `boardListProvider` 등 자동 생성.
  - repository(`boardRepository` 등)와 전역 상태(`UserMe`)는 `@Riverpod(keepAlive: true)`.
- **Model**: `@JsonSerializable` + `part '*.g.dart'`. 목록 대상 모델은 `ModelWithId`(문서 `id` 노출)를 구현한다.
  날짜 필드는 `@TimestampConverter()` 로 Firestore `Timestamp` ↔ `DateTime` 변환.
- **요청 파라미터**: `*_parameter.dart` 의 별도 클래스(예: `AddBoardParams`)로 전달한다.
- **전역 유저 상태**: `@Riverpod(keepAlive: true) class UserMe` → `userMeProvider`. `id == ''` 이면 비로그인.
  갱신은 `ref.read(userMeProvider.notifier).update((state) => ...)` 로 하며, 주로 `app/app.dart` 의
  `FirebaseAuth.authStateChanges()` 리스너에서 이루어진다.
- **화면 공통 레이아웃**: `DefaultLayout`(공통 Scaffold). `title` 을 주면 브랜드 색 AppBar 가 렌더된다.
- **라우팅**: go_router 명명 라우트. 각 화면은 `static get routeName` 을 노출한다.
  값 전달은 path parameter(`:id`)와 query parameter(`isAnonymous`, `userName` 등) 사용.
- **인증 예외**: `FirebaseAuthExceptionCode` enum 으로 매핑하고, 미분류 예외는 `unknownError` 로 처리.
- **import 정렬**: `dart:` → `package:` 순으로 그룹을 나누고 그룹 안에서는 알파벳순으로 정렬한다.
  (파일을 옮기면 경로가 바뀌어 정렬이 깨지므로 이동 후 반드시 다시 정렬한다)
- **문서 주석**: 모든 공개 최상위 선언(위젯·모델·repository·provider)에 `///` 주석을 단다.
  "무엇을 하는지"보다 "왜/언제 쓰는지"와 주의점을 적는다.

## 주의사항 (Gotchas)

- **생성 파일 직접 수정 금지**: `*.g.dart` (모델 변경 후 `build_runner` 실행). 단 `lib/firebase_options.dart` 는 API 키를 `.env`(→ `core/constants/firebase_env.dart`)에서 읽도록 커스터마이징돼 있어, `flutterfire configure` 로 재생성하면 그 import 를 다시 적용해야 한다.
- **Riverpod 패턴(codegen)**: provider 는 `@riverpod`/`@Riverpod` 애너테이션 + `riverpod_generator` 로 작성하고, 변경 후 `build_runner` 로 `*.g.dart` 를 재생성한다. 구형 `StateNotifier`·`StateProvider`(legacy)는 사용하지 않는다.
- **codegen ↔ Flutter 버전**: `@riverpod` codegen 은 **Flutter ≥ 3.44 (Dart ≥ 3.12, meta ≥ 1.18)** 에서만 resolve 된다. 이전 버전(예: 3.41.6/meta 1.17)에서는 analyzer 충돌로 설치 불가하니 Flutter 를 낮추지 말 것.
- **build_runner**: 최신 버전에서 `--delete-conflicting-outputs` 플래그는 제거됐고 기본 동작이다. `build_runner build` 로 실행한다.
- **`.env` 필수**: 없으면 시작 시 크래시(`dotenv.env[...]!`). 코드가 실제로 읽는 키는
  `FIREBASE_WEB_API_KEY` · `FIREBASE_ANDROID_API_KEY` · `FIREBASE_IOS_API_KEY` 3개뿐이다.
  (`.env` 에 남아 있는 `IOS_BUNDLE_ID` · `ANDROID_PACKAGE_NAME` 은 현재 코드에서 참조하지 않는 잔여 키)
- **정적 분석**: `analysis_options.yaml` 에서 `use_build_context_synchronously` 를 `ignore` 로 설정해 두었다.
- **강제 업데이트**: Remote Config 의 `version_name` 과 앱 버전(major/minor)을 비교한다. (`splash_screen.dart`)
  patch 차이는 허용하며, **Remote Config 조회 자체가 실패하면 안내 후 `exit(0)`** 으로 앱을 종료한다.
  즉 Remote Config 에 `version_name` 이 없으면 앱이 뜨지 않는다.
- **차단 로직**: 유저 차단 시 `user/{uid}/blockUser` 에 기록되고, 이후 목록 쿼리에서 자동 제외된다.
- **백엔드**: `functions/` 디렉터리는 비어 있다(Cloud Functions 없음). Firestore 보안 규칙 파일은 저장소에 없다.

## 주요 파일

| 파일 | 역할 |
| --- | --- |
| `lib/main.dart` | 진입점 (`Bootstrap.run()` 후 `App` 실행) |
| `lib/app/app.dart` | 앱 루트 위젯 — 인증 상태 동기화, 라우터/테마 주입 |
| `lib/app/bootstrap.dart` | `.env` 로드 + Firebase 초기화 |
| `lib/core/router/router.dart` | 전체 라우트 정의 |
| `lib/core/theme/app_theme.dart` | 앱 전역 테마 |
| `lib/core/data/pagination_repository.dart` | 제네릭 목록 조회 + 차단 필터 |
| `lib/core/providers/pagination_provider.dart` | 목록 공통 로직 (`PaginationMixin`) |
| `lib/features/auth/data/auth_repository.dart` | 회원가입/로그인/탈퇴/차단 |
| `lib/features/splash/presentation/screens/splash_screen.dart` | 강제 업데이트 확인 + 초기 라우팅 분기 |
| `lib/features/home/presentation/screens/home_tab.dart` | 게시판/채팅/프로필 3탭 메인 화면 |
| `lib/features/user/presentation/providers/user_me_provider.dart` | 전역 로그인 유저 상태 (`userMeProvider`) |
| `lib/core/widgets/default_layout.dart` | 공통 Scaffold (`DefaultLayout`) |
