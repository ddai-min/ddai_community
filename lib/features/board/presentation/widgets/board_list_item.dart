import 'package:ddai_community/core/constants/colors.dart';
import 'package:ddai_community/core/utils/data_utils.dart';
import 'package:flutter/material.dart';

/// 게시판 목록의 게시글 한 줄.
///
/// 제목·내용을 한 줄로 말줄임 처리하고, 아래에 작성자와 작성 시각을 덧붙인다.
/// 좋아요·댓글 수는 제목·내용 오른쪽(화살표 앞)에 세로로 쌓는다.
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

    // 하나도 없으면 굳이 0 을 그리지 않는다.
    final counts = <Widget>[
      if (likeCount != null && likeCount! > 0)
        _CountLabel(
          icon: Icons.favorite_border,
          count: likeCount!,
          textStyle: metaTextStyle.copyWith(fontSize: 14),
        ),
      if (commentCount != null && commentCount! > 0)
        _CountLabel(
          icon: Icons.chat_bubble_outline,
          count: commentCount!,
          textStyle: metaTextStyle.copyWith(fontSize: 14),
        ),
    ];

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
              ],
            ),
          ],
        ),
        // 개수를 화살표 앞에 두는 자리. 본문이 쓸 폭을 뺏지 않도록 최소 폭만 차지한다.
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (counts.isNotEmpty) ...[
              Column(
                mainAxisSize: MainAxisSize.min,
                // 자릿수가 달라도 아이콘은 세로로 나란히 보이도록 왼쪽 정렬한다.
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: 4.0,
                children: counts,
              ),
              const SizedBox(width: 8.0),
            ],
            const Icon(Icons.arrow_forward_ios),
          ],
        ),
        onTap: onTap,
      ),
    );
  }
}

/// 아이콘과 개수를 한 줄로 붙인 라벨. 좋아요·댓글 수가 같은 모양이라 공유한다.
class _CountLabel extends StatelessWidget {
  final IconData icon;
  final int count;
  final TextStyle textStyle;

  const _CountLabel({
    required this.icon,
    required this.count,
    required this.textStyle,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          size: 14.0,
          color: textStyle.color,
        ),
        const SizedBox(width: 3.0),
        Text(
          '$count',
          style: textStyle,
        ),
      ],
    );
  }
}
