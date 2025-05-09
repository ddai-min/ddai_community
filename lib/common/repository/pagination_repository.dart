import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ddai_community/common/model/model_with_id.dart';
import 'package:ddai_community/common/model/pagination_model.dart';
import 'package:ddai_community/main.dart';

enum CollectionPath {
  board,
  comment,
  chat,
}

class PaginationRepository<T extends ModelWithId> {
  final CollectionPath collectionPath;
  final T Function(Map<String, dynamic> data) fromJson;

  PaginationRepository({
    required this.collectionPath,
    required this.fromJson,
  });

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

      final blockSnapshot = await firestore
          .collection('user')
          .doc(userUid)
          .collection('blockUser')
          .get();

      final blockUserList = blockSnapshot.docs.map((e) => e.id).toList();

      if (subCollectionPath == null || collectionId == null) {
        query = firestore
            .collection(collectionPath.name)
            .orderBy(
              'date',
              descending: true,
            )
            .limit(pageSize);
      } else {
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

      if (blockUserList.isNotEmpty) {
        query = query.where(
          'userUid',
          whereNotIn: blockUserList,
        );
      }

      if (lastDocument != null) {
        query = query.startAfterDocument(lastDocument);
      }

      final querySnapshot = await query.get();
      final docs = querySnapshot.docs;

      final items =
          docs.map((e) => fromJson(e.data() as Map<String, dynamic>)).toList();
      final newLastDocument = docs.isNotEmpty ? docs.last : null;
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
