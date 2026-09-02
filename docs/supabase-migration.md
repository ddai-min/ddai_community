# Supabase 마이그레이션 기록

Firebase(Auth · Firestore · Remote Config) → **Supabase**(Auth · Postgres · Realtime · Edge Functions) 전환.

> **Phase 0~6 완료.** 앱은 Supabase 위에서 빌드·실행된다. 남은 것은 출시 직전의 Phase 7(CAPTCHA)뿐이다.
> 이 문서는 이제 계획서가 아니라 **스키마 · RLS 정책의 단일 출처이자 전환 기록**이다.
> 스키마를 다시 세우거나 새 환경을 만들 때는 §1(DDL)과 §2(RLS)를 그대로 실행하면 된다.

- 시작 커밋: `7d044bb` → 완료 커밋: `01164b5`
- 클라이언트 패키지: `supabase_flutter: ^2.17.2`
- **데이터 이관 없음** — 기존 Firebase 프로젝트가 삭제되어 보존할 데이터가 없었다. 스키마만 새로 만들었다.

### 단계별 결과

| Phase | 내용 | 상태 |
| --- | --- | --- |
| 0 | Supabase 프로젝트 · 스키마 · RLS | ✅ |
| 1 | 의존성 · 초기화 교체 | ✅ |
| 2 | 인증 + Edge Function 배포 | ✅ |
| 3 | 모델 · 페이지네이션 기반 | ✅ |
| 4 | 게시판 · 댓글 · 채팅 | ✅ |
| 5 | 신고 · 강제 업데이트 → **앱 빌드·실행 성공** | ✅ |
| 6 | `CLAUDE.md` · `README.md` 갱신 | ✅ |
| 7 | CAPTCHA | 출시 직전 |

**아직 남은 검증** — 실기기에서의 UI 조작(무한 스크롤, 당겨서 새로고침, 2기기 채팅,
회원가입 → 로그아웃 → 로그인 → 닉네임 수정 → 탈퇴 전 과정). 각 경로의 서버 동작은
REST · `package:supabase` 스크립트로 이미 확인했다.

---

## 0. 전환 요약

| 영역 | 기존 (Firebase) | 현재 (Supabase) |
| --- | --- | --- |
| 인증 | Firebase Auth (이메일 · 익명) | Supabase Auth (이메일 · 익명) |
| DB | Firestore 문서 + 하위 컬렉션 | Postgres 테이블 + FK |
| 목록 조회 | `startAfterDocument` 커서 | `created_at` keyset 커서 |
| 차단 필터 | 클라이언트가 차단 목록 조회 후 `whereNotIn` | **RLS 정책으로 서버에서 강제** |
| 실시간 채팅 | `snapshots()` | `.stream(primaryKey: ['id'])` |
| 강제 업데이트 | Remote Config `version_name` | `app_config` 테이블 1행 |
| 계정 삭제 | 클라이언트 재인증 + `delete()` | Edge Function (`service_role`) |

### 이번 전환으로 함께 해결된 문제

1. **차단 우회 불가** — 지금은 클라이언트가 차단 목록을 읽어 쿼리에 끼워넣는 구조라, 앱을 우회하면 차단이 무력화된다. RLS 로 옮기면 서버가 강제한다.
2. **차단 11명 이상 시 목록 실패** — Firestore `not-in` 은 값 10개 제한이 있어 11명 이상 차단하면 쿼리가 깨진다. Postgres 서브쿼리에는 제한이 없다.
3. **페이지마다 차단 목록 재조회 제거** — `fetchData()` 가 매 페이지 호출마다 `blockUser` 컬렉션을 통째로 읽는다. RLS 로 옮기면 이 왕복이 사라진다.
4. **`core → features` 역방향 의존 해소** — `core/providers/pagination_provider.dart` 가 uid 를 얻으려 `features/user` 의 `userMeProvider` 를 참조하는 구조가 없어진다. (RLS 가 uid 를 서버에서 판단)

---

## 1. Postgres 스키마

> 테이블명 `comment` · `report` 는 Postgres **비예약어**라 그대로 써도 된다.
> (`user` 는 예약어이므로 `profile` 을 쓴다)

### 1-1. 확장 · 프로필

```sql
create extension if not exists "pgcrypto";   -- gen_random_uuid()

-- auth.users 1:1 확장 테이블
create table public.profile (
  id           uuid primary key references auth.users(id) on delete cascade,
  user_name    text not null,
  is_anonymous boolean not null default false,
  email        text,
  created_at   timestamptz not null default now()
);

-- 회원가입 시 profile 자동 생성
create or replace function public.handle_new_user()
returns trigger
language plpgsql
security definer set search_path = ''
as $$
begin
  insert into public.profile (id, user_name, is_anonymous, email)
  values (
    new.id,
    coalesce(
      new.raw_user_meta_data ->> 'user_name',
      '익명' || substr(new.id::text, 1, 6)      -- DataUtils.setAnonymousName 과 동일 규칙
    ),
    new.is_anonymous,
    new.email
  );
  return new;
end;
$$;

create trigger on_auth_user_created
  after insert on auth.users
  for each row execute function public.handle_new_user();
```

### 1-2. 게시글 · 댓글 · 채팅

```sql
create table public.board (
  id         uuid primary key default gen_random_uuid(),
  title      text not null,
  content    text not null,
  user_name  text not null,
  user_uid   uuid not null references public.profile(id) on delete cascade,
  created_at timestamptz not null default now()
);
create index board_cursor_idx  on public.board (created_at desc, id desc);
create index board_user_idx    on public.board (user_uid);

-- Firestore 의 board/{id}/comment 하위 컬렉션 → FK 테이블
create table public.comment (
  id         uuid primary key default gen_random_uuid(),
  board_id   uuid not null references public.board(id) on delete cascade,
  content    text not null,
  user_name  text not null,
  user_uid   uuid not null references public.profile(id) on delete cascade,
  created_at timestamptz not null default now()
);
create index comment_cursor_idx on public.comment (board_id, created_at desc, id desc);

create table public.chat (
  id         uuid primary key default gen_random_uuid(),
  content    text not null,
  user_name  text not null,
  user_uid   uuid not null references public.profile(id) on delete cascade,
  created_at timestamptz not null default now()
);
create index chat_cursor_idx on public.chat (created_at desc, id desc);
```

### 1-3. 차단 · 신고 · 앱 설정

