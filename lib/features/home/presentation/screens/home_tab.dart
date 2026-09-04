import 'package:ddai_community/core/constants/colors.dart';
import 'package:ddai_community/core/widgets/default_layout.dart';
import 'package:ddai_community/core/widgets/default_text_button.dart';
import 'package:ddai_community/features/auth/presentation/screens/login_screen.dart';
import 'package:ddai_community/features/board/presentation/screens/board_list_screen.dart';
import 'package:ddai_community/features/board/presentation/widgets/add_board_floating_action_button.dart';
import 'package:ddai_community/features/chat/presentation/screens/chat_screen.dart';
import 'package:ddai_community/features/user/presentation/providers/user_me_provider.dart';
import 'package:ddai_community/features/user/presentation/screens/profile_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// 로그인 후 진입하는 메인 화면.
///
/// 게시판·채팅·프로필 세 탭을 하단 내비게이션으로 전환하며,
/// 게시판 탭에서만 글쓰기 플로팅 버튼을 노출한다.
/// 비로그인 상태로 진입하면 로그인 안내 화면을 대신 보여준다.
class HomeTab extends ConsumerStatefulWidget {
  static String get routeName => 'home';

  const HomeTab({super.key});

  @override
  ConsumerState<HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends ConsumerState<HomeTab>
    with SingleTickerProviderStateMixin {
  int index = 0;
  late TabController tabController;

  @override
  void initState() {
    super.initState();

    tabController = TabController(
      length: 3,
      vsync: this,
    );

    tabController.addListener(_tabListener);
  }

  @override
  void dispose() {
    tabController.removeListener(_tabListener);
    tabController.dispose();

    super.dispose();
  }

  void _tabListener() {
    setState(() {
      index = tabController.index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.read(userMeProvider);

    if (user.id.isEmpty) {
      return DefaultLayout(
        title: 'DDAI Community',
        // 스크롤뷰 안에서는 높이가 내용만큼 줄어들어 세로 가운데 정렬이 무의미해진다.
        isScrollable: false,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              '로그인 후 이용해주세요.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16.0,
              ),
            ),
            DefaultTextButton(
              onPressed: () {
                context.goNamed(
                  LoginScreen.routeName,
                );
              },
              text: '로그인',
            ),
          ],
        ),
      );
    }

    return DefaultLayout(
      title: 'DDAI Community',
      // 게시판·채팅은 목록이 화면 끝까지 닿아야 하고 프로필만 여백이 필요하다.
      // 세 탭이 레이아웃 하나를 공유하므로 여백은 각 탭이 직접 준다.
      padding: EdgeInsets.zero,
      // TabBarView 와 그 안의 목록이 스스로 스크롤한다. 스크롤뷰로 감싸면 높이가
      // 무한이 되어 그대로 터진다.
      isScrollable: false,
      floatingActionButton: renderFloatingActionButton(),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.white,
        selectedItemColor: primaryColor,
        selectedFontSize: 12.0,
        unselectedFontSize: 12.0,
        type: BottomNavigationBarType.fixed,
        currentIndex: index,
        onTap: (int index) => tabController.animateTo(index),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.list_alt_outlined),
            activeIcon: Icon(Icons.list_alt),
            label: '게시판',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.chat_bubble_outline),
            activeIcon: Icon(Icons.chat_bubble),
            label: '채팅',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline_outlined),
            activeIcon: Icon(Icons.person),
            label: '프로필',
          ),
        ],
      ),
      child: TabBarView(
        controller: tabController,
        physics: const NeverScrollableScrollPhysics(),
        clipBehavior: Clip.none,
        children: const [
          BoardListScreen(),
          ChatScreen(),
          ProfileScreen(),
        ],
      ),
    );
  }

  Widget? renderFloatingActionButton() {
    if (index == 0) {
      return const AddBoardFloatingActionButton();
    } else {
      return null;
    }
  }
}
