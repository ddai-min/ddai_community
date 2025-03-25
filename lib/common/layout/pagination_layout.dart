import 'package:ddai_community/common/component/default_circular_progress_indicator.dart';
import 'package:ddai_community/common/const/colors.dart';
import 'package:ddai_community/common/provider/pagination_provider.dart';
import 'package:ddai_community/common/repository/pagination_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

typedef PaginationWidgetBuilder<T> = Widget Function(
  BuildContext context,
  int index,
  T model,
);

class PaginationLayout extends ConsumerStatefulWidget {
  final CollectionPath collectionPath;
  final PaginationWidgetBuilder itemBuilder;

  const PaginationLayout({
    super.key,
    required this.collectionPath,
    required this.itemBuilder,
  });

  @override
  ConsumerState<PaginationLayout> createState() => _PaginationLayoutState();
}

class _PaginationLayoutState extends ConsumerState<PaginationLayout> {
  final ScrollController scrollController = ScrollController();

  @override
  void initState() {
    super.initState();

    scrollController.addListener(_listener);
  }

  @override
  void dispose() {
    scrollController.removeListener(_listener);
    scrollController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final paginationState = ref.watch(paginationProvider);
    final paginationNotifier = ref.read(paginationProvider.notifier);

    return RefreshIndicator(
      color: primaryColor,
      onRefresh: () async {
        await paginationNotifier.refreshData(
          collectionPath: widget.collectionPath,
        );
      },
      child: ListView.builder(
        controller: scrollController,
        itemCount: paginationState.items.length + 1,
        itemBuilder: (context, index) {
          if (index == paginationState.items.length) {
            return paginationState.hasMore
                ? const Center(
                    child: DefaultCircularProgressIndicator(),
                  )
                : const SizedBox();
          }

          final item = paginationState.items[index];

          return widget.itemBuilder(
            context,
            index,
            item,
          );
        },
      ),
    );
  }

  void _listener() {
    if (scrollController.offset >
        scrollController.position.maxScrollExtent - 200) {
      ref.read(paginationProvider.notifier).fetchData(
            collectionPath: widget.collectionPath,
          );
    }
  }
}
