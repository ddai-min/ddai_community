import 'package:ddai_community/core/data/supabase_client.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'session_provider.g.dart';

/// 현재 세션의 유저 uid. 비로그인이면 빈 문자열.
///
/// 목록 조회 결과는 RLS 때문에 **세션마다 달라진다**(차단한 유저의 글이 빠지는 등).
/// 그래서 로그인 유저가 바뀌면 목록을 처음부터 다시 만들어야 하고,
/// [PaginationMixin.initialState] 가 이 provider 를 watch 해 그 시점을 잡는다.
///
/// `features/user` 의 `userMeProvider` 도 같은 정보를 갖고 있지만, core 가 feature 를
/// 참조하지 않도록(의존 방향은 `features → core`) core 안에 따로 둔다.
@Riverpod(keepAlive: true)
class SessionUid extends _$SessionUid {
  @override
  String build() {
    final subscription = supabase.auth.onAuthStateChange.listen((authState) {
      state = authState.session?.user.id ?? '';
    });

    // provider 가 폐기될 때 구독을 해제한다.
    ref.onDispose(subscription.cancel);

    return supabase.auth.currentUser?.id ?? '';
  }
}
