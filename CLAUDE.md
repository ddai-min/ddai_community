# CLAUDE.md

이 저장소에서 작업하는 Claude Code(및 신규 개발자)를 위한 안내서.
사용자 대상 소개·설치 안내는 `README.md` 를 참고한다.

## 프로젝트 개요

`ddai_community` — Flutter + Firebase 커뮤니티 앱. 게시판, 실시간 채팅, 인증(이메일/익명),
신고·차단 기능을 제공한다. 상태 관리는 Riverpod, 라우팅은 go_router 를 사용한다.

## 명령어

이 프로젝트는 **FVM** 으로 Flutter 버전(3.41.6, `.fvmrc`, 번들 Dart 3.11.4)을 고정한다. 항상 `fvm` 접두사를 사용한다.

```bash
fvm flutter pub get                # 의존성 설치
fvm dart run build_runner build    # *.g.dart 재생성 (모델 변경 후 필수)
fvm flutter analyze                # 정적 분석
fvm flutter run                    # 실행
fvm flutter test                   # 테스트
```

## 아키텍처

**feature-first** 구조. 각 도메인(`board`/`chat`/`user`)이 동일한 계층을 반복한다.

```
view  ──watch/read──▶  provider(Riverpod)  ──▶  repository  ──▶  Firebase
```

- `lib/<feature>/{component,model,provider,repository,view}/`
- `lib/common/` — 공통 요소(`const`, `converter`, `layout`, `model`, `provider`, `repository`, `router`, `util`, `view`)
- 진입점: `main.dart` → `bootstrap.dart`(`.env` 로드 + Firebase 초기화) → `MaterialApp.router`(초기 경로 `/splash`)

### 핵심 패턴: 제네릭 페이지네이션

목록(게시판/채팅/댓글)은 모두 공통 모듈을 통해 처리된다. 새 목록 기능을 추가할 때 이 패턴을 따른다.

- `common/repository/pagination_repository.dart` — `PaginationRepository<T extends ModelWithId>`
  - `fetchData(...)`: 커서(`startAfterDocument`) 기반 페이지네이션. **차단 유저 글 자동 제외**(`whereNotIn`).
  - `streamData(...)`: 실시간 스트림(채팅용).
  - `CollectionPath` enum 의 `name` 이 실제 Firestore 컬렉션 경로다.
- `common/provider/pagination_provider.dart` — `PaginationNotifier<T>` (`Notifier<PaginationModel<T>>`, Riverpod 3)
  - 각 목록은 이 제네릭 base 를 **상속한 구체 Notifier**(`BoardListNotifier`/`ChatListNotifier`/`CommentListNotifier`)로 만들고,
    `readRepository()`·`collectionPath`·(필요 시) `subCollectionPath`·`isUsingStream` 만 override 한다.
  - `isUsingStream: true` → `build` 시 스트림 구독(채팅), `false` → `fetchData` 호출 시 다음 페이지 append(게시판/댓글).
  - provider 는 `NotifierProvider.autoDispose(.family)(구체Notifier.new)` 로 노출한다. (family 인자는 Notifier 생성자로 주입)
- 각 도메인 repository 는 `PaginationRepository` 를 **상속**해 `collectionPath` 와 `fromJson` 만 지정한다.
  (예: `BoardRepository`, `CommentRepository`, `ChatRepository`)

## 관례 (Conventions)

- **언어**: 코드 주석·다이얼로그 문구·문서는 **한국어**로 작성한다.
- **Repository**: 단건 조회/생성/삭제는 `static` 메서드. 성공 여부는 `bool`, 조회는 `Model?`(실패 시 `null`) 반환.
  모든 메서드는 `try/catch` 로 감싸고 실패 시 전역 `logger`(main.dart 정의)로 로깅 후 안전한 기본값을 반환한다.
- **Provider 네이밍**: `xxxRepositoryProvider`(인스턴스), `getXxxProvider`(조회),
  `addXxxProvider`/`deleteXxxProvider`(변경). 목록 조회는 `NotifierProvider`(위 페이지네이션),
  단건 조회·변경 계열은 대부분 `FutureProvider.family.autoDispose<..., Params>`.
