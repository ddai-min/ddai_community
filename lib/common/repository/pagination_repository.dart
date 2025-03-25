import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ddai_community/common/model/pagination_model.dart';
import 'package:ddai_community/main.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

enum CollectionPath {
  board,
  comment,
  chat,
}

class PaginationRepository extends StateNotifier<PaginationModel> {
  PaginationRepository()
      : super(
          PaginationModel(
            items: [],
          ),
        );

  Future<void> fetchData({
    required CollectionPath collectionPath,
    int pageSize = 30,
  }) async {
    if (state.isLoading || !state.hasMore) return;

    state = state.copyWith(
      isLoading: true,
    );

    try {
      Query query = firestore
          .collection(collectionPath.name)
          .orderBy('date', descending: true)
          .limit(pageSize);

      if (state.lastDocument != null) {
        query = query.startAfterDocument(state.lastDocument!);
      }

      QuerySnapshot querySnapshot = await query.get();
      List<DocumentSnapshot> newItems = querySnapshot.docs;

      state = state.copyWith(
        items: [...state.items, ...newItems],
        isLoading: false,
        hasMore: newItems.length == pageSize,
        lastDocument: newItems.isNotEmpty ? newItems.last : state.lastDocument,
      );
    } catch (error) {
      logger.e(error);
    }
  }

  Future<void> refreshData({
    required CollectionPath collectionPath,
    int pageSize = 30,
  }) async {
    state = state.copyWith(
      items: [],
      isLoading: true,
      hasMore: true,
      lastDocument: null,
    );

    try {
      QuerySnapshot querySnapshot = await firestore
          .collection(collectionPath.name)
          .orderBy('date', descending: true)
          .limit(pageSize)
          .get();

      List<DocumentSnapshot> newItems = querySnapshot.docs;

      state = state.copyWith(
        items: newItems,
        isLoading: false,
        hasMore: newItems.length == pageSize,
        lastDocument: newItems.isNotEmpty ? newItems.last : null,
      );
    } catch (error) {
      logger.e(error);

      state = state.copyWith(
        isLoading: false,
      );
    }
  }
}
