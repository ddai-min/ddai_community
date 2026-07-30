import 'package:ddai_community/common/model/model_with_id.dart';
import 'package:ddai_community/common/model/pagination_model.dart';
import 'package:ddai_community/common/repository/pagination_repository.dart';
import 'package:ddai_community/user/provider/user_me_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

/// 페이지네이션 목록 Notifier의 공통 로직 mixin.
///
/// `@riverpod` 로 생성된 목록 Notifier(`BoardList`/`ChatList`/`CommentList`)에
/// `with` 로 섞어 사용한다. 각 Notifier는 [paginationRepository]·[collectionPath]
/// 등 설정만 제공하면 [fetchData]/[refresh]/[subscribeStream] 을 그대로 쓸 수 있다.
///
/// (codegen 은 제네릭 Notifier 를 지원하지 않으므로, 공통 로직만 이 제네릭 mixin 으로
///  분리하고 구체 Notifier 는 도메인별로 둔다. mixin 은 생성된 base `$Notifier` 에 붙는다.)
mixin PaginationMixin<T extends ModelWithId> on $Notifier<PaginationModel<T>> {
  /// build 시점에 조회할 repository. (구체 Notifier 에서 `ref.read` 로 제공)
  PaginationRepository<T> get paginationRepository;

  /// 조회 대상 최상위 컬렉션.
  CollectionPath get collectionPath;

  /// 하위 컬렉션 경로. 댓글처럼 하위 컬렉션을 조회할 때만 지정한다.
  CollectionPath? get subCollectionPath => null;

  /// 하위 컬렉션 조회 시 상위 문서 id. (예: 게시글 id)
  String? get collectionId => null;

  int get pageSize => 30;

  /// `build()` 에서 반환할 초기 상태.
  ///
  /// 로그인 유저가 바뀌면 목록을 다시 만들도록 [userMeProvider] 를 watch 한다.
  /// (차단 필터가 유저별로 다르기 때문)
  PaginationModel<T> initialState() {
    ref.watch(userMeProvider);

    return PaginationModel<T>(
      items: [],
      hasMore: true,
      lastDocument: null,
    );
  }

  /// 실시간 스트림을 구독해 새 데이터가 도착하면 목록을 교체한다. (`build()` 에서 호출)
  void subscribeStream() {
    final subscription = paginationRepository
        .streamData(collectionPath: collectionPath)
        .listen((newData) {
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
      userUid: ref.read(userMeProvider).id,
      collectionPath: collectionPath,
      subCollectionPath: subCollectionPath,
      collectionId: collectionId,
      pageSize: pageSize,
      lastDocument: state.lastDocument,
    );

    state = state.copyWith(
      items: [...state.items, ...newData.items], // 기존 목록에 이어 붙인다.
      isLoading: false,
      hasMore: newData.hasMore,
      lastDocument: newData.lastDocument,
    );
  }

  /// 목록을 초기 상태로 되돌린 뒤 첫 페이지를 다시 조회한다.
  ///
  /// 당겨서 새로고침, 글/댓글 작성·삭제 후 목록 갱신 등에 사용한다.
  void refresh() {
    state = PaginationModel(
      items: [],
      hasMore: true,
      lastDocument: null,
    );

    fetchData();
  }
}
