import 'package:ddai_community/core/constants/colors.dart';
import 'package:ddai_community/core/utils/data_utils.dart';
import 'package:ddai_community/features/notification/domain/notification_model.dart';
import 'package:flutter/material.dart';

/// 알림 목록의 한 줄.
///
/// "누가 · 무엇을 · 어느 글에" 를 한 줄씩 쌓고, 안 읽은 알림만 옅게 칠한다.
/// 여백을 화면이 아니라 이 위젯이 갖는 이유는 **안 읽음 배경이 화면 끝까지
/// 닿아야** 목록을 훑을 때 무엇이 남았는지 한눈에 들어오기 때문이다.
class NotificationListItem extends StatelessWidget {
  final NotificationModel notification;
  final GestureTapCallback onTap;

  const NotificationListItem({
    super.key,
    required this.notification,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final metaTextStyle = TextStyle(
      fontSize: 12.0,
      color: Colors.grey[600],
    );

    final isComment = notification.type == NotificationType.comment;
    final preview = notification.preview;
    final hasPreview = preview != null && preview.isNotEmpty;

    return ColoredBox(
      color: notification.isRead
          ? Colors.transparent
          : primaryColor.withValues(alpha: 0.08),
      child: ListTile(
        // 화면(DefaultLayout)이 여백을 주지 않으므로 가로 여백은 공통값과 맞춘다.
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 24.0,
          vertical: 8.0,
        ),
        // 부제 줄 수가 알림마다 달라서, 비워 두면 아이콘과 시각의 높이가 들쭉날쭉해진다.
        titleAlignment: ListTileTitleAlignment.top,
        leading: CircleAvatar(
          radius: 18.0,
          backgroundColor: isComment ? primaryColor : Colors.redAccent,
          foregroundColor: Colors.white,
          child: Icon(
            isComment ? Icons.chat_bubble : Icons.favorite,
            size: 18.0,
          ),
        ),
        title: Text(
          '${notification.actorName}님이 ${notification.type.label}',
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: 14.0,
            // 안 읽은 알림만 굵게. 색으로만 구분하면 옅은 배경이라 놓치기 쉽다.
            fontWeight: notification.isRead
                ? FontWeight.normal
                : FontWeight.bold,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4.0),
            Text(
              // 원글 제목. 작성 시점의 스냅샷이라 제목을 고쳐도 바뀌지 않는다.
              '"${notification.boardTitle}"',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: metaTextStyle,
            ),
            if (hasPreview) ...[
              const SizedBox(height: 2.0),
              Text(
                preview,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 13.0),
              ),
            ],
          ],
        ),
        trailing: Text(
          DataUtils.formatRelativeDate(notification.date),
          style: metaTextStyle,
        ),
        onTap: onTap,
      ),
    );
  }
}
