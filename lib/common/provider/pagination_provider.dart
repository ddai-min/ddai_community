import 'package:ddai_community/common/model/model_with_id.dart';
import 'package:ddai_community/common/model/pagination_model.dart';
import 'package:ddai_community/common/repository/pagination_repository.dart';
import 'package:ddai_community/user/provider/user_me_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// 페이지네이션 목록 상태([PaginationModel])를 관리하는 제네릭 Notifier 베이스.
///
/// 게시판·채팅·댓글 목록 Notifier가 이 클래스를 상속해 컬렉션 설정만 지정하면
/// 공통 조회 로직(다음 페이지 로드·새로고침·실시간 스트림)을 그대로 사용한다.
/// [isUsingStream] 이 true 면 build 시 실시간 스트림을 구독하고(채팅),
/// false 면 [fetchData] 호출 시마다 다음 페이지를 이어서 불러온다(게시판/댓글).
abstract class PaginationNotifier<T extends ModelWithId>
    extends Notifier<PaginationModel<T>> {
  late final PaginationRepository<T> _repository;

  /// build 시점에 사용할 repository 를 반환한다. (하위 클래스에서 ref 로 조회)
  PaginationRepository<T> readRepository();

  /// 조회 대상 최상위 컬렉션.
  CollectionPath get collectionPath;

  /// 하위 컬렉션 경로. 댓글처럼 하위 컬렉션을 조회할 때만 지정한다.
  CollectionPath? get subCollectionPath => null;

  /// 하위 컬렉션 조회 시 상위 문서 id. (예: 게시글 id)
  String? get collectionId => null;

  /// 실시간 스트림 구독 여부. true 면 채팅처럼 실시간으로 동기화한다.
  bool get isUsingStream => false;

  int get pageSize => 30;

  @override
  PaginationModel<T> build() {
    _repository = readRepository();

    // 로그인 유저가 바뀌면 목록을 다시 만든다. (차단 필터가 유저별로 다르기 때문)
    ref.watch(userMeProvider);

    if (isUsingStream) {
      _subscribeStream();
    }

    return PaginationModel<T>(
      items: [],
      hasMore: true,
      lastDocument: null,
    );
  }

  /// 다음 페이지를 불러와 기존 목록 뒤에 이어 붙인다.
  Future<void> fetchData() async {
    // 이미 로딩 중이거나 마지막 페이지면 중복 요청을 막는다.
    if (state.isLoading || !state.hasMore) {
      return;
    }

    state = state.copyWith(isLoading: true);

    final newData = await _repository.fetchData(
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

  /// 실시간 스트림을 구독해 새 데이터가 도착하면 목록을 교체한다.
  void _subscribeStream() {
    final subscription = _repository
        .streamData(collectionPath: collectionPath)
        .listen((newData) {
      state = state.copyWith(items: newData);
    });

    // provider 가 재빌드/폐기될 때 구독을 해제한다.
    ref.onDispose(subscription.cancel);
  }
}