```sql
create table public.block_user (
  blocker_uid uuid not null references public.profile(id) on delete cascade,
  blocked_uid uuid not null references public.profile(id) on delete cascade,
  created_at  timestamptz not null default now(),
  primary key (blocker_uid, blocked_uid)
);
create index block_user_blocker_idx on public.block_user (blocker_uid);

-- 신고 내역은 유저가 탈퇴해도 남겨야 하므로 uid 는 nullable + set null
create table public.report (
  id                 uuid primary key default gen_random_uuid(),
  reporter_user_name text not null,
  reporter_user_uid  uuid references public.profile(id) on delete set null,
  reported_user_name text not null,
  reported_user_uid  uuid references public.profile(id) on delete set null,
  report_reason      text not null,
  report_content_id  text not null,
  created_at         timestamptz not null default now()
);

-- Remote Config 대체
create table public.app_config (
  key   text primary key,
  value text not null
);
insert into public.app_config (key, value) values ('version_name', '1.4.0');
```

### 1-4. 실시간 활성화

```sql
-- Realtime 은 신규 테이블에 기본 비활성이다. 채팅만 켠다.
alter publication supabase_realtime add table public.chat;
```

---

## 2. RLS 정책

**모든 테이블에 RLS 를 켜지 않으면 anon key 만으로 전체 데이터가 노출된다.** 스키마 생성 직후 반드시 적용한다.

```sql
alter table public.profile    enable row level security;
alter table public.board      enable row level security;
alter table public.comment    enable row level security;
alter table public.chat       enable row level security;
alter table public.block_user enable row level security;
alter table public.report     enable row level security;
alter table public.app_config enable row level security;
```

### 2-1. 차단 판정 함수

```sql
create or replace function public.is_blocked(target_uid uuid)
returns boolean
language sql
stable
security definer set search_path = ''
as $$
  select exists (
    select 1 from public.block_user
    where blocker_uid = auth.uid()
      and blocked_uid = target_uid
  );
$$;
```

### 2-2. 정책

```sql
-- profile: 로그인 유저는 모두 조회, 본인만 수정
create policy profile_select      on public.profile for select to authenticated using (true);
create policy profile_update_own  on public.profile for update to authenticated
  using (id = auth.uid()) with check (id = auth.uid());

-- board / comment / chat: 차단하지 않은 유저의 글만 조회, 본인 글만 작성
create policy board_select      on public.board   for select to authenticated using (not public.is_blocked(user_uid));
create policy board_insert_own  on public.board   for insert to authenticated with check (user_uid = auth.uid());
create policy board_delete_own  on public.board   for delete to authenticated using (user_uid = auth.uid());

create policy comment_select     on public.comment for select to authenticated using (not public.is_blocked(user_uid));
create policy comment_insert_own on public.comment for insert to authenticated with check (user_uid = auth.uid());

create policy chat_select        on public.chat    for select to authenticated using (not public.is_blocked(user_uid));
create policy chat_insert_own    on public.chat    for insert to authenticated with check (user_uid = auth.uid());

-- block_user: 본인 차단 목록만
create policy block_select_own on public.block_user for select to authenticated using (blocker_uid = auth.uid());
create policy block_insert_own on public.block_user for insert to authenticated with check (blocker_uid = auth.uid());
create policy block_delete_own on public.block_user for delete to authenticated using (blocker_uid = auth.uid());

-- report: 작성만 가능, 조회는 불가 (운영자는 대시보드에서 확인)
create policy report_insert on public.report for insert to authenticated with check (reporter_user_uid = auth.uid());

-- app_config: 스플래시가 "로그인 전"에 조회하므로 anon 에게도 열어야 한다
create policy app_config_select on public.app_config for select to anon, authenticated using (true);
```

> 정책의 `anon` · `authenticated` 는 **Postgres 롤 이름**이며 API 키 이름과 무관하다.
> publishable 키로 로그인 없이 접근하면 `anon` 롤, 로그인 후 JWT 를 실으면 `authenticated` 롤로 매핑된다.

> **주의**: `app_config` 의 `anon` 정책을 빼먹으면 스플래시에서 버전 조회가 실패하고,
> 현재 로직상 조회 실패 = `exit(0)` 이므로 **앱이 아예 뜨지 않는다.**

---

## 3. 인증 매핑

Supabase 대시보드에서 **Authentication → Providers → Anonymous sign-ins 를 먼저 활성화**해야 한다.

| 현재 (Firebase) | 전환 후 (Supabase) |
| --- | --- |
| `createUserWithEmailAndPassword(email, password)` | `auth.signUp(email:, password:, data: {'user_name': userName})` |
| `user.updateDisplayName(userName)` | 위 `data` 로 대체 (트리거가 `profile.user_name` 생성) |
| `signInWithEmailAndPassword` | `auth.signInWithPassword(email:, password:)` |
| `signInAnonymously()` | `auth.signInAnonymously()` |
| `authStateChanges()` | `auth.onAuthStateChange` (`AuthState` 스트림) |
| `signOut()` | `auth.signOut()` |
| `reauthenticateWithCredential` + `user.delete()` | Edge Function `delete-account` (§4) |
| `currentUser.updateDisplayName` (프로필 수정) | `auth.updateUser(UserAttributes(data: {...}))` + `profile` UPDATE |

### 예외 코드 매핑

`FirebaseAuthExceptionCode` enum 은 이름만 바꿔 그대로 유지한다 (`AuthExceptionCode`).
Supabase 는 `AuthApiException.code` 로 문자열 코드를 준다.

| `AuthExceptionCode` | Supabase code | 비고 |
| --- | --- | --- |
| `emailAlreadyInUse` | `user_already_exists` · `email_exists` | 두 코드 모두 같은 안내로 묶는다 |
| `weakPassword` | `weak_password` | |
| `invalidCredential` | `invalid_credentials` | **실제 응답으로 확인 완료** |
| `emailNotConfirmed` | `email_not_confirmed` | 아래 "Confirm email" 항목 참고 |
| `anonymousDisabled` | `anonymous_provider_disabled` | 익명 프로바이더가 꺼진 경우 |
| `noUser` | `session_not_found` · `session_missing` | |
| `tooManyRequests` | `over_request_rate_limit` · `over_email_send_rate_limit` | |
| `unknownError` | 그 외 전부 | |

> `gotrue` 의 `ErrorCode` enum 에는 `invalid_credentials` 가 **빠져 있다.** 서버는 그 코드를 내려주므로
> (실제 응답으로 확인) SDK enum 대신 문자열을 직접 비교한다.

---

## 4. Edge Function — 계정 삭제

Supabase 는 **클라이언트에서 유저를 삭제할 수 없다**(`auth.admin.deleteUser` 는 `service_role` 필요).
현재 탈퇴 플로우가 "비밀번호 재확인 → 삭제" 이므로 그 검증까지 함수 안에서 처리한다.

실제 코드는 저장소의 **`supabase/functions/delete-account/index.ts`** 에 있다.
문서와 코드가 어긋나지 않도록 여기서는 계약만 적는다.

