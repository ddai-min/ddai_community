# ddai_community

Flutter + Firebase 기반 커뮤니티 앱.

[앱 안내](https://ddai-min.notion.site/1ce98497e613806b8b98e631cc606628)

## Stack

<img src="https://img.shields.io/badge/flutter-02569B?style=for-the-badge&logo=flutter&logoColor=white"> <img src="https://img.shields.io/badge/firebase-DD2C00?style=for-the-badge&logo=firebase&logoColor=white"> <img src="https://img.shields.io/badge/riverpod-40C4FF?style=for-the-badge&logoColor=white">

- **Client**: Flutter 3.44.8 (FVM 관리), Dart `>=3.12.0 <4.0.0` (번들 Dart 3.12.2)
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

각 도메인(`board`/`chat`/`user`)이 동일한 계층 구조를 갖는 **feature-first** 구조이다.

```
lib/
├── main.dart                # 진입점, 인증 상태 → 전역 유저 상태 동기화, MaterialApp.router
├── bootstrap.dart           # .env 로드 & Firebase 초기화
├── firebase_options.dart    # FlutterFire 자동 생성 (수정 금지)
│
├── board/                   # 게시글 · 댓글
│   ├── component/           #   재사용 위젯 (목록 아이템, 상세 버튼 등)
│   ├── model/               #   BoardModel · CommentModel · 요청 파라미터
│   ├── provider/            #   Riverpod provider
│   ├── repository/          #   Firestore 송수신
│   └── view/                #   화면 (목록/상세/작성)
├── chat/                    # 실시간 채팅 (동일 계층 구조)
├── user/                    # 회원가입 · 로그인 · 프로필 · 신고/차단 (동일 계층 구조)
│
└── common/                  # 도메인 공통
    ├── component/           #   공통 위젯 (버튼, 다이얼로그, 텍스트필드, 로딩 오버레이 등)
    ├── const/               #   색상 · 라이선스 상수
    ├── converter/           #   TimestampConverter (Firestore Timestamp ↔ DateTime)
    ├── layout/              #   DefaultLayout (공통 Scaffold)
    ├── model/               #   ModelWithId · PaginationModel
    ├── provider/            #   PaginationMixin (페이지네이션 공통 로직)
    ├── repository/          #   PaginationRepository (제네릭 Firestore 조회)
    ├── router/              #   go_router 라우트 정의
    ├── util/                #   DataUtils · RegUtils
    └── view/                #   Splash · HomeTab · License
```

### 계층 역할

| 계층 | 역할 |
| --- | --- |
| `view` | 실제 화면 위젯 (Riverpod provider 를 구독해 UI 구성) |
| `component` | 화면을 구성하는 재사용 위젯 |
| `provider` | Riverpod provider — 상태 관리 및 view ↔ repository 연결 |
| `repository` | Firebase(Firestore/Auth) 송수신 |
| `model` | JSON 직렬화 모델(`*_model.dart`)과 요청 파라미터(`*_parameter.dart`) |

## 아키텍처 & 데이터 흐름

```
View ──watch/read──▶ Provider(Riverpod) ──▶ Repository ──▶ Firebase(Firestore/Auth)
  ▲                        │
  └──────── state ─────────┘
```

- 화면은 provider 를 `watch` 해 상태를 구독하고, 액션은 `read` 로 트리거한다.
- provider 는 repository 를 호출해 Firebase 와 통신하고 결과를 상태로 반영한다.
- 전역 로그인 유저 상태는 `userMeProvider`(`StateProvider<UserModel>`)가 보관하며,
  `main.dart` 의 `FirebaseAuth.authStateChanges()` 리스너가 갱신한다.

### 제네릭 페이지네이션 시스템

게시판·채팅·댓글 목록은 하나의 공통 모듈로 처리된다.

- **`PaginationRepository<T extends ModelWithId>`**: 커서 기반 페이지네이션(`fetchData`)과
  실시간 스트림(`streamData`)을 제공한다. 조회 시 현재 유저가 **차단한 유저의 글을 자동 제외**한다.
- **`PaginationMixin<T>`**: 목록 상태(`PaginationModel<T>`) 공통 로직(다음 페이지·새로고침·스트림)을 담은 mixin.
  각 목록 Notifier(`@riverpod class BoardList ... with PaginationMixin`)에 섞어 쓴다. 채팅은 실시간 스트림으로 동기화한다.
- 각 도메인 repository 는 `PaginationRepository` 를 상속해 컬렉션과 `fromJson` 만 지정한다.

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

- **FVM** 으로 Flutter 3.35.4 사용 (버전은 `.fvmrc` 에 고정)
- **Firebase 프로젝트** (`ddai-community`) 접근 권한
  - `android/app/google-services.json`
  - `ios/Runner/GoogleService-Info.plist`
  - `lib/firebase_options.dart` (`flutterfire configure` 로 생성)

### 환경 변수 (`.env`)

프로젝트 루트에 `.env` 파일을 만들고 아래 키를 채운다. (앱 실행 시 `flutter_dotenv` 로 로드)

```dotenv
IOS_BUNDLE_ID=
ANDROID_PACKAGE_NAME=
FIREBASE_WEB_API_KEY=
FIREBASE_ANDROID_API_KEY=
FIREBASE_IOS_API_KEY=
```

### 설치 및 실행

```bash
fvm install                        # .fvmrc 의 Flutter 버전 설치
fvm flutter pub get                # 의존성 설치
fvm dart run build_runner build    # *.g.dart 코드 생성
fvm flutter run                    # 앱 실행
```

> 모델(`@JsonSerializable`)을 수정하면 `build_runner` 를 다시 실행해 `*.g.dart` 를 갱신해야 한다.

### Remote Config

강제 업데이트를 위해 Firebase Remote Config 에 `version_name`(예: `1.4.0`) 파라미터가 필요하다.
현재 앱 버전의 major/minor 가 이보다 낮으면 업데이트 안내 후 앱을 종료한다. (patch 차이는 허용)

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
- [flutter_dotenv](https://pub.dev/packages/flutter_dotenv)
- [package_info_plus](https://pub.dev/packages/package_info_plus)

### Dev Dependencies

- [flutter_lints](https://pub.dev/packages/flutter_lints)
- [build_runner](https://pub.dev/packages/build_runner)
- [json_serializable](https://pub.dev/packages/json_serializable)
