import 'package:ddai_community/common/model/model_with_id.dart';
import 'package:ddai_community/common/model/pagination_model.dart';
import 'package:ddai_community/common/repository/pagination_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class PaginationProvider<T extends ModelWithId>
    extends StateNotifier<PaginationModel<T>> {
  final PaginationRepository<T> paginationRepository;
  final String userUid;
  final CollectionPath collectionPath;
  final CollectionPath? subCollectionPath;
  final String? collectionId;
  final bool isUsingStream;
  final int pageSize;

  PaginationProvider({
    required this.paginationRepository,
    required this.userUid,
    required this.collectionPath,
    this.subCollectionPath,
    this.collectionId,
    required this.isUsingStream,
    this.pageSize = 30,
  }) : super(
          PaginationModel<T>(
            items: [],
            hasMore: true,
            lastDocument: null,
          ),
        ) {
    if (isUsingStream) {
      streamData();
    }
  }

  Future<void> fetchData() async {
    if (state.isLoading || !state.hasMore) {
      return;
    }

    state = state.copyWith(
      isLoading: true,
    );

    final newData = await paginationRepository.fetchData(
      userUid: userUid,
      collectionPath: collectionPath,
      subCollectionPath: subCollectionPath,
      collectionId: collectionId,
      pageSize: pageSize,
      lastDocument: state.lastDocument,
    );

    state = state.copyWith(
      items: [...state.items, ...newData.items],
      isLoading: false,
      hasMore: newData.hasMore,
      lastDocument: newData.lastDocument,
    );
  }

  void refresh() {
    state = PaginationModel(
      items: [],
      hasMore: true,
      lastDocument: null,
    );

    fetchData();
  }

  void streamData() {
    paginationRepository
        .streamData(
      collectionPath: collectionPath,
    )
        .listen((newData) {
      if (!mounted) {
        return;
      }

      state = state.copyWith(
        items: newData,
      );
    });
  }
}