| 항목 | 값 |
| --- | --- |
| 요청 | `POST` · 본문 `{"password": "..."}` · `Authorization: Bearer <호출자 JWT>` |
| 성공 | `200` · `{"ok": true}` |
| 비밀번호 불일치 | `401` · `{"code": "invalid_credentials"}` |
| 세션 없음 | `401` · `{"code": "session_not_found"}` |
| 그 외 실패 | `500` · `{"code": "unknown_error"}` |

응답의 `code` 문자열은 앱의 `AuthExceptionCode` 값과 **일부러 일치**시켰다.
Dart 쪽은 `FunctionException.details['code']` 를 그대로 비교한다.

처리 순서는 ① 호출자 JWT 로 신원 확인 → ② (익명이 아니면) 비밀번호 재확인 →
③ secret 키로 `auth.admin.deleteUser`. 연관 행은 FK CASCADE 로 함께 지워진다.

Edge Function 런타임에는 신규 변수(`SUPABASE_URL` · `SUPABASE_PUBLISHABLE_KEYS` · `SUPABASE_SECRET_KEYS` · `SUPABASE_JWKS`)와
레거시 변수(`SUPABASE_ANON_KEY` · `SUPABASE_SERVICE_ROLE_KEY`)가 **함께** 자동 주입된다.
신규 변수명이 복수형이라 값이 단일 키가 아닐 수 있으므로, 위 코드는 형식이 확실한 레거시 변수명을 쓴다.
신규 변수로 옮길 때는 배포 직후 값을 한 번 로깅해 형식을 확인하거나, `supabase secrets set` 으로 명시적 시크릿을 두는 편이 안전하다.

**비밀 키(`service_role` / `sb_secret_...`)는 절대 앱이나 `.env` 에 넣지 않는다.**

Dart 호출:

```dart
final res = await supabase.functions.invoke(
  'delete-account',
  body: {'password': password},
);
```

배포: `supabase functions deploy delete-account`

---

## 5. 페이지네이션 재설계

### 문제

`PaginationModel.lastDocument` 가 `DocumentSnapshot` 타입이라 Firestore 에 직접 묶여 있다. Postgres 에는 스냅샷 개념이 없다.

### 방식: `created_at` keyset 커서

```dart
// core/models/pagination_cursor.dart (신규)
class PaginationCursor {
  final DateTime createdAt;
  final String id;

  const PaginationCursor({required this.createdAt, required this.id});
}
```

`PaginationModel` 의 `DocumentSnapshot? lastDocument` → `PaginationCursor? lastCursor` 로 교체.

### 함께 정리한 API

Firestore 용어와 중복된 배관을 걷어냈다. 저장 모델이 바뀌면서 강제된 변경이 대부분이다.

| 기존 | 변경 후 | 이유 |
| --- | --- | --- |
| `CollectionPath` | `TablePath` | 컬렉션이 아니라 Postgres 테이블이다 |
| `fetchData(collectionPath: ...)` 파라미터 | repository 의 `table` 필드 | 같은 값을 두 곳에서 선언하던 중복 제거 |
| `subCollectionPath` + `collectionId` | repository 의 `parentColumn` + mixin 의 `parentId` | 하위 컬렉션이 없다. 댓글은 `comment.board_id` FK |
| `fetchData(userUid: ...)` | **삭제** | 차단 필터를 RLS 가 처리 |

그 결과 목록 Notifier 가 override 할 것은 `paginationRepository` 하나(+댓글은 `parentId`)로 줄어,
`board_provider` · `chat_provider` · `comment_provider` 도 이 단계에서 함께 손봤다.

```dart
// core/data/pagination_repository.dart 조회부
var query = supabase.from(table).select();

if (parentId != null) {
  query = query.eq('board_id', parentId);   // 댓글 목록
}
if (cursor != null) {
  query = query.lt('created_at', cursor.createdAt.toIso8601String());
}

final rows = await query
    .order('created_at', ascending: false)
    .limit(pageSize);
```

- `userUid` 파라미터와 차단 목록 조회 로직은 **전부 삭제**한다 (RLS 가 처리).
- `created_at` 동시각 충돌이 걱정되면 아래 복합 조건으로 엄밀하게 처리한다.

```dart
query = query.or(
  'created_at.lt.$ts,'
  'and(created_at.eq.$ts,id.lt.${cursor.id})',
);
```

> 더 단순한 `.range(offset, offset + pageSize - 1)` offset 방식도 가능하지만,
> 채팅·게시글처럼 쓰기가 잦으면 페이지 경계에서 항목이 밀리거나 중복된다. keyset 을 권장한다.

### 게시글 상세 + 댓글 동시 조회

`BoardRepository.getBoard()` 는 현재 게시글과 댓글을 **두 번** 조회한다. Supabase 는 FK 임베딩으로 한 번에 가져올 수 있다.

```dart
final row = await supabase
    .from('board')
    .select('*, comment(*)')          // 댓글까지 한 방에
    .eq('id', searchId)
    .single();
```

`BoardModel.commentList` 에 `@JsonKey(name: 'comment')` 를 붙이면 그대로 역직렬화된다.

---

## 6. 실시간 채팅

`.stream()` 은 **변경분(delta)이 아니라 전체 목록 스냅샷**을 흘려보낸다. 현재 `streamData()` 가 목록을 통째로 교체하는 구조와 동일하므로 거의 드롭인이다.

```dart
Stream<List<ChatModel>> streamData() => supabase
    .from('chat')
    .stream(primaryKey: ['id'])
    .order('created_at', ascending: false)
    .limit(100)
    .map((rows) => rows.map(ChatModel.fromJson).toList());
```

`PaginationMixin.subscribeStream()` 은 그대로 두면 된다.

확인할 것:
- `alter publication supabase_realtime add table public.chat;` 실행 여부. 누락되면 채팅이 **조용히** 멈춘다.
- Postgres Changes 는 구독자마다 이벤트를 RLS 로 검증하므로 차단 필터가 실시간에도 적용된다.
  단 **DELETE 이벤트에는 RLS 가 적용되지 않는다** — 채팅은 삭제 기능이 없어 현재는 무관하지만, 나중에 추가하면 고려해야 한다.

---

## 7. 강제 업데이트

조회는 화면이 아니라 **repository** 에 둔다. (`features/splash/data/app_config_repository.dart`)
`FirebaseRemoteConfig.instance` 를 화면에서 직접 부르던 기존 구조와 달리, 이제는 Postgres 조회라
프로젝트의 계층 규칙(`presentation → domain ← data`)을 따르는 편이 맞다.

```dart
// features/splash/data/app_config_repository.dart
static Future<String?> getVersionName() async {
  try {
    final row = await supabase
        .from('app_config')
        .select('value')
        .eq('key', 'version_name')
        .single();

    return row['value'] as String;
  } catch (error) {
    logger.e(error);

    return null;   // 호출부는 이를 "업데이트 확인 불가"로 보고 앱을 종료한다
  }
}
```

