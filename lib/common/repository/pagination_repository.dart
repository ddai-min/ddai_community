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
    required CollectionPath collectionPath,
    int pageSize = 30,
    DocumentSnapshot? lastDocument,
  }) async {
    try {
      Query query = firestore
          .collection(collectionPath.name)
          .orderBy(
            'date',
            descending: true,
          )
          .limit(pageSize);

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
