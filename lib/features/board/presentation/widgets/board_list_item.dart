import 'package:ddai_community/core/constants/colors.dart';
import 'package:ddai_community/core/utils/data_utils.dart';
import 'package:flutter/material.dart';

/// 게시판 목록의 게시글 한 줄.
///
/// 제목·내용을 한 줄로 말줄임 처리하고, 아래에 작성자와 작성 시각을 덧붙인다.
/// 작성자 이름은 작성 시점의 스냅샷이라 닉네임을 바꿔도 지난 글에는 반영되지 않는다.
class BoardListItem extends StatelessWidget {
  final String title;
  final String content;
  final String userName;
  final DateTime date;

  /// 댓글 수. 목록 조회에서만 실리므로 없을 수 있다.
  final int? commentCount;

  /// 좋아요 수. 목록 조회에서만 실리므로 없을 수 있다.
  final int? likeCount;

  final GestureTapCallback onTap;

  const BoardListItem({
    super.key,
    required this.title,
    required this.content,
    required this.userName,
    required this.date,
    required this.onTap,
    this.commentCount,
    this.likeCount,
  });

  @override
  Widget build(BuildContext context) {
    final metaTextStyle = TextStyle(
      fontSize: 12.0,
      color: Colors.grey[600],
    );

    return Card(
      elevation: 0,
      color: Colors.white,
      surfaceTintColor: primaryColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: ListTile(
        // 부제가 두 줄이라 기본 높이로는 모자란다.
        isThreeLine: true,
        // isThreeLine 은 화살표를 위쪽에 붙이므로 가운데로 되돌린다.
        titleAlignment: ListTileTitleAlignment.center,
        title: Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              content,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 6.0),
            Row(
              children: [
                // 긴 닉네임이 시각을 밀어내지 않도록 이름 쪽만 줄인다.
                Flexible(
                  child: Text(
                    userName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: metaTextStyle,
                  ),
                ),
                Text(
                  ' · ${DataUtils.formatRelativeDate(date)}',
                  style: metaTextStyle,
                ),
                // 하나도 없으면 굳이 0 을 그리지 않는다.
                if (commentCount != null && commentCount! > 0) ...[
                  const SizedBox(width: 8.0),
                  Icon(
                    Icons.chat_bubble_outline,
                    size: 12.0,
                    color: Colors.grey[600],
                  ),
                  const SizedBox(width: 3.0),
                  Text(
                    '$commentCount',
                    style: metaTextStyle,
                  ),
                ],
                if (likeCount != null && likeCount! > 0) ...[
                  const SizedBox(width: 8.0),
                  Icon(
                    Icons.favorite_border,
                    size: 12.0,
                    color: Colors.grey[600],
                  ),
                  const SizedBox(width: 3.0),
                  Text(
                    '$likeCount',
                    style: metaTextStyle,
                  ),
                ],
              ],
            ),
          ],
        ),
        trailing: const Icon(Icons.arrow_forward_ios),
        onTap: onTap,
      ),
    );
  }
}