비교 로직(major/minor)과 실패 시 `exit(0)` 동작은 그대로 유지한다.
다만 기존 `.then().catchError()` 는 try/catch 로 바꾸고, **버전 문자열 파싱 실패**도
같은 종료 경로로 묶었다. `firebase_remote_config` 의존성은 Phase 1 에서 이미 제거했다.

---

## 8. 모델 변경

Postgres 컬럼은 snake_case, Dart 필드는 camelCase 이므로 **모델마다 `fieldRename` 한 줄**로 해결한다.

```dart
@JsonSerializable(fieldRename: FieldRename.snake)   // userName ↔ user_name
class BoardModel implements ModelWithId {
  ...
  @JsonKey(name: 'created_at')
  final DateTime date;                              // Dart 이름은 date 유지

  @JsonKey(name: 'comment')
  final List<CommentModel>? commentList;
}
```

`TimestampConverter` 는 **삭제**한다. Supabase 는 ISO8601 문자열을 주고, `json_serializable` 이 `DateTime.parse` 를 자동 생성한다. `@TimestampConverter()` 애너테이션 4곳(`board_model` · `comment_model` · `chat_model` · `report_model`)을 지우면 된다.

---

## 9. 파일별 변경 맵

| 파일 | 작업 | 난이도 |
| --- | --- | --- |
| `pubspec.yaml` | firebase 4종 제거, `supabase_flutter` 추가 | 하 |
| `lib/firebase_options.dart` | **삭제** | 하 |
| `lib/core/constants/firebase_env.dart` | `supabase_env.dart` 로 교체 (URL · publishable key) | 하 |
| `lib/app/bootstrap.dart` | `Firebase.initializeApp` → `Supabase.initialize` | 하 |
| `lib/app/app.dart` | `authStateChanges()` → `onAuthStateChange` | 중 |
| `lib/core/converters/timestamp_converter.dart` | **삭제** | 하 |
| `lib/core/models/pagination_model.dart` | `DocumentSnapshot` → `PaginationCursor` | 중 |
| `lib/core/data/pagination_repository.dart` | 전면 재작성 (차단 조회 로직 삭제) | **상** |
| `lib/core/providers/pagination_provider.dart` | `userUid` 전달 제거, `userMeProvider` 의존 정리 | 중 |
| `lib/core/providers/session_provider.dart` | **신설** — `sessionUidProvider` (core → features 역참조 제거) | 하 |
| `lib/features/*/presentation/providers/{board,chat,comment}_provider.dart` | mixin override 정리 (`collectionPath` 삭제, 댓글은 `parentId`) | 하 |
| `lib/features/auth/data/auth_repository.dart` | 전면 재작성 + 탈퇴는 Edge Function 호출 | **상** |
| `lib/features/board/data/board_repository.dart` | 재작성 (`select('*, comment(*)')` 활용) | 중 |
| `lib/features/board/data/comment_repository.dart` | 재작성 | 중 |
| `lib/features/chat/data/chat_repository.dart` | 재작성 (`.stream()`) | 중 |
| `lib/features/user/data/report_repository.dart` | 재작성 (단순 insert) | 하 |
| `lib/features/*/domain/*_model.dart` (4개) | `fieldRename` 추가, `@TimestampConverter` 제거 | 하 |
| `lib/features/splash/.../splash_screen.dart` | Remote Config → `app_config` 조회 | 중 |
| `lib/features/splash/data/app_config_repository.dart` | **신설** — `app_config` 조회를 data 계층으로 | 하 |
| `lib/features/user/domain/report_model.dart` | **삭제** — 신고는 write-only 라 읽을 모델이 필요 없다 | 하 |
| `lib/features/user/.../profile_screen.dart` | `FirebaseAuth.instance.signOut()` → repository 경유 | 하 |
| `lib/features/user/.../profile_edit_screen.dart` | `updateDisplayName` → `updateUser` + profile UPDATE | 중 |
| `lib/features/user/domain/license.dart` | 고지 목록의 firebase 4종 → `supabase_flutter` (MIT) | 하 |

### 네이티브 · 설정 정리

| 대상 | 작업 |
| --- | --- |
| `android/settings.gradle:23` | `com.google.gms.google-services` 플러그인 선언 제거 |
| `android/app/build.gradle:4` | 같은 플러그인 apply 제거 |
| `android/app/google-services.json` | 삭제 |
| `ios/Runner/GoogleService-Info.plist` | 삭제 |
| `ios/Runner.xcodeproj/project.pbxproj` | `GoogleService-Info.plist` 참조 4곳 제거 (파일만 지우면 빌드 실패) |
| `firebase.json` | 삭제 |
| `ios/Podfile.lock` · `Pods/` | 의존성 교체 후 `pod install` 재실행 |
| `.env` | `FIREBASE_*_API_KEY` 3개 → `SUPABASE_URL` · `SUPABASE_PUBLISHABLE_KEY` |

> **`ios/Podfile.lock` 이 Flutter 전용인 것은 정상이다.** Flutter 3.44 는 iOS·macOS 에서
> **Swift Package Manager 를 기본 사용**하므로(`.flutter-plugins-dependencies` 의
> `swift_package_manager_enabled`), `Package.swift` 를 제공하는 플러그인은 CocoaPods 대상에서
> 제외된다. 현재 iOS 플러그인 4종(`app_links` · `package_info_plus` ·
> `shared_preferences_foundation` · `url_launcher_ios`)이 모두 여기 해당해
> `pod install` 결과는 `Flutter` 팟 하나뿐이다. Xcode 프로젝트에 대한 SPM 마이그레이션은
> 첫 `fvm flutter build ios` / `run` 때 툴이 자동으로 수행한다.

---

## 10. 단계별 실행 순서

각 단계를 개별 커밋(가능하면 PR)으로 끊는다.

