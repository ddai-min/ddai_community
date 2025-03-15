import 'package:ddai_community/board/component/add_board_floating_action_button.dart';
import 'package:ddai_community/board/view/board_list_screen.dart';
import 'package:ddai_community/chat/view/chat_screen.dart';
import 'package:ddai_community/common/const/colors.dart';
import 'package:ddai_community/common/layout/default_layout.dart';
import 'package:ddai_community/user/view/profile_screen.dart';
import 'package:flutter/material.dart';

class HomeTab extends StatefulWidget {
  static get routeName => 'home';

  const HomeTab({super.key});

  @override
  State<HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> with SingleTickerProviderStateMixin {
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
    return DefaultLayout(
      title: 'DDAI Community',
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
