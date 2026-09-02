# ddai_community

Flutter + Supabase 기반 커뮤니티 앱.

[앱 안내](https://ddai-min.notion.site/1ce98497e613806b8b98e631cc606628)

## Stack

<img src="https://img.shields.io/badge/flutter-02569B?style=for-the-badge&logo=flutter&logoColor=white"> <img src="https://img.shields.io/badge/supabase-3FCF8E?style=for-the-badge&logo=supabase&logoColor=white"> <img src="https://img.shields.io/badge/postgresql-4169E1?style=for-the-badge&logo=postgresql&logoColor=white"> <img src="https://img.shields.io/badge/riverpod-40C4FF?style=for-the-badge&logoColor=white">

- **Client**: Flutter 3.44.9 (FVM 관리), Dart `>=3.12.0 <4.0.0` (번들 Dart 3.12.2)
- **Backend**: Supabase — Auth, Postgres(+RLS), Realtime, Edge Functions
- **상태 관리**: Riverpod (`flutter_riverpod` + `riverpod_generator` 코드 생성)
- **라우팅**: `go_router`
- **직렬화**: `json_serializable` / `json_annotation`

> 원래 Firebase(Auth · Firestore · Remote Config) 기반이었으나 Supabase 로 전환했다.
> 스키마 · RLS 정책 전문과 단계별 전환 기록은 [`docs/supabase-migration.md`](docs/supabase-migration.md) 에 있다.

## 주요 기능

- **인증**: 이메일 회원가입/로그인, 익명 로그인, 로그아웃, 계정 삭제(비밀번호 재확인)
- **게시판**: 목록(무한 스크롤·당겨서 새로고침), 작성, 상세 조회, 삭제, 댓글 작성
- **채팅**: 전체 공개 실시간 채팅 (Supabase Realtime)
- **프로필**: 닉네임 수정, 오픈소스 라이선스 확인
- **커뮤니티 보호**: 게시글/작성자 신고, 유저 차단, EULA 약관 동의
  - 차단은 **RLS 정책이 서버에서 강제**한다. 차단한 유저의 글은 목록에서 사라지고,
    클라이언트를 조작해도 조회되지 않는다.
- **강제 업데이트**: `app_config` 테이블의 최신 버전과 비교해 구버전이면 안내 후 종료
  (`runApp()` 이전에 확인하므로 별도 스플래시 화면이 필요 없다)

## 프로젝트 구조

기능 단위로 나눈 뒤 각 기능 안에서 `data` / `domain` / `presentation` 계층을 반복하는
**feature-first + layered** 구조이다. 기능에 종속되지 않는 공통 자산은 `core/` 에 모은다.

```
lib/
├── main.dart                     # 진입점 (Bootstrap 실행 → App 실행)
│
├── app/                          # 앱 전역 조립
│   ├── app.dart                  #   App 루트 위젯 — 인증 동기화 · 라우터/차단 화면 분기
│   ├── app_update.dart           #   강제 업데이트 확인 (UI 없는 순수 로직)
│   └── bootstrap.dart            #   .env 로드 & Supabase 초기화
│
├── core/                         # 기능에 종속되지 않는 공통 자산
│   ├── constants/                #   색상 · Supabase 환경 변수
│   ├── data/                     #   supabase 클라이언트 getter · PaginationRepository · AppConfigRepository
│   ├── models/                   #   ModelWithId · PaginationModel · PaginationCursor
│   ├── providers/                #   PaginationMixin · sessionUidProvider
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
    └── user/                     #   프로필 · 신고 · 전역 유저 상태 · 오픈소스 라이선스

supabase/
├── config.toml                   # Supabase CLI 설정
└── functions/delete-account/     # 계정 삭제 Edge Function (Deno)
```

각 기능 폴더는 동일한 3계층을 갖는다. (해당 계층이 없으면 폴더도 만들지 않는다)

```
features/board/
├── data/                         # BoardRepository · CommentRepository (Supabase 송수신)
├── domain/                       # BoardModel · CommentModel · 요청 파라미터
└── presentation/
    ├── providers/                # boardListProvider · commentListProvider 등
    ├── screens/                  # 목록 / 상세 / 작성 화면
    └── widgets/                  # 목록 아이템 · 상세 버튼 · 댓글 입력 등 재사용 위젯
```

### 계층 역할

| 계층 | 역할 |
| --- | --- |
| `data` | Supabase(Postgres/Auth) 송수신 — repository |
| `domain` | JSON 직렬화 모델(`*_model.dart`)과 요청 파라미터(`*_parameter.dart`) |
| `presentation/providers` | Riverpod provider — 상태 관리 및 screen ↔ repository 연결 |
| `presentation/screens` | 실제 화면 위젯 (provider 를 구독해 UI 구성, `routeName` 노출) |
| `presentation/widgets` | 화면을 구성하는 재사용 위젯 |

> 의존 방향은 `features → core` 단방향이며 **예외는 없다.**
> 목록이 로그인 유저 변경을 감지해야 하는 부분은 core 안의 `sessionUidProvider` 가 담당한다.

## 아키텍처 & 데이터 흐름

```
Screen ──watch/read──▶ Provider(Riverpod) ──▶ Repository ──▶ Supabase(Postgres/Auth)
  ▲                          │
  └──────── state ───────────┘
```

- 화면(`presentation/screens`)은 provider 를 `watch` 해 상태를 구독하고, 액션은 `read` 로 트리거한다.
- provider 는 repository 를 호출해 Supabase 와 통신하고 결과를 상태로 반영한다.
- 전역 로그인 유저 상태는 `userMeProvider`(`@Riverpod(keepAlive: true) class UserMe`)가 보관하며,
  `app/app.dart` 의 `supabase.auth.onAuthStateChange` 리스너가 갱신한다.

### 제네릭 페이지네이션 시스템

게시판·채팅·댓글 목록은 하나의 공통 모듈로 처리된다.

- **`PaginationRepository<T extends ModelWithId>`**: `created_at desc, id desc` **keyset 커서**
  페이지네이션(`fetchData`)과 실시간 스트림(`streamData`)을 제공한다.
  같은 시각에 만들어진 행이 있어도 페이지 경계에서 누락/중복이 생기지 않도록
  `id` 로 타이브레이크한다.
- **`PaginationMixin<T>`**: 목록 상태(`PaginationModel<T>`) 공통 로직(다음 페이지·새로고침·스트림)을 담은 mixin.
  각 목록 Notifier(`@riverpod class BoardList ... with PaginationMixin`)에 섞어 쓴다.
  채팅은 실시간 스트림으로 동기화한다.
- 각 도메인 repository 는 `PaginationRepository` 를 상속해 테이블과 `fromJson` 만 지정한다.
  댓글처럼 부모 행으로 좁혀야 하면 `parentColumn`(`board_id`)을 함께 지정한다.
- **차단 필터는 클라이언트에 없다.** RLS 정책 `is_blocked()` 가 서버에서 처리한다.

### 라우팅

`go_router` 명명 라우트를 사용하며, 각 화면이 `static get routeName` 으로 이름을 노출한다.

| 경로 | 이름 | 화면 | 전달 값 |
| --- | --- | --- | --- |
| `/login` | `login` | `LoginScreen` | — |
| `/login/eula` | `eula` | `EulaScreen` | query `isAnonymous` |
| `/login/sign_up` | `sign_up` | `SignUpScreen` | — |
| `/` | `home` | `HomeTab` | — |
| `/board_detail/:id` | `board_detail` | `BoardDetailScreen` | path `id` |
| `/board_create` | `board_create` | `BoardCreateScreen` | — |
| `/profile_edit` | `profile_edit` | `ProfileEditScreen` | query `userName`, `email` |
| `/license` | `license` | `LicenseScreen` | — |

**스플래시 라우트는 없다.** 강제 업데이트 확인은 `runApp()` 이전에 끝나고,
시작 화면은 세션 유무에 따라 곧바로 `/` 또는 `/login` 이 된다.
확인 결과가 정상이 아니면 라우터를 아예 띄우지 않고 안내 후 앱을 종료한다.

## 데이터 모델 (Postgres)

| 테이블 | 설명 | 주요 컬럼 |
| --- | --- | --- |
| `profile` | 유저 프로필 (`auth.users` 와 1:1) | `id`, `user_name`, `is_anonymous`, `email`, `created_at` |
| `board` | 게시글 | `id`, `title`, `content`, `user_name`, `user_uid`, `created_at` |
| `comment` | 댓글 | `id`, `board_id`, `content`, `user_name`, `user_uid`, `created_at` |
| `chat` | 채팅 메시지 | `id`, `content`, `user_name`, `user_uid`, `created_at` |
| `block_user` | 차단 목록 | `blocker_uid`, `blocked_uid` (복합 PK), `created_at` |
| `report` | 신고 내역 | 신고자·피신고자 정보, `report_reason`, `report_content_id`, `created_at` |
| `app_config` | 앱 설정 (Remote Config 대체) | `key`, `value` |

- 목록 정렬 및 페이지네이션은 모든 테이블에서 `created_at` 을 기준으로 한다.
- 회원가입 시 `profile` 행은 DB 트리거 `handle_new_user` 가 자동 생성한다.
- **모든 테이블에 RLS 가 켜져 있다.** 정책 전문은 `docs/supabase-migration.md` §2 참고.

## 시작하기

### 사전 준비

- **FVM** 으로 Flutter 3.44.9 사용 (버전은 `.fvmrc` 에 고정)
- **Supabase 프로젝트** 접근 권한
  - 스키마 · RLS 정책은 `docs/supabase-migration.md` 의 SQL 을 그대로 실행하면 된다.
  - Authentication → Providers 에서 **Anonymous sign-ins** 를 켠다.
  - `chat` 테이블이 `supabase_realtime` publication 에 포함돼야 실시간 채팅이 동작한다.

### 환경 변수 (`.env`)

프로젝트 루트에 `.env` 파일을 만들고 아래 키를 채운다. (앱 실행 시 `flutter_dotenv` 로 로드)

```dotenv
SUPABASE_URL=https://<project-ref>.supabase.co
SUPABASE_PUBLISHABLE_KEY=sb_publishable_...
```

`.env` 가 없거나 키가 비어 있으면 앱 시작 시 크래시하므로 반드시 먼저 준비해야 한다.

> **secret 키(`sb_secret_...`, 구 `service_role`)는 절대 넣지 않는다.** RLS 를 우회하는 키다.
> 서버 권한이 필요한 작업(계정 삭제)은 Edge Function 런타임에서만 처리한다.

### 설치 및 실행

```bash
fvm install                        # .fvmrc 의 Flutter 버전 설치
fvm flutter pub get                # 의존성 설치
fvm dart run build_runner build    # *.g.dart 코드 생성
fvm flutter run                    # 앱 실행
```

> 모델(`@JsonSerializable`)이나 provider(`@riverpod`)를 수정하면
> `build_runner` 를 다시 실행해 `*.g.dart` 를 갱신해야 한다.

### Edge Function 배포

계정 삭제는 클라이언트에서 할 수 없어 Edge Function 을 거친다.
**반드시 프로젝트 루트에서** 실행한다. (`supabase link` 는 실행한 디렉터리에 설정을 새로 만든다)

```bash
supabase login
supabase functions deploy delete-account --project-ref <project-ref>
```

### 강제 업데이트 (`app_config`)

`app_config` 테이블에 `version_name` 행이 **반드시** 필요하다.

```sql
insert into public.app_config (key, value) values ('version_name', '1.4.0');
```

현재 앱 버전의 major/minor 가 이보다 낮으면 업데이트 안내 후 앱을 종료한다. (patch 차이는 허용)

> 조회에 실패하면 업데이트 여부를 판단할 수 없으므로 안내 후 앱을 종료한다.
> 즉 `version_name` 행이 없으면 스플래시에서 앱이 뜨지 않는다.
> `app_config` 의 SELECT 정책은 **`anon` 롤에도 열려 있어야 한다** — 스플래시가 로그인 전에 읽는다.

> 현재 앱 버전은 `pubspec.yaml` 의 `1.5.0+8` 이다. 업데이트를 강제하려면
> `version_name` 을 **1.6.0 이상**(major 또는 minor 가 더 큰 값)으로 올린다.

## 사용 패키지

### Dependencies

- [cupertino_icons](https://pub.dev/packages/cupertino_icons)
- [go_router](https://pub.dev/packages/go_router)
- [json_annotation](https://pub.dev/packages/json_annotation)
- [supabase_flutter](https://pub.dev/packages/supabase_flutter)
- [logger](https://pub.dev/packages/logger)
- [flutter_riverpod](https://pub.dev/packages/flutter_riverpod)
- [riverpod_annotation](https://pub.dev/packages/riverpod_annotation)
- [flutter_dotenv](https://pub.dev/packages/flutter_dotenv)
- [package_info_plus](https://pub.dev/packages/package_info_plus)
- [flutter_native_splash](https://pub.dev/packages/flutter_native_splash)

### Dev Dependencies

- [flutter_lints](https://pub.dev/packages/flutter_lints)
- [build_runner](https://pub.dev/packages/build_runner)
- [json_serializable](https://pub.dev/packages/json_serializable)
- [riverpod_generator](https://pub.dev/packages/riverpod_generator)

## 에셋

| 경로 | 용도 |
| --- | --- |
| `asset/fonts/NotoSansKR-*.otf` | 앱 전역 기본 폰트 `NotoSans` (Thin 100 ~ Black 900) |
| `asset/img/splash.png` | 네이티브 스플래시 원본 (1152×1152, 투명 배경) |

폰트는 `AppTheme.light` 의 `fontFamily: 'NotoSans'` 로 전역 적용된다.
스플래시 이미지는 **런타임 에셋이 아니라** 빌드 시점에 네이티브 리소스로 구워지므로
`flutter: assets:` 에 선언하지 않는다.

### 네이티브 스플래시

`flutter_native_splash` 로 생성한다. 앱 실행 즉시 브랜드 색과 워드마크가 뜨고,
흰 화면이 스치는 구간이 없다.

```bash
fvm dart run flutter_native_splash:create   # pubspec 의 flutter_native_splash 설정으로 재생성
```

`main()` 이 `FlutterNativeSplash.preserve()` 로 스플래시를 붙잡아 두고,
초기화와 강제 업데이트 확인이 끝나 **첫 화면이 그려진 뒤** `App` 이 `remove()` 한다.
Dart 쪽 스플래시 화면은 없다 — 네트워크 확인이 끝날 때까지 네이티브 스플래시가 그대로 유지된다.

## 개발 규칙

- **언어**: 코드 주석·다이얼로그 문구·문서는 한국어로 작성한다.
- **Supabase 접근**: `core/data/supabase_client.dart` 의 전역 getter `supabase` 를 사용한다.
- **모델 매핑**: Postgres 는 snake_case 이므로 모델에 `@JsonSerializable(fieldRename: FieldRename.snake)`
  를 붙이고, 날짜 필드는 `@JsonKey(name: 'created_at')` 로 매핑한다.
- **쓰기 페이로드**: 모델의 `toJson()` 이 아니라 `*Params` 에서 명시적 map 을 만들어 insert 한다.
  `id` 와 `created_at` 은 DB 기본값에 맡긴다.
- **RLS 확인**: PostgREST 는 권한이 없어도 예외 대신 **0행**을 반환한다.
  삭제/수정 성공 여부가 필요하면 `.select()` 로 영향받은 행을 되받아 확인한다.
- **코드 생성**: `*.g.dart` 는 직접 수정하지 않는다. 모델(`@JsonSerializable`)이나
  provider(`@riverpod`)를 변경하면 `fvm dart run build_runner build` 를 실행한다.
- **Riverpod**: `@riverpod` / `@Riverpod` 애너테이션 기반 코드 생성만 사용한다.
  구형 `StateNotifier` · `StateProvider` 는 사용하지 않는다.
- **import 정렬**: `dart:` → `package:` 순으로 그룹을 나누고 그룹 안에서는 알파벳순으로 정렬한다.
- **문서 주석**: 공개 최상위 선언에는 `///` 주석을 단다.
- **정적 분석**: `fvm flutter analyze` 가 0 issue 인 상태를 유지한다.
  (`analysis_options.yaml` 에서 `use_build_context_synchronously` 만 `ignore` 로 완화)
- **포매터**: `analysis_options.yaml` 에 `formatter: trailing_commas: preserve` 를 켜 두었다.
  Dart 3.7 부터 포매터가 trailing comma 를 무시하므로, 이 설정이 없으면
  저장(format on save)할 때마다 인자들이 한 줄로 합쳐진다.
- **버전**: `pubspec.yaml` 이 단일 출처다. iOS `project.pbxproj` 나 Android `build.gradle` 에
  버전을 적지 않는다. Xcode General 탭에서 버전을 고치면 `MARKETING_VERSION` 이 기록되어
  pubspec 이 무시되므로 주의한다.
- **Android Studio**: Flutter 프로젝트는 루트를 열어야 한다.
  `android/` 만 따로 열면 Gradle/JDK 설정이 프로젝트와 어긋난다.

## 테스트

아직 테스트 코드가 없다(`test/` 디렉터리 없음). 추가 시 `fvm flutter test` 로 실행한다.