> **중간 단계에서 `analyze` 0 issue 는 불가능하다.** Phase 1 에서 firebase 패키지를 걷어내는 순간
> 아직 손대지 않은 파일들이 한꺼번에 깨지기 때문이다. 대신 **에러 개수를 소진(burn-down)** 시키는
> 방식으로 관리한다. Phase 1 직후 기준선은 **20개 파일 · 85 issue** 이고, 이 목록이 곧 남은 작업 목록이다.
>
> | 단계 | 대상 | 소진 |
> | --- | --- | --- |
> | Phase 2 | `auth_repository`(21) · `app.dart`(4) · `profile_screen`(3) · `profile_edit_screen`(3) | −31 |
> | Phase 3 | `pagination_repository`(8) · `timestamp_converter`(6) · `pagination_model`(4) · 모델 4종(8) · `*.g.dart` 4종(4) | −30 |
> | Phase 4 | `board_repository`(9) · `chat_repository`(4) · `comment_repository`(4) | −17 |
> | Phase 5 | `report_repository`(4) · `splash_screen`(3) | −7 |
>
> Phase 5 를 마치면 0 이 되고, **그때 처음으로 앱이 빌드·실행된다.**
>
> **진행 현황**
>
> | 시점 | 예측 | 실제 |
> | --- | --- | --- |
> | Phase 2 완료 | 54 | **54** — 일치 |
> | Phase 3 완료 | 24 | **33** |
> | Phase 4 완료 | 7 | **7** — 일치 |
> | Phase 5 완료 | 0 | **0** — 일치 |
>
> Phase 3 이 예측보다 9 많았던 이유는 아래 Phase 3 항목 참고. (대상 파일 목록은 그대로였고,
> Phase 4 에서 그 9까지 함께 소진돼 예정된 7로 복귀했다)

### Phase 0 — Supabase 프로젝트 준비 *(코드 변경 없음)*

