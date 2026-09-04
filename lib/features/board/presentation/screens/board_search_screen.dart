import 'package:ddai_community/core/widgets/default_circular_progress_indicator.dart';
import 'package:ddai_community/core/widgets/default_layout.dart';
import 'package:ddai_community/core/widgets/default_list_placeholder.dart';
import 'package:ddai_community/core/widgets/default_text_field.dart';
import 'package:ddai_community/features/board/presentation/providers/board_provider.dart';
import 'package:ddai_community/features/board/presentation/screens/board_detail_screen.dart';
import 'package:ddai_community/features/board/presentation/widgets/board_list_item.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// 게시글 검색 화면.
///
/// 제목과 내용을 함께 훑는다. (훑을 컬럼은 `BoardRepository.searchColumns` 가 정한다)
/// 입력할 때마다 조회하지 않고 **제출(엔터·검색 버튼) 시점**에만 조회한다.
/// 커서 페이지네이션이라 매 글자마다 새 목록을 만들면 요청이 금방 쌓인다.
class BoardSearchScreen extends ConsumerStatefulWidget {
  static String get routeName => 'board_search';

  const BoardSearchScreen({super.key});

  @override
  ConsumerState<BoardSearchScreen> createState() => _BoardSearchScreenState();
}

class _BoardSearchScreenState extends ConsumerState<BoardSearchScreen> {
  final TextEditingController keywordTextController = TextEditingController();

  /// 제출된 검색어. 비어 있으면 아직 검색 전이다.
  String keyword = '';

  @override
  void dispose() {
    keywordTextController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultLayout(
      title: '게시글 검색',
      // 결과 목록이 스스로 스크롤한다.
      isScrollable: false,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          DefaultTextField(
            controller: keywordTextController,
            hintText: '제목 · 내용 검색',
            padding: 0,
            textInputAction: TextInputAction.search,
            onFieldSubmitted: _search,
          ),
          const SizedBox(height: 16.0),
          Expanded(
            child: keyword.isEmpty
                ? const DefaultListPlaceholder(
                    message: '검색어를 입력해주세요.',
                  )
                // 검색어가 바뀌면 목록을 처음부터 다시 만든다.
                : _SearchResult(
                    key: ValueKey(keyword),
                    keyword: keyword,
                  ),
          ),
        ],
      ),
    );
  }

  void _search(String value) {
    setState(() {
      keyword = value.trim();
    });
  }
}

/// 검색 결과 목록. 검색어 하나에 대응한다.
class _SearchResult extends ConsumerStatefulWidget {
  final String keyword;

  const _SearchResult({
    super.key,
    required this.keyword,
  });

  @override
  ConsumerState<_SearchResult> createState() => _SearchResultState();
}

class _SearchResultState extends ConsumerState<_SearchResult> {
  final ScrollController scrollController = ScrollController();

  @override
  void initState() {
    super.initState();

    Future.microtask(() {
      ref.read(boardSearchListProvider(widget.keyword).notifier).fetchData();
    });

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
    final searchList = ref.watch(boardSearchListProvider(widget.keyword));

    if (searchList.items.isEmpty) {
      if (searchList.isLoading) {
        return const Center(
          child: DefaultCircularProgressIndicator(),
        );
      }

      return DefaultListPlaceholder(
        message: searchList.hasError
            ? '검색에 실패했습니다.\n네트워크 상태를 확인해주세요.'
            : '검색 결과가 없습니다.',
        onRetry: searchList.hasError
            ? () {
                ref
                    .read(boardSearchListProvider(widget.keyword).notifier)
                    .refresh();
              }
            : null,
      );
    }

    return ListView.builder(
      controller: scrollController,
      clipBehavior: Clip.none,
      itemCount: searchList.items.length + (searchList.hasMore ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == searchList.items.length) {
          return const Center(
            child: DefaultCircularProgressIndicator(),
          );
        }

        final board = searchList.items[index];

        return BoardListItem(
          title: board.title,
          content: board.content,
          userName: board.userName,
          date: board.date,
          commentCount: board.commentCount,
          likeCount: board.likeCount,
          onTap: () {
            context.pushNamed(
              BoardDetailScreen.routeName,
              pathParameters: {
                'id': board.id,
              },
            );
          },
        );
      },
    );
  }

  /// 스크롤이 목록 끝(200px 이내)에 도달하면 다음 페이지를 불러온다.
  void _listener() {
    if (scrollController.offset >
        scrollController.position.maxScrollExtent - 200) {
      ref.read(boardSearchListProvider(widget.keyword).notifier).fetchData();
    }
  }
}