- **Model**: `@JsonSerializable` + `part '*.g.dart'`. 목록 대상 모델은 `ModelWithId`(문서 `id` 노출)를 구현한다.
  날짜 필드는 `@TimestampConverter()` 로 Firestore `Timestamp` ↔ `DateTime` 변환.
- **요청 파라미터**: `*_parameter.dart` 의 별도 클래스(예: `AddBoardParams`)로 전달한다.
- **전역 유저 상태**: `userMeProvider`(`NotifierProvider<UserMeNotifier, UserModel>`). `id == ''` 이면 비로그인.
  갱신은 `ref.read(userMeProvider.notifier).update((state) => ...)` 로 하며, 주로 `main.dart` 의
  `FirebaseAuth.authStateChanges()` 리스너에서 이루어진다.
- **화면 공통 레이아웃**: `DefaultLayout`(공통 Scaffold). `title` 을 주면 브랜드 색 AppBar 가 렌더된다.
- **라우팅**: go_router 명명 라우트. 각 화면은 `static get routeName` 을 노출한다.
  값 전달은 path parameter(`:id`)와 query parameter(`isAnonymous`, `userName` 등) 사용.
- **인증 예외**: `FirebaseAuthExceptionCode` enum 으로 매핑하고, 미분류 예외는 `unknownError` 로 처리.

## 주의사항 (Gotchas)

- **생성 파일 직접 수정 금지**: `*.g.dart`, `lib/firebase_options.dart`. 모델 변경 후 `build_runner` 를 실행한다.
- **Riverpod 3 패턴**: 상태는 `Notifier`/`NotifierProvider`(권장 패턴)로 작성한다. 구형 `StateNotifier(Provider)`·`StateProvider`(legacy.dart)는 사용하지 않는다.
- **Riverpod codegen 불가**: `@riverpod` 코드 생성(`riverpod_generator`)은 현재 **Flutter 3.41.6 이 고정한 `meta 1.17.0` 과 analyzer 버전이 충돌**해 설치 불가하다. 그래서 provider 는 수동으로 작성한다. (Flutter 가 meta 핀을 올리는 향후 버전에서 재검토)
- **build_runner**: 최신 버전에서 `--delete-conflicting-outputs` 플래그는 제거됐고 기본 동작이다. `build_runner build` 로 실행한다.
- **`.env` 필수**: 없으면 시작 시 크래시(`dotenv.env[...]!`). 필요한 키는 `README.md` 참고.
- **정적 분석**: `analysis_options.yaml` 에서 `use_build_context_synchronously` 를 `ignore` 로 설정해 두었다.
- **강제 업데이트**: Remote Config 의 `version_name` 과 앱 버전(major/minor)을 비교한다. (`splash_screen.dart`)
- **차단 로직**: 유저 차단 시 `user/{uid}/blockUser` 에 기록되고, 이후 목록 쿼리에서 자동 제외된다.
- **백엔드**: `functions/` 디렉터리는 비어 있다(Cloud Functions 없음). Firestore 보안 규칙 파일은 저장소에 없다.

## 주요 파일

| 파일 | 역할 |
| --- | --- |
| `lib/main.dart` | 진입점, 인증 상태 동기화, 앱/테마/라우터 구성 |
| `lib/bootstrap.dart` | `.env` 로드 + Firebase 초기화 |
| `lib/common/router/router.dart` | 전체 라우트 정의 |
| `lib/common/repository/pagination_repository.dart` | 제네릭 목록 조회 + 차단 필터 |
| `lib/common/provider/pagination_provider.dart` | 제네릭 목록 상태 관리 |
| `lib/user/repository/auth_repository.dart` | 회원가입/로그인/탈퇴/차단 |
| `lib/common/view/splash_screen.dart` | 강제 업데이트 확인 + 초기 라우팅 분기 |
