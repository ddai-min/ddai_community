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
      padding: const EdgeInsets.all(16.0),
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
