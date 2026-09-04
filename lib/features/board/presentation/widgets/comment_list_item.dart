import 'package:ddai_community/features/board/domain/comment_model.dart';
import 'package:flutter/material.dart';

/// 게시글 상세 화면의 댓글 한 줄.
///
/// 오른쪽 메뉴 버튼은 항상 보이고, 무엇이 뜰지는 호출부가 정한다.
/// (내 댓글이면 삭제, 남의 댓글이면 신고·차단)
/// 실제 권한은 RLS 가 서버에서 강제하므로 화면의 구분은 안내일 뿐이다.
class CommentListItem extends StatelessWidget {
  final CommentModel commentModel;
  final VoidCallback onMenuPressed;

  const CommentListItem({
    super.key,
    required this.commentModel,
    required this.onMenuPressed,
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
              IconButton(
                onPressed: onMenuPressed,
                visualDensity: VisualDensity.compact,
                iconSize: 20.0,
                color: Colors.grey[600],
                icon: const Icon(Icons.more_vert),
              ),
            ],
          ),
          Text(commentModel.content),
        ],
      ),
    );
  }
}
