import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ddai_community/common/model/model_with_id.dart';
import 'package:ddai_community/common/model/pagination_model.dart';
import 'package:ddai_community/main.dart';

/// Firestore 최상위 컬렉션 이름 모음.
///
/// enum 의 `name`(`board`/`comment`/`chat`)이 실제 컬렉션 경로 문자열로 사용된다.
enum CollectionPath {
  board,
  comment,
  chat,
}

/// 목록 조회 로직을 공통화한 제네릭 Firestore repository.
///
/// 게시판/채팅 목록과 게시글 하위 댓글 목록이 모두 이 클래스를 통해
/// 동일한 방식(커서 기반 페이지네이션 + 차단 유저 필터링)으로 조회된다.
/// 각 도메인 repository([BoardRepository] 등)는 이 클래스를 상속해
/// [collectionPath] 와 [fromJson] 만 지정한다.
class PaginationRepository<T extends ModelWithId> {
  /// 조회 대상 컬렉션.
  final CollectionPath collectionPath;

  /// Firestore 문서(Map)를 모델 [T] 로 변환하는 함수.
  final T Function(Map<String, dynamic> data) fromJson;

  PaginationRepository({
    required this.collectionPath,
    required this.fromJson,
  });

  /// 한 페이지 분량의 문서를 조회한다.
  ///
  /// - 현재 유저가 차단한 유저(`user/{userUid}/blockUser`)가 작성한 글은 제외한다.
  /// - [subCollectionPath] 와 [collectionId] 가 함께 주어지면 하위 컬렉션
  ///   (예: `board/{collectionId}/comment`)을 조회한다.
  /// - [lastDocument](직전 페이지의 마지막 문서)를 커서로 사용해 이어서 조회한다.
  /// - 오류가 발생하면 빈 목록을 반환해 UI 크래시를 방지한다.
  Future<PaginationModel<T>> fetchData({
    required String userUid,
    required CollectionPath collectionPath,
    CollectionPath? subCollectionPath,
    String? collectionId,
    int pageSize = 30,
    DocumentSnapshot? lastDocument,
  }) async {
    try {
      Query query;
      FirebaseFirestore firestore = FirebaseFirestore.instance;

      // 현재 유저가 차단한 유저 목록을 먼저 조회한다.
      final blockSnapshot = await firestore
          .collection('user')
          .doc(userUid)
          .collection('blockUser')
          .get();

      final blockUserList = blockSnapshot.docs.map((e) => e.id).toList();

      if (subCollectionPath == null || collectionId == null) {
        // 최상위 컬렉션(board/chat) 조회. 최신순(date 내림차순)으로 정렬한다.
        query = firestore
            .collection(collectionPath.name)
            .orderBy(
              'date',
              descending: true,
            )
            .limit(pageSize);
      } else {
        // 하위 컬렉션(board/{collectionId}/comment) 조회.
        query = firestore
            .collection(collectionPath.name)
            .doc(collectionId)
            .collection(subCollectionPath.name)
            .orderBy(
              'date',
              descending: true,
            )
            .limit(pageSize);
      }

      // 차단한 유저가 작성한 문서를 결과에서 제외한다.
      if (blockUserList.isNotEmpty) {
        query = query.where(
          'userUid',
          whereNotIn: blockUserList,
        );
      }

      // 커서가 있으면 직전 페이지의 마지막 문서 다음부터 이어서 조회한다.
      if (lastDocument != null) {
        query = query.startAfterDocument(lastDocument);
      }

      final querySnapshot = await query.get();
      final docs = querySnapshot.docs;

      final items =
          docs.map((e) => fromJson(e.data() as Map<String, dynamic>)).toList();
      final newLastDocument = docs.isNotEmpty ? docs.last : null;
      // 조회 개수가 요청한 pageSize 와 같으면 다음 페이지가 더 있다고 판단한다.
      final hasMore = docs.length == pageSize;

      return PaginationModel<T>(
        items: items,
        hasMore: hasMore,
        lastDocument: newLastDocument,
      );
    } catch (error) {
      logger.e(error);

      return PaginationModel(
        items: [],
      );
    }
  }

  /// 컬렉션을 실시간 구독하는 스트림을 반환한다. (채팅에서 사용)
  ///
  /// 커서 페이지네이션 없이 최신 [pageSize] 개를 최신순으로 지속 수신한다.
  Stream<List<T>> streamData({
    required CollectionPath collectionPath,
    int pageSize = 100,
  }) {
    FirebaseFirestore firestore = FirebaseFirestore.instance;

    return firestore
        .collection(collectionPath.name)
        .orderBy(
          'date',
          descending: true,
        )
        .limit(pageSize)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map(
                (e) => fromJson(
                  e.data(),
                ),
              )
              .toList(),
        );
  }
}
