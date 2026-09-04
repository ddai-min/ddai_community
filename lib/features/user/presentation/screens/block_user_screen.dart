import 'package:ddai_community/core/widgets/default_circular_progress_indicator.dart';
import 'package:ddai_community/core/widgets/default_dialog.dart';
import 'package:ddai_community/core/widgets/default_layout.dart';
import 'package:ddai_community/features/auth/presentation/providers/auth_provider.dart';
import 'package:ddai_community/features/board/presentation/providers/board_provider.dart';
import 'package:ddai_community/features/chat/presentation/providers/chat_provider.dart';
import 'package:ddai_community/features/user/domain/block_user_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// 차단한 사용자 목록 화면. (프로필 탭에서 진입)
///
/// 차단은 게시글 상세에서만 걸 수 있고 지금까지 **푸는 방법이 없었다.**
/// 개인정보처리방침이 차단 기록 보유 기간을 "이용자가 차단을 해제하거나 회원 탈퇴할
/// 때까지" 로 적고 있으므로 이 화면이 그 문구의 근거이기도 하다.
///
/// 목록은 페이지네이션하지 않는다. 이유는 [BlockUserModel] 참고.
class BlockUserScreen extends ConsumerWidget {
  static String get routeName => 'block_user';

  const BlockUserScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final blockUserList = ref.watch(blockUserListProvider);

    return DefaultLayout(
      title: '차단한 사용자',
      child: blockUserList.when(
        loading: () => const Center(
          child: DefaultCircularProgressIndicator(),
        ),
        error: (_, _) => const Center(
          child: Text('목록을 불러오지 못했습니다.'),
        ),
        data: (items) {
          if (items.isEmpty) {
            return const Center(
              child: Text('차단한 사용자가 없습니다.'),
            );
          }

          return ListView.separated(
            itemCount: items.length,
            itemBuilder: (_, index) => _BlockUserListItem(
              blockUser: items[index],
              onPressed: () {
                _confirmUnblock(
                  context: context,
                  ref: ref,
                  blockUser: items[index],
                );
              },
            ),
            separatorBuilder: (_, _) => const Divider(height: 1),
          );
        },
      ),
    );
  }

  void _confirmUnblock({
    required BuildContext context,
    required WidgetRef ref,
    required BlockUserModel blockUser,
  }) {
    showDialog(
      context: context,
      builder: (_) {
        return DefaultDialog(
          titleText: '차단 해제',
          // 이름이 비어 있을 수 있어(마이그레이션 전 행) 문구에 넣지 않는다.
          contentText: '차단을 해제하시겠습니까?\n이 사용자가 쓴 글이 다시 보이게 됩니다.',
          buttonText: '차단 해제',
          onPressed: () {
            context.pop();

            _unblockUser(
              context: context,
              ref: ref,
              blockUser: blockUser,
            );
          },
        );
      },
    );
  }

  void _unblockUser({
    required BuildContext context,
    required WidgetRef ref,
    required BlockUserModel blockUser,
  }) async {
    final isSuccess = await ref.read(
      unblockUserProvider(blockUser.blockedUid).future,
    );

    if (!isSuccess) {
      showDialog(
        context: context,
        builder: (_) {
          return DefaultDialog(
            contentText: '차단 해제에 실패했습니다.\n잠시 후 다시 시도해주세요.',
            buttonText: '확인',
            onPressed: () {
              context.pop();
            },
          );
        },
      );

      return;
    }

    ref.invalidate(blockUserListProvider);

    // 차단 여부는 RLS(`is_blocked()`)가 조회 시점에 서버에서 거른다. 이미 받아 둔
    // 목록에는 반영되지 않으므로 다시 받아야 그 사람 글이 돌아온다.
    ref.read(boardListProvider.notifier).refresh();

    // 채팅은 `refresh()` 가 아니라 invalidate 다. 스트림 구독을 다시 맺어야
    // 이전 메시지까지 새 RLS 판정으로 받아온다. (`ChatList.build` 가 재구독한다)
    ref.invalidate(chatListProvider);
  }
}

/// 차단한 사용자 한 줄. 닉네임과 차단 시각, 해제 버튼을 보여준다.
class _BlockUserListItem extends StatelessWidget {
  final BlockUserModel blockUser;
  final VoidCallback onPressed;

  const _BlockUserListItem({
    required this.blockUser,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final date = blockUser.date.toLocal();

    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(
        blockUser.blockedUserName.isEmpty
            ? '(이름을 알 수 없는 사용자)'
            : blockUser.blockedUserName,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      ),
      subtitle: Text(
        '${date.year}.${date.month}.${date.day} 차단',
        style: TextStyle(
          fontSize: 13,
          color: Colors.grey[600],
        ),
      ),
      trailing: TextButton(
        onPressed: onPressed,
        style: TextButton.styleFrom(
          foregroundColor: Colors.grey[700],
        ),
        child: const Text('차단 해제'),
      ),
    );
  }
}
