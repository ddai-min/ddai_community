import 'package:ddai_community/features/board/presentation/providers/board_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// 게시글 좋아요 버튼. 하트와 개수를 함께 보여준다.
///
/// 상태는 [boardLikeProvider] 가 낙관적으로 갱신한다. 조회 중에는 0 으로 그리고
/// 값이 오면 바뀐다 — 스피너를 돌리면 글을 읽는 흐름이 끊긴다.
class BoardLikeButton extends ConsumerWidget {
  final String boardId;

  const BoardLikeButton({
    super.key,
    required this.boardId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final like = ref.watch(boardLikeProvider(boardId)).value;
    final isLiked = like?.isLiked ?? false;

    return Align(
      alignment: Alignment.centerLeft,
      child: TextButton.icon(
        onPressed: () {
          ref.read(boardLikeProvider(boardId).notifier).toggle();
        },
        style: TextButton.styleFrom(
          foregroundColor: isLiked ? Colors.red : Colors.grey[600],
        ),
        icon: Icon(
          isLiked ? Icons.favorite : Icons.favorite_border,
          size: 20.0,
        ),
        label: Text('${like?.count ?? 0}'),
      ),
    );
  }
}
