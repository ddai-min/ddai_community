import 'package:ddai_community/features/board/domain/comment_model.dart';
import 'package:flutter/material.dart';

/// 게시글 상세 화면의 댓글 한 줄.
///
/// [isMine] 이면 삭제 버튼을 함께 보여준다. 화면에서 감추는 것은 안내일 뿐이고,
/// 실제 권한은 RLS(`comment_delete_own`)가 서버에서 강제한다.
class CommentListItem extends StatelessWidget {
  final CommentModel commentModel;
  final bool isMine;
  final VoidCallback onDelete;

  const CommentListItem({
    super.key,
    required this.commentModel,
    required this.isMine,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      // 가로 여백은 [DefaultLayout.contentPadding] 이 준다. 여기서 또 주면 본문과 어긋난다.
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  commentModel.userName,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (isMine)
                TextButton(
                  onPressed: onDelete,
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.grey[600],
                    visualDensity: VisualDensity.compact,
                    textStyle: const TextStyle(fontSize: 13),
                  ),
                  child: const Text('삭제'),
                ),
            ],
          ),
          Text(commentModel.content),
        ],
      ),
    );
  }
}
