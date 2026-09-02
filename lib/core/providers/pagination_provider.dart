import 'package:ddai_community/core/data/pagination_repository.dart';
import 'package:ddai_community/core/models/model_with_id.dart';
import 'package:ddai_community/core/models/pagination_model.dart';
import 'package:ddai_community/core/providers/session_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

/// 페이지네이션 목록 Notifier의 공통 로직 mixin.
///
/// `@riverpod` 로 생성된 목록 Notifier(`BoardList`/`ChatList`/`CommentList`)에
/// `with` 로 섞어 사용한다. 각 Notifier는 [paginationRepository] 만 제공하면
/// [fetchData]/[refresh]/[subscribeStream] 을 그대로 쓸 수 있다.
/// (어느 테이블을 볼지는 repository 자신이 알고 있다)
///
/// (codegen 은 제네릭 Notifier 를 지원하지 않으므로, 공통 로직만 이 제네릭 mixin 으로
///  분리하고 구체 Notifier 는 도메인별로 둔다. mixin 은 생성된 base `$Notifier` 에 붙는다.)
mixin PaginationMixin<T extends ModelWithId> on $Notifier<PaginationModel<T>> {
  /// build 시점에 조회할 repository. (구체 Notifier 에서 `ref.read` 로 제공)
  PaginationRepository<T> get paginationRepository;

  /// 부모 행 id. 댓글처럼 특정 게시글에 속한 목록일 때만 지정한다.
  /// (어떤 컬럼으로 좁힐지는 repository 의 `parentColumn` 이 안다)
  String? get parentId => null;

  int get pageSize => 30;

  /// `build()` 에서 반환할 초기 상태.
  ///
  /// 로그인 유저가 바뀌면 목록을 다시 만들도록 [sessionUidProvider] 를 watch 한다.
  /// (RLS 때문에 조회 결과 자체가 세션마다 다르다)
  PaginationModel<T> initialState() {
    ref.watch(sessionUidProvider);

    return PaginationModel<T>(
      items: [],
      hasMore: true,
      lastCursor: null,
    );
  }

  /// 실시간 스트림을 구독해 새 데이터가 도착하면 목록을 교체한다. (`build()` 에서 호출)
  void subscribeStream() {
    final subscription = paginationRepository.streamData().listen((newData) {
      state = state.copyWith(items: newData);
    });

    // provider 가 재빌드/폐기될 때 구독을 해제한다.
    ref.onDispose(subscription.cancel);
  }

  /// 다음 페이지를 불러와 기존 목록 뒤에 이어 붙인다.
  Future<void> fetchData() async {
    // 이미 로딩 중이거나 마지막 페이지면 중복 요청을 막는다.
    if (state.isLoading || !state.hasMore) {
      return;
    }

    state = state.copyWith(isLoading: true);

    final newData = await paginationRepository.fetchData(
      parentId: parentId,
      pageSize: pageSize,
      cursor: state.lastCursor,
    );

    state = state.copyWith(
      items: [...state.items, ...newData.items], // 기존 목록에 이어 붙인다.
      isLoading: false,
      hasMore: newData.hasMore,
      lastCursor: newData.lastCursor,
    );
  }

  /// 목록을 초기 상태로 되돌린 뒤 첫 페이지를 다시 조회한다.
  ///
  /// 당겨서 새로고침, 글/댓글 작성·삭제 후 목록 갱신 등에 사용한다.
  void refresh() {
    state = PaginationModel(
      items: [],
      hasMore: true,
      lastCursor: null,
    );

    fetchData();
  }
}
