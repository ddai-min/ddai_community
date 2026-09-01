# ddai_community

Flutter + Firebase 기반 커뮤니티 앱.

[앱 안내](https://ddai-min.notion.site/1ce98497e613806b8b98e631cc606628)

## Stack

<img src="https://img.shields.io/badge/flutter-02569B?style=for-the-badge&logo=flutter&logoColor=white"> <img src="https://img.shields.io/badge/firebase-DD2C00?style=for-the-badge&logo=firebase&logoColor=white"> <img src="https://img.shields.io/badge/riverpod-40C4FF?style=for-the-badge&logoColor=white">

- **Client**: Flutter 3.44.9 (FVM 관리), Dart `>=3.12.0 <4.0.0` (번들 Dart 3.12.2)
- **Backend**: Firebase — Authentication, Cloud Firestore, Remote Config
- **상태 관리**: Riverpod (`flutter_riverpod` + `riverpod_generator` 코드 생성)
- **라우팅**: `go_router`
- **직렬화**: `json_serializable` / `json_annotation`

## 주요 기능

- **인증**: 이메일 회원가입/로그인, 익명 로그인, 로그아웃, 계정 삭제(비밀번호 재인증)
- **게시판**: 목록(무한 스크롤·당겨서 새로고침), 작성, 상세 조회, 삭제, 댓글 작성
- **채팅**: 전체 공개 실시간 채팅(Firestore 스트림)
- **프로필**: 닉네임 수정, 오픈소스 라이선스 확인
- **커뮤니티 보호**: 게시글/작성자 신고, 유저 차단(차단 시 목록에서 해당 유저 글 자동 제외), EULA 약관 동의
- **강제 업데이트**: Remote Config 의 최신 버전과 비교해 구버전이면 업데이트 유도

## 프로젝트 구조

기능 단위로 나눈 뒤 각 기능 안에서 `data` / `domain` / `presentation` 계층을 반복하는
**feature-first + layered** 구조이다. 기능에 종속되지 않는 공통 자산은 `core/` 에 모은다.

```
lib/
├── main.dart                     # 진입점 (Bootstrap 실행 → App 실행)
├── firebase_options.dart         # FlutterFire 자동 생성 (.env 에서 API 키를 읽도록 커스터마이징)
│
├── app/                          # 앱 전역 조립
│   ├── app.dart                  #   App 루트 위젯 — 인증 상태 동기화 + MaterialApp.router
│   └── bootstrap.dart            #   .env 로드 & Firebase 초기화
│
├── core/                         # 기능에 종속되지 않는 공통 자산
│   ├── constants/                #   색상 · Firebase 환경 변수
│   ├── converters/               #   TimestampConverter (Firestore Timestamp ↔ DateTime)
│   ├── data/                     #   PaginationRepository (제네릭 Firestore 조회)
│   ├── models/                   #   ModelWithId · PaginationModel
│   ├── providers/                #   PaginationMixin (페이지네이션 공통 로직)
│   ├── router/                   #   go_router 라우트 정의
│   ├── theme/                    #   AppTheme (앱 전역 테마)
│   ├── utils/                    #   DataUtils · RegUtils · logger
│   └── widgets/                  #   DefaultLayout · 공통 위젯(버튼/다이얼로그/텍스트필드 등)
│
└── features/                     # 기능(도메인) 모듈
    ├── auth/                     #   로그인 · 회원가입 · EULA · 유저 차단
    ├── board/                    #   게시글 · 댓글
    ├── chat/                     #   실시간 채팅
    ├── home/                     #   홈 탭 (게시판/채팅/프로필)
    ├── splash/                   #   스플래시 + 강제 업데이트
    └── user/                     #   프로필 · 신고 · 전역 유저 상태 · 오픈소스 라이선스
```

각 기능 폴더는 동일한 3계층을 갖는다. (해당 계층이 없으면 폴더도 만들지 않는다)

```
features/board/
├── data/                         # BoardRepository · CommentRepository (Firestore 송수신)
├── domain/                       # BoardModel · CommentModel · 요청 파라미터
└── presentation/
    ├── providers/                # boardListProvider · commentListProvider 등
    ├── screens/                  # 목록 / 상세 / 작성 화면
    └── widgets/                  # 목록 아이템 · 상세 버튼 · 댓글 입력 등 재사용 위젯
```

### 계층 역할

| 계층 | 역할 |
| --- | --- |
| `data` | Firebase(Firestore/Auth) 송수신 — repository |
| `domain` | JSON 직렬화 모델(`*_model.dart`)과 요청 파라미터(`*_parameter.dart`) |
| `presentation/providers` | Riverpod provider — 상태 관리 및 screen ↔ repository 연결 |
| `presentation/screens` | 실제 화면 위젯 (provider 를 구독해 UI 구성, `routeName` 노출) |
| `presentation/widgets` | 화면을 구성하는 재사용 위젯 |

> 의존 방향은 `features → core` 단방향이 원칙이다.
> 다만 `core/providers/pagination_provider.dart` 는 차단 필터에 필요한 로그인 uid 때문에
> `features/user` 의 `userMeProvider` 를 참조한다.

## 아키텍처 & 데이터 흐름

```
Screen ──watch/read──▶ Provider(Riverpod) ──▶ Repository ──▶ Firebase(Firestore/Auth)
  ▲                          │
  └──────── state ───────────┘
```

- 화면(`presentation/screens`)은 provider 를 `watch` 해 상태를 구독하고, 액션은 `read` 로 트리거한다.
- provider 는 repository 를 호출해 Firebase 와 통신하고 결과를 상태로 반영한다.
- 전역 로그인 유저 상태는 `userMeProvider`(`@Riverpod(keepAlive: true) class UserMe`)가 보관하며,
  `app/app.dart` 의 `FirebaseAuth.authStateChanges()` 리스너가 갱신한다.

### 제네릭 페이지네이션 시스템

게시판·채팅·댓글 목록은 하나의 공통 모듈로 처리된다.

- **`PaginationRepository<T extends ModelWithId>`**: 커서 기반 페이지네이션(`fetchData`)과
  실시간 스트림(`streamData`)을 제공한다. 조회 시 현재 유저가 **차단한 유저의 글을 자동 제외**한다.
- **`PaginationMixin<T>`**: 목록 상태(`PaginationModel<T>`) 공통 로직(다음 페이지·새로고침·스트림)을 담은 mixin.
  각 목록 Notifier(`@riverpod class BoardList ... with PaginationMixin`)에 섞어 쓴다. 채팅은 실시간 스트림으로 동기화한다.
- 각 도메인 repository 는 `PaginationRepository` 를 상속해 컬렉션과 `fromJson` 만 지정한다.

### 라우팅

`go_router` 명명 라우트를 사용하며, 각 화면이 `static get routeName` 으로 이름을 노출한다.

| 경로 | 이름 | 화면 | 전달 값 |
| --- | --- | --- | --- |
| `/splash` | `splash` | `SplashScreen` | — |
| `/login` | `login` | `LoginScreen` | — |
| `/login/eula` | `eula` | `EulaScreen` | query `isAnonymous` |
| `/login/sign_up` | `sign_up` | `SignUpScreen` | — |
| `/` | `home` | `HomeTab` | — |
| `/board_detail/:id` | `board_detail` | `BoardDetailScreen` | path `id` |
| `/board_create` | `board_create` | `BoardCreateScreen` | — |
| `/profile_edit` | `profile_edit` | `ProfileEditScreen` | query `userName`, `email` |
| `/license` | `license` | `LicenseScreen` | — |

앱은 항상 `/splash` 로 시작해, 강제 업데이트 확인 후 로그인 여부에 따라 `/` 또는 `/login` 으로 분기한다.

## Firestore 데이터 모델

| 컬렉션 | 설명 | 주요 필드 |
| --- | --- | --- |
| `board/{boardId}` | 게시글 | `id`, `title`, `content`, `userName`, `userUid`, `date` |
| `board/{boardId}/comment/{commentId}` | 댓글 (하위 컬렉션) | `id`, `content`, `userName`, `userUid`, `date` |
| `chat/{chatId}` | 채팅 메시지 | `id`, `content`, `userName`, `userUid`, `date` |
| `user/{uid}` | 유저 프로필 | `id`, `userName`, `isAnonymous`, `email` |
| `user/{uid}/blockUser/{blockedUid}` | 차단 목록 (하위 컬렉션) | `blockUserUid` |
| `report/{reportId}` | 신고 내역 | 신고자·피신고자 정보, `reportReason`, `reportContentId`, `date` |

> 목록 정렬 및 페이지네이션은 모든 컬렉션에서 `date` 필드를 기준으로 한다.

## 시작하기

### 사전 준비

- **FVM** 으로 Flutter 3.44.9 사용 (버전은 `.fvmrc` 에 고정)
- **Firebase 프로젝트** (`ddai-community`) 접근 권한
  - `android/app/google-services.json`
  - `ios/Runner/GoogleService-Info.plist`
  - `lib/firebase_options.dart` (`flutterfire configure` 로 생성)

### 환경 변수 (`.env`)

프로젝트 루트에 `.env` 파일을 만들고 아래 키를 채운다. (앱 실행 시 `flutter_dotenv` 로 로드)

```dotenv
FIREBASE_WEB_API_KEY=
FIREBASE_ANDROID_API_KEY=
FIREBASE_IOS_API_KEY=
```

`lib/firebase_options.dart` 는 API 키를 하드코딩하지 않고 이 값들을 참조하도록
`core/constants/firebase_env.dart` 를 통해 커스터마이징되어 있다.
`.env` 가 없거나 키가 비어 있으면 앱 시작 시 크래시하므로 반드시 먼저 준비해야 한다.

### 설치 및 실행

```bash
fvm install                        # .fvmrc 의 Flutter 버전 설치
fvm flutter pub get                # 의존성 설치
fvm dart run build_runner build    # *.g.dart 코드 생성
fvm flutter run                    # 앱 실행
```

> 모델(`@JsonSerializable`)을 수정하면 `build_runner` 를 다시 실행해 `*.g.dart` 를 갱신해야 한다.

### Remote Config

강제 업데이트를 위해 Firebase Remote Config 에 `version_name`(예: `1.4.0`) 파라미터가 **반드시** 필요하다.
현재 앱 버전의 major/minor 가 이보다 낮으면 업데이트 안내 후 앱을 종료한다. (patch 차이는 허용)

> Remote Config 조회에 실패하면 업데이트 여부를 판단할 수 없으므로 안내 후 앱을 종료한다.
> 즉 `version_name` 파라미터가 없으면 스플래시에서 앱이 뜨지 않는다.

## 사용 패키지

### Dependencies

- [cupertino_icons](https://pub.dev/packages/cupertino_icons)
- [go_router](https://pub.dev/packages/go_router)
- [json_annotation](https://pub.dev/packages/json_annotation)
- [firebase_core](https://pub.dev/packages/firebase_core)
- [firebase_auth](https://pub.dev/packages/firebase_auth)
- [firebase_remote_config](https://pub.dev/packages/firebase_remote_config)
- [cloud_firestore](https://pub.dev/packages/cloud_firestore)
- [logger](https://pub.dev/packages/logger)
- [flutter_riverpod](https://pub.dev/packages/flutter_riverpod)
- [riverpod_annotation](https://pub.dev/packages/riverpod_annotation)
- [flutter_dotenv](https://pub.dev/packages/flutter_dotenv)
- [package_info_plus](https://pub.dev/packages/package_info_plus)

### Dev Dependencies

- [flutter_lints](https://pub.dev/packages/flutter_lints)
- [build_runner](https://pub.dev/packages/build_runner)
- [json_serializable](https://pub.dev/packages/json_serializable)
- [riverpod_generator](https://pub.dev/packages/riverpod_generator)

## 에셋

| 경로 | 용도 |
| --- | --- |
| `asset/fonts/NotoSansKR-*.otf` | 앱 전역 기본 폰트 `NotoSans` (Thin 100 ~ Black 900) |

폰트는 `AppTheme.light` 의 `fontFamily: 'NotoSans'` 로 전역 적용된다.

## 개발 규칙

- **언어**: 코드 주석·다이얼로그 문구·문서는 한국어로 작성한다.
- **코드 생성**: `*.g.dart` 는 직접 수정하지 않는다. 모델(`@JsonSerializable`)이나
  provider(`@riverpod`)를 변경하면 `fvm dart run build_runner build` 를 실행한다.
- **Riverpod**: `@riverpod` / `@Riverpod` 애너테이션 기반 코드 생성만 사용한다.
  구형 `StateNotifier` · `StateProvider` 는 사용하지 않는다.
- **import 정렬**: `dart:` → `package:` 순으로 그룹을 나누고 그룹 안에서는 알파벳순으로 정렬한다.
- **문서 주석**: 공개 최상위 선언에는 `///` 주석을 단다.
- **정적 분석**: `fvm flutter analyze` 가 0 issue 인 상태를 유지한다.
  (`analysis_options.yaml` 에서 `use_build_context_synchronously` 만 `ignore` 로 완화)

## 테스트

아직 테스트 코드가 없다(`test/` 디렉터리 없음). 추가 시 `fvm flutter test` 로 실행한다.