**1. 프로젝트 생성** — [supabase.com/dashboard](https://supabase.com/dashboard) → New project

| 항목 | 값 |
| --- | --- |
| Name | `ddai-community` |
| Database Password | 강한 비밀번호 생성 후 **비밀번호 관리자에 보관** (이후 조회 불가, 재설정만 가능) |
| Region | **Northeast Asia (Seoul)** — 없으면 Tokyo |
| Plan | Free |

프로비저닝에 1~2분 걸린다. 완료되면 URL 의 `<project-ref>` 를 기록해 둔다.

**2. 키 확인** — Settings → **API Keys**

| 키 | 용도 |
| --- | --- |
| Project URL (`https://<ref>.supabase.co`) | `.env` 의 `SUPABASE_URL` |
| **Publishable key** (`sb_publishable_...`) | `.env` 의 `SUPABASE_PUBLISHABLE_KEY` — 앱에 넣는 키 |
| Secret key (`sb_secret_...`) | 서버 전용. **앱·저장소 금지** |

레거시 `anon` / `service_role` JWT 키도 함께 표시되지만 2026년 말 폐지 예정이므로 신규 프로젝트는 publishable 키를 쓴다.

**3. 익명 로그인 활성화** — Authentication → Providers → Anonymous 토글
- 익명 가입은 기본적으로 IP 당 **시간당 30회** 제한이 걸려 있다. (Rate Limits 에서 조정 가능)
- **CAPTCHA 는 지금 켜지 않는다.** 이유와 적용 시점은 아래 참조.

> **결정 사항 — "Confirm email" 을 켤 것인가.**
> Authentication → Sign In / Providers → Email 의 **Confirm email** 은 신규 프로젝트에서 **기본 ON** 이다.
> (`GET /auth/v1/settings` 의 `mailer_autoconfirm: false` 로 확인 가능)
>
> | | Confirm email **OFF** | Confirm email **ON** |
> | --- | --- | --- |
> | 가입 직후 | 세션 발급 → 곧바로 홈 진입 | 세션 없음, 메일 인증 후에야 로그인 |
> | 기존 Firebase 동작 | **동일** | 다름 |
> | 이메일 중복 | `user_already_exists` → "이미 사용 중인 이메일입니다" 노출 | 계정 노출 방지를 위해 **성공처럼 응답** (중복 안내 불가) |
> | 추가 작업 | 없음 | 커스텀 SMTP · 인증 안내 화면 · 딥링크 |
>
> Free 플랜의 기본 메일러는 **시간당 2통** 제한이라 운영용이 아니다.
> 이 마이그레이션은 **동작 동일성**이 목표이므로 **OFF 를 권장**한다.
> ON 으로 갈 경우 위 "추가 작업"이 별도 단계로 필요하다.
> (코드는 두 경우 모두 동작한다 — 세션이 없으면 `emailNotConfirmed` 로 안내한다)

**4. 스키마 실행** — SQL Editor → New query → §1 DDL 전체 붙여넣고 Run

**5. RLS 정책 실행** — 같은 방식으로 §2 전체 실행

**6. Realtime 활성화** — Database → Publications → `supabase_realtime` 에서 `chat` 토글
(§1 마지막의 `alter publication` 문을 실행했다면 이미 켜져 있다)

**7. 검증**
- Table Editor 에서 테이블 7개와 RLS 배지(Enabled)가 모두 보이는지
- SQL Editor 에서 `select * from public.board;` — 대시보드는 secret 권한이라 조회된다
- 실제 차단 검증은 Phase 5 에서 앱으로 한다

**8. (선택) CLI 설치** — Phase 2 의 Edge Function 배포에 필요하다

```bash
brew install supabase/tap/supabase
supabase login
supabase link --project-ref <project-ref>
```

> **반드시 프로젝트 루트에서 실행한다.** `supabase link` 는 실행한 디렉터리에 `supabase/config.toml`
> 을 새로 만들어 버린다. 홈 디렉터리 등에서 실행하면 그쪽이 "링크된 프로젝트"가 되고, 이후
> `supabase functions deploy` 가 함수 파일이 없는 그 디렉터리를 올려서 다음 오류가 난다.
>
> ```
> unexpected deploy status 400: {"message":"Entrypoint path does not exist -
> /tmp/user_fn_<ref>_<uuid>_1/source/supabase/functions/delete-account/index.ts"}
> ```
>
> link 상태에 의존하지 말고 **`--project-ref` 를 매번 명시**하는 편이 안전하다.
> 잘못 만들어진 디렉터리(`~/supabase` 등)는 지워도 된다.

### Phase 1 — 의존성 · 초기화 교체 ✅ *(완료)*

- `pubspec.yaml`: firebase 4종 제거, `supabase_flutter: ^2.17.2` 추가 → 전이 의존성 13개 제거
- `bootstrap.dart` → `Supabase.initialize`
- `firebase_options.dart` · `firebase_env.dart` 삭제, `supabase_env.dart` 신설
- `license.dart` 고지 목록 갱신 (firebase 4종 → `supabase_flutter`)
- 네이티브 정리: gradle 플러그인 · `google-services.json` · `GoogleService-Info.plist`
  (+ pbxproj 참조) · `firebase.json` 삭제 후 `pod install`

**`anonKey` 가 아니라 `publishableKey` 를 쓴다.** `supabase_flutter` 2.17.2 에서 `anonKey` 는
이미 `@Deprecated` 라 그대로 쓰면 경고가 남는다.

```dart
await Supabase.initialize(
  url: supabaseUrl,
  publishableKey: supabasePublishableKey,
);
```

**검증** — 앱이 아직 빌드되지 않으므로(위 burn-down 표) 자격증명은 REST 로 직접 확인한다.

```bash
URL=$(grep '^SUPABASE_URL=' .env | cut -d= -f2- | tr -d "'\"")
KEY=$(grep '^SUPABASE_PUBLISHABLE_KEY=' .env | cut -d= -f2- | tr -d "'\"")

curl -s -o /dev/null -w "%{http_code}\n" "$URL/auth/v1/health" -H "apikey: $KEY"
curl -s "$URL/rest/v1/app_config?select=*" -H "apikey: $KEY" -H "Authorization: Bearer $KEY"
curl -s "$URL/rest/v1/board?select=id&limit=1" -H "apikey: $KEY" -H "Authorization: Bearer $KEY"
```

| 확인 | 기대값 | 의미 |
| --- | --- | --- |
| `auth/v1/health` | `200` | URL · publishable 키 유효 |
| `app_config` | `[{"key":"version_name",...}]` | 스플래시가 로그인 전에 읽어야 하는 anon 정책 정상 |
| `board` | `[]` | anon 에 SELECT 정책이 없어 0행 — RLS 정상 (403 이 아니라 빈 배열이 정상) |

### Phase 2 — 인증 ✅ *(완료)*

- `auth_repository.dart` 전면 재작성, `AuthExceptionCode` 매핑 확정 (§3)
- `core/data/supabase_client.dart` 신설 — 전역 `supabase` getter
  (`FirebaseFirestore.instance` 자리를 대신하며 Phase 3~5 의 모든 repository 가 쓴다)
- `app.dart` → `supabase.auth.onAuthStateChange` 구독
- `profile_screen` 로그아웃 · `profile_edit_screen` 닉네임 수정/탈퇴를 repository 경유로 정리
- Edge Function `supabase/functions/delete-account/index.ts` 작성 (§4)

`AuthResult.user` 의 타입이 SDK 의 `User` → 앱의 `UserModel` 로 바뀌었다.
표시 이름 규칙(익명 `익명xxxxxx` / 이메일 `user_metadata.user_name`)이
`AuthRepository.userModelFrom()` 한 곳에 모여 화면·리스너가 이를 공유한다.
덕분에 세 화면에서 `UserModel` 을 직접 조립하던 중복이 사라졌다.

**검증 — 앱이 아직 빌드되지 않으므로(burn-down 표) 각 경로를 REST 로 직접 확인했다.**

| 확인 | 결과 |
| --- | --- |
| 잘못된 비밀번호 로그인 | `error_code = invalid_credentials` — enum 매핑 확정 |
| 익명 로그인 (`POST /auth/v1/signup` 빈 본문) | `is_anonymous: true` + 세션 발급 |
| `handle_new_user` 트리거 | `profile.user_name = 익명357f40` — `DataUtils.setAnonymousName` 과 **일치** |
| 로그인 상태 `board` SELECT | `200` (RLS `to authenticated` 정상) |
| `profile` UPDATE (닉네임 수정 경로) | 성공 |
| `block_user` upsert → delete (차단 경로) | `201` → `204` |

**Edge Function 배포 완료 · 실동작 확인** — `delete-account` v1 `ACTIVE` (`verify_jwt: true`)

```bash
supabase functions deploy delete-account --project-ref <ref>
```

익명 계정의 JWT 로 실제 호출해 전 과정을 확인했다. (익명 유저는 비밀번호 검사를 건너뛴다)

| 단계 | 결과 |
| --- | --- |
| 호출 전 `profile` 행 | 존재 |
| `POST /functions/v1/delete-account` | `200` · `{"ok": true}` |
| 호출 후 `profile` 행 | 사라짐 — `auth.users` 삭제가 FK CASCADE 로 전파됨 |

런타임에 `SUPABASE_SERVICE_ROLE_KEY` 가 정상 주입되는 것도 이로써 확인됐다.

**남은 일** — 회원가입 → 로그아웃 → 로그인 → 닉네임 수정 → 탈퇴 **전 과정 실기기 테스트**.
앱이 빌드되는 Phase 5 이후에 수행한다. (이메일 계정의 비밀번호 재확인 경로는 그때 처음 실행된다)

### Phase 3 — 모델 · 페이지네이션 기반 ✅ *(완료)*

- 4개 모델에 `fieldRename: FieldRename.snake` + `@JsonKey(name: 'created_at')` 적용
- `core/converters/timestamp_converter.dart` **삭제** (디렉터리째 사라짐)
- `PaginationCursor` 신설, `PaginationModel.lastDocument` → `lastCursor`
- `pagination_repository.dart` 재작성 — keyset 커서, 차단 조회 로직 제거
- `session_provider.dart` 신설 → **`core → features` 역참조 해소**
- 목록 provider 3개의 mixin override 정리

**`core → features` 역참조가 사라졌다.** 기존에는 `pagination_provider` 가 차단 필터에 쓸
uid 때문에 `features/user` 의 `userMeProvider` 를 watch 했다. 이제 차단은 RLS 가 처리하지만,
**RLS 결과가 세션마다 다르므로 로그인 유저가 바뀌면 목록은 여전히 다시 만들어야 한다.**
그 트리거만 core 안의 `sessionUidProvider` 로 옮겨 의존 방향을 `features → core` 로 되돌렸다.

**검증** — `build_runner` 성공. 생성된 매핑이 의도대로다.

```dart
userName: json['user_name'] as String,
userUid:  json['user_uid']  as String,
date:     DateTime.parse(json['created_at'] as String),   // TimestampConverter 제거됨
commentList: (json['comment'] as List<dynamic>?)?...      // select('*, comment(*)') 대응
```

**커서 페이지네이션은 실제 DB 로 확인했다.** 게시글 5건을 넣되 2건은 `created_at` 을 같게 만들어
동률 구간이 페이지 경계에 걸리도록 했다. (테스트 계정은 `delete-account` 로 정리 → CASCADE 로 게시글도 삭제)

| 확인 | 결과 |
| --- | --- |
| `pageSize=2` 로 끝까지 페이징 | 3페이지 · 5건 |
| 중복 | 없음 |
| 누락 | 없음 |
| 동률 타이브레이커 `and(created_at.eq,id.lt)` | 2~3페이지 경계에서 **실제 실행**되어 정상 동작 |

> 값에 `.` 과 `:` 이 들어가므로 PostgREST 필터에서 타임스탬프를 **큰따옴표로 감싼다.**
> 또 `+00:00` 의 `+` 가 공백으로 해석될 여지를 없애려고 `toUtc().toIso8601String()`(`...Z`)을 쓴다.

**남은 issue 가 예측(24)보다 9 많은 33 인 이유** — 위 API 정리로 `board` · `chat` · `comment`
repository 가 `CollectionPath` 등 사라진 심볼을 더 참조하게 됐다. **대상 파일은 늘지 않았고**
(모두 Phase 4 재작성 대상) 파일당 컴파일 오류만 3개씩 늘었다.

### Phase 4 — 게시판 · 댓글 · 채팅 ✅ *(완료)*

- `board_repository` · `comment_repository` · `chat_repository` 재작성
- `getBoard()` 가 **조회 2회 → 1회**로 줄었다. FK 임베딩(`select('*, comment(*)')`)으로
  게시글과 댓글을 한 번에 가져온다.
- `CommentRepository` 는 `parentColumn: 'board_id'` 만 지정하면 목록 로직을 그대로 물려받는다.

**`deleteBoard()` 는 삭제된 행을 되받아 확인한다.**

```dart
final deletedRows =
    await supabase.from('board').delete().eq('id', searchId).select('id');

return deletedRows.isNotEmpty;
```

Firestore 는 권한이 없으면 예외를 던졌지만, PostgREST 는 RLS(`board_delete_own`)에 걸리면
**오류 없이 0행**을 지운다. 이 확인이 없으면 실패를 성공으로 보고하게 된다.

**검증 — `package:supabase` 로 실제 DB 에 붙여 전 경로를 확인했다.** (앱은 Phase 5 부터 빌드된다)

| 확인 | 결과 |
| --- | --- |
| `addBoard` + `addComment`×3 | 성공 |
| `getBoard` FK 임베딩 | 댓글 3건 · **오래된 순** 정렬 정확 |
| 댓글 페이지네이션 (`parentColumn`) | `limit=2` → 2건, 최신순 |
| 채팅 실시간 구독 → 전송 → 수신 | **성공** (구독 직후 1회 + 삽입 후 1회 emit) |
| `deleteBoard` | 삭제 1행 반환, 댓글 CASCADE 삭제 확인 |
| 테스트 데이터 | `delete-account` 로 전량 정리 |

> 실시간 수신이 되었다는 것은 Phase 0 의
> `alter publication supabase_realtime add table public.chat;` 이 실제로 적용됐다는 뜻이다.
> (누락되면 채팅이 **조용히** 멈추므로 확인이 필요했다)

**남은 일** — 무한 스크롤·당겨서 새로고침·2기기 채팅 같은 **UI 레벨 검증**은 Phase 5 이후 실기기에서.

### Phase 5 — 신고 · 차단 · 강제 업데이트 ✅ *(완료)*

- `report_repository` 재작성 (단순 insert)
- `report_model.dart` **삭제** — 신고는 RLS 상 write-only 라 읽을 모델이 필요 없다.
  다른 3개 repository 와 마찬가지로 파라미터에서 map 을 만들어 넣는다.
- `app_config_repository` 신설, `splash_screen` 이 이를 경유해 버전을 조회
- `.then().catchError()` → try/catch. **버전 문자열 파싱 실패**도 같은 종료 경로로 묶었다

**검증 — 앱이 처음으로 빌드·실행됐다.**

| 확인 | 결과 |
| --- | --- |
| `fvm flutter analyze` | **0 issue** |
| `fvm flutter build ios --no-codesign` | 성공 (SPM 통합 자동 수행) |
| `fvm flutter build apk --debug` | 성공 |
| iOS 시뮬레이터 실행 | 스플래시 → **로그인 화면 정상 도달** |
| `app_config` 조회 | 성공 (실패했다면 `exit(0)` 로 앱이 죽었을 것) |
| 강제 업데이트 다이얼로그 | 앱 버전을 임시로 낮춰 **실제로 뜨는 것 확인** (확인 후 원복) |

### Phase 6 — 문서 갱신 ✅ *(완료)*

- `CLAUDE.md` — 아키텍처 트리 · 페이지네이션 패턴 · 관례 · 주의사항 전면 교체.
  남긴 Firebase 언급은 **비교 목적 3곳**뿐이다. (전환 배경, `deleteBoard` 의 0행 함정,
  `whereNotIn` 10개 제한 해소)
- `README.md` — 스택 배지 · 기능 설명 · 구조 트리 · 데이터 모델 표(Firestore 컬렉션 → Postgres 테이블) ·
  `.env` 키 · 패키지 목록 · Edge Function 배포 · `app_config` 안내로 교체
- 이 문서를 "기록" 상태로 정리

두 문서 모두 `docs/supabase-migration.md` 를 **스키마 · RLS 의 단일 출처**로 참조한다.

### Phase 7 — CAPTCHA (출시 직전)

익명 로그인 남용을 막는 마지막 단계다. **Phase 0~6 동안에는 켜지 않는다.**

> **켜는 순간 인증이 전부 막힌다.** Supabase 의 Attack Protection CAPTCHA 는 회원가입 · 로그인 ·
> 익명 로그인 · 비밀번호 재설정 등 **모든 auth 엔드포인트**에 `captchaToken` 을 요구한다.
> 앱이 토큰을 실어 보내지 않으면 Phase 2 의 인증 작업과 테스트가 통째로 실패한다.

**1. 제공자 선택** — Supabase 는 hCaptcha 와 Cloudflare Turnstile 을 지원한다.
모바일 UX 와 Flutter 패키지 성숙도를 보면 **Turnstile** 이 낫다.

| 제공자 | Flutter 패키지 | 비고 |
| --- | --- | --- |
| Cloudflare Turnstile | `cloudflare_turnstile` (Android · iOS · macOS · Web · Windows) | 무료 · 무제한, 대부분 무마찰 통과 |
| hCaptcha | `hcaptcha_widget` 등 | 퍼즐 노출 빈도가 상대적으로 높음 |

둘 다 1st-party Flutter SDK 가 아니라 **WebView 기반 커뮤니티 패키지**다. 도입 전에 유지보수 상태를 확인한다.

**2. 키 발급** — Cloudflare 대시보드 → Turnstile → Add site

| 키 | 어디에 |
| --- | --- |
| **Site Key** (공개) | Flutter 앱의 위젯 초기화 |
| **Secret Key** (비공개) | Supabase → Authentication → Attack Protection → **Captcha secret** |

**3. Supabase 설정** — Attack Protection 에서 Enable Captcha protection → Provider 선택 → Secret Key 붙여넣기

**4. 앱 연동** — 위젯에서 받은 토큰을 모든 인증 호출에 전달한다.

```dart
final token = await getTurnstileToken();   // 위젯에서 획득

await supabase.auth.signInAnonymously(captchaToken: token);
await supabase.auth.signUp(email: email, password: password, captchaToken: token);
await supabase.auth.signInWithPassword(email: email, password: password, captchaToken: token);
```

**개발 중 우회** — Cloudflare 가 공개한 테스트 키를 쓰면 항상 통과한다. 연동 코드를 먼저 붙이고
실제 키로 바꾸는 순서를 권한다. (운영 키는 더미 토큰을 거부하므로 **반드시 쌍으로** 맞춰 쓴다)

| 용도 | 값 |
| --- | --- |
| Site Key — 항상 통과 (invisible) | `1x00000000000000000000BB` |
| Secret Key — 항상 통과 | `1x0000000000000000000000000000000AA` |
| Secret Key — 항상 실패 (실패 경로 테스트) | `2x0000000000000000000000000000000AA` |

---

---

## 별건 — 앱 버전 관리 정리 ✅ *(해결됨)*

강제 업데이트를 검증하다 찾은 **기존 문제**다. (마이그레이션 이전 `7d044bb` 에도 있었다)

### 증상

`pubspec.yaml` 을 바꿔도 iOS 앱 버전이 변하지 않았다. `Generated.xcconfig` 가 `1.4.1` 인데
빌드된 앱은 `1.5.0` 을 보고했다. (클린 빌드로 확인)

### 원인

`ios/Runner.xcodeproj/project.pbxproj` 에 버전이 **빌드 설정으로 하드코딩**돼 있었다.

```
FLUTTER_BUILD_NAME = 1.5.0;
FLUTTER_BUILD_NUMBER = 8;
MARKETING_VERSION = 1.5.0;
CURRENT_PROJECT_VERSION = 8;
```

`Info.plist` 는 `$(FLUTTER_BUILD_NAME)` 을 참조하고 Flutter 는 이 값을 `Generated.xcconfig` 에
pubspec 기준으로 써 넣지만, **프로젝트 빌드 설정이 xcconfig 를 이긴다.**
표준 Flutter iOS 템플릿에는 이 설정이 **아예 없다** — Xcode General 탭에서 버전을 고치면 생긴다.

git 이력을 보면 원인이 분명하다. `1.3.0`·`1.4.0`·`1.4.1` 까지는 `pubspec` 과 `pbxproj` 가 항상 같이
올라갔는데, 커밋 **`7192284 update: 1.5.0(8)`** 은 **`pbxproj` 만** 올리고 `pubspec` 을 빠뜨렸다.
그 결과 iOS 는 `1.5.0(8)`, Android 는 `pubspec` 기준 `1.4.1(7)` 로 **서로 다른 버전이 나갔다.**

Android 쪽도 `app/build.gradle` 이 `local.properties` 를 직접 파싱하고
**폴백을 `"1.5.0"` / `"8"` 로 하드코딩**해 두어 같은 위험이 있었다.
(`local.properties` 는 git 에 없으므로 새로 클론한 환경에서 폴백이 걸린다)

### 조치

`pubspec.yaml` 을 **단일 출처**로 만들었다.

| 파일 | 조치 |
| --- | --- |
| `pubspec.yaml` | `1.4.1+7` → **`1.5.0+8`** — iOS 가 실제로 내보내던 값에 맞춤 |
| `ios/.../project.pbxproj` | 위 4개 설정 **12줄 제거** (표준 템플릿 상태로 복귀) |
| `android/app/build.gradle` | `local.properties` 수동 파싱 + 하드코딩 폴백 제거 → `flutter.versionCode` / `flutter.versionName` |

`1.4.1+7` 이 아니라 `1.5.0+8` 로 맞춘 이유: iOS 가 이미 `1.5.0(8)` 로 배포돼 있어,
낮추면 스토어가 빌드 번호 역행으로 업로드를 거부한다.

`flutter.versionCode` / `versionName` 은 값이 없으면 `GradleException` 을 던진다.
조용히 틀린 버전으로 빌드되는 것보다 낫다.

### 검증

`pubspec` 을 구분 가능한 값(`9.9.9+99`)으로 바꿔 양쪽을 빌드해 확인한 뒤 원복했다.

| | 테스트 값 빌드 | 원복 후 |
| --- | --- | --- |
| Android APK | `versionCode='99' versionName='9.9.9'` | `versionCode='8' versionName='1.5.0'` |
| iOS `Info.plist` | `9.9.9` / `99` | `1.5.0` / `8` |
| `pubspec.yaml` | `9.9.9+99` | `1.5.0+8` |

> 앞으로 버전을 올릴 때는 **`pubspec.yaml` 한 줄만** 고친다.
> Xcode General 탭에서 버전을 고치면 `MARKETING_VERSION` 이 다시 기록되어 같은 문제가 재발한다.

> 현재 앱은 `1.5.0` 이므로 강제 업데이트를 걸려면
> `app_config.version_name` 을 **1.6.0 이상**으로 올려야 한다. (현재 값 `1.4.0`)

---

## 11. 리스크 · 주의사항

| 리스크 | 대응 |
| --- | --- |
| **RLS 미적용 테이블** — anon key 만으로 전체 데이터 노출 | Phase 0 에서 테이블마다 RLS 활성화 확인. 이후 새 테이블 추가 시에도 필수 |
| **`service_role` 키 유출** | 앱/`.env`/저장소에 절대 넣지 않는다. Edge Function 런타임에만 존재 |
| **익명 로그인 남용** — 무제한 계정 생성 | Supabase 대시보드에서 CAPTCHA(hCaptcha/Turnstile) 활성화 권장 |
| **`app_config` anon 정책 누락** | 스플래시 조회 실패 → `exit(0)` → 앱이 아예 안 뜸. Phase 0 체크리스트 필수 항목 |
| **Realtime 기본 비활성** | `alter publication supabase_realtime add table public.chat;` 누락 시 채팅이 조용히 멈춤 |
| **무료 티어 일시정지** | 프로젝트가 일정 기간 미사용이면 pause 된다. 운영 전환 시 유료 플랜 검토 |
| **`is_blocked()` 함수 호출 비용** | 행마다 평가된다. `block_user(blocker_uid)` 인덱스 필수. 규모가 커지면 `NOT EXISTS` 조인으로 재작성 |
| **Supabase 예외 코드 변동** | §3 매핑 표는 Phase 2 에서 실제 응답을 로깅해 확정 |

---

## 12. Phase 0 체크리스트

- [ ] 프로젝트 생성 · 리전 선택
- [ ] Anonymous sign-ins 활성화 (**CAPTCHA 는 켜지 않는다** — Phase 7)
- [ ] 테이블 7개 생성 (`profile` `board` `comment` `chat` `block_user` `report` `app_config`)
- [ ] `handle_new_user` 트리거 생성
- [ ] 인덱스 5개 생성
- [ ] **모든 테이블 RLS 활성화**
- [ ] `is_blocked()` 함수 + 정책 전체 적용
- [ ] `app_config` 에 `anon` SELECT 정책 확인
- [ ] `chat` 테이블 Realtime 활성화
- [ ] `app_config` 에 `version_name` 행 삽입
- [ ] Project URL · **publishable key** 를 `.env` 에 기록
- [ ] secret / `service_role` 키가 저장소 어디에도 없는지 확인
