import 'package:ddai_community/common/model/pagination_model.dart';
import 'package:ddai_community/common/repository/pagination_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class PaginationProvider<T> extends StateNotifier<PaginationModel<T>> {
  final PaginationRepository<T> paginationRepository;
  final CollectionPath collectionPath;
  final int pageSize;

  PaginationProvider({
    required this.paginationRepository,
    required this.collectionPath,
    this.pageSize = 30,
  }) : super(
          PaginationModel<T>(
            items: [],
            hasMore: true,
            lastDocument: null,
          ),
        );

  Future<void> fetchData() async {
    if (state.isLoading || !state.hasMore) {
      return;
    }

    state = state.copyWith(
      isLoading: true,
    );

    final newData = await paginationRepository.fetchData(
      collectionPath: collectionPath,
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
}
