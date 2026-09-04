import 'package:ddai_community/core/widgets/default_dialog.dart';
import 'package:ddai_community/core/widgets/text_field_dialog.dart';
import 'package:ddai_community/features/auth/presentation/providers/auth_provider.dart';
import 'package:ddai_community/features/user/domain/report_parameter.dart';
import 'package:ddai_community/features/user/presentation/providers/report_provider.dart';
import 'package:ddai_community/features/user/presentation/providers/user_me_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// 남이 쓴 콘텐츠를 신고한다. 사유를 입력받아 `report` 에 기록한다.
///
/// 게시글 상세의 AppBar 버튼과 채팅·댓글의 동작 시트가 **같은 구현**을 쓴다.
/// 예전에는 신고가 게시글 상세에만 있어서, 전체 공개인 채팅에서 욕설을 봐도
/// 그 사람이 쓴 게시글을 따로 찾아 들어가야만 신고할 수 있었다.
Future<void> showReportDialog({
  required BuildContext context,
  required WidgetRef ref,
  required ReportContentType contentType,
  required String contentId,
  required String userUid,
  required String userName,
}) async {
  final reportTextController = TextEditingController();
  String? reason;

  await showDialog(
    context: context,
    builder: (dialogContext) {
      return TextFieldDialog(
        textController: reportTextController,
        contentText: '${contentType.label} 신고 사유를 입력해주세요.',
        hintText: '신고 사유',
        buttonText: '신고',
        onPressed: () {
          // 컨트롤러는 이 다이얼로그와 함께 사라지므로 값만 꺼내 두고 닫는다.
          reason = reportTextController.text.trim();

          dialogContext.pop();
        },
      );
    },
  );

  reportTextController.dispose();

  // 사유 없이 닫았으면(바깥 탭 등) 아무 일도 하지 않는다.
  if (reason == null || !context.mounted) {
    return;
  }

  if (reason!.isEmpty) {
    await _notify(
      context: context,
      message: '신고 사유를 입력해주세요.',
    );

    return;
  }

  final userMe = ref.read(userMeProvider);

  final isSuccess = await ref.read(
    reportProvider(
      ReportParams(
        reporterUserName: userMe.userName,
        reporterUserUid: userMe.id,
        reportedUserName: userName,
        reportedUserUid: userUid,
        reportReason: reason!,
        reportContentId: contentId,
        reportContentType: contentType,
      ),
    ).future,
  );

  if (!context.mounted) {
    return;
  }

  // 실패를 알리지 않으면 사유가 너무 길거나(500자 제한) 네트워크가 끊겼을 때
  // 눌러도 아무 반응이 없어 접수된 줄 알게 된다.
  await _notify(
    context: context,
    title: isSuccess ? '신고 완료' : null,
    message: isSuccess
        ? '신고가 접수되었습니다.\n확인 후 조치하겠습니다.'
        : '신고에 실패했습니다.\n잠시 후 다시 시도해주세요.',
  );
}

/// 작성자를 차단한다. 성공하면 [onBlocked] 로 목록 갱신을 맡긴다.
///
/// 익명 계정은 차단할 수 없다. (기존 게시글 상세의 동작을 그대로 옮겼다)
Future<void> showBlockDialog({
  required BuildContext context,
  required WidgetRef ref,
  required String userUid,
  required String userName,
  required VoidCallback onBlocked,
}) async {
  if (ref.read(userMeProvider).isAnonymous) {
    await _notify(
      context: context,
      message: '로그인 후\n차단할 수 있습니다.',
    );

    return;
  }

  var isConfirmed = false;

  await showDialog(
    context: context,
    builder: (dialogContext) {
      return DefaultDialog(
        titleText: '차단',
        contentText: '$userName 님을 차단하시겠습니까?\n이 사용자가 쓴 글과 메시지가 보이지 않게 됩니다.',
        buttonText: '차단',
        onPressed: () {
          isConfirmed = true;

          dialogContext.pop();
        },
      );
    },
  );

  if (!isConfirmed || !context.mounted) {
    return;
  }

  final isSuccess = await ref.read(
    blockUserProvider(userUid).future,
  );

  if (!context.mounted) {
    return;
  }

  await _notify(
    context: context,
    title: isSuccess ? '차단 완료' : null,
    message: isSuccess
        ? '차단이 완료되었습니다.\n프로필 > 차단한 사용자에서 해제할 수 있습니다.'
        : '차단에 실패했습니다.\n잠시 후 다시 시도해주세요.',
  );

  if (isSuccess) {
    onBlocked();
  }
}

/// 확인 버튼 하나짜리 안내 다이얼로그.
Future<void> _notify({
  required BuildContext context,
  required String message,
  String? title,
}) {
  return showDialog(
    context: context,
    builder: (dialogContext) {
      return DefaultDialog(
        titleText: title,
        contentText: message,
        buttonText: '확인',
        onPressed: () {
          dialogContext.pop();
        },
      );
    },
  );
}
