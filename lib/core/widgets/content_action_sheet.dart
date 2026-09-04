import 'package:ddai_community/core/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// [showContentActionSheet] 에 나열할 동작 하나.
class ContentAction {
  final String label;
  final IconData icon;

  /// 삭제처럼 되돌릴 수 없는 동작이면 붉게 그린다.
  final bool isDestructive;

  final VoidCallback onPressed;

  const ContentAction({
    required this.label,
    required this.icon,
    required this.onPressed,
    this.isDestructive = false,
  });
}

/// 콘텐츠 하나에 대해 취할 동작을 고르는 시트.
///
/// 내 것이면 `[삭제]`, 남의 것이면 `[신고, 차단]` 처럼 호출부가 목록을 만든다.
/// 채팅 말풍선(길게 누르기)과 댓글(오른쪽 메뉴 버튼)이 같은 시트를 쓴다.
///
/// **동작은 시트가 닫힌 뒤에 실행된다.** 시트가 열린 채로 다이얼로그를 띄우면
/// 다이얼로그를 닫을 때 시트까지 함께 사라져서 흐름이 끊긴다.
Future<void> showContentActionSheet({
  required BuildContext context,
  required List<ContentAction> actions,
}) async {
  ContentAction? selected;

  await showModalBottomSheet(
    context: context,
    backgroundColor: Colors.white,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(
        top: Radius.circular(AppTheme.borderRadius),
      ),
    ),
    builder: (sheetContext) {
      return SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (final action in actions)
              ListTile(
                leading: Icon(
                  action.icon,
                  color: action.isDestructive ? Colors.red : null,
                ),
                title: Text(
                  action.label,
                  style: TextStyle(
                    color: action.isDestructive ? Colors.red : null,
                  ),
                ),
                onTap: () {
                  selected = action;

                  sheetContext.pop();
                },
              ),
          ],
        ),
      );
    },
  );

  selected?.onPressed();
}
