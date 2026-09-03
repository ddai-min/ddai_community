import 'package:ddai_community/features/board/domain/comment_model.dart';
import 'package:flutter/material.dart';

/// 게시글 상세 화면의 댓글 한 줄.
class CommentListItem extends StatelessWidget {
  final CommentModel commentModel;

  const CommentListItem({
    super.key,
    required this.commentModel,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      // 가로 여백은 [DefaultLayout.contentPadding] 이 준다. 여기서 또 주면 본문과 어긋난다.
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            commentModel.userName,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(commentModel.content),
        ],
      ),
    );
  }
}
