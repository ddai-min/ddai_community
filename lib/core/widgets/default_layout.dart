import 'package:ddai_community/core/constants/colors.dart';
import 'package:flutter/material.dart';

/// 앱 전역에서 사용하는 공통 Scaffold 레이아웃.
///
/// [title] 이 주어지면 브랜드 색상의 AppBar 를 렌더링하고,
/// null 이면 AppBar 없이 [child] 만 표시한다.
class DefaultLayout extends StatelessWidget {
  final Widget child;
  final bool? resizeToAvoidBottomInset;
  final Color? backgroundColor;
  final String? title;
  final List<Widget>? actions;
  final Widget? bottomNavigationBar;
  final Widget? bottomSheet;
  final Widget? floatingActionButton;

  const DefaultLayout({
    super.key,
    required this.child,
    this.resizeToAvoidBottomInset,
    this.backgroundColor = Colors.white,
    this.title,
    this.actions,
    this.bottomNavigationBar,
    this.bottomSheet,
    this.floatingActionButton,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: resizeToAvoidBottomInset,
      backgroundColor: backgroundColor,
      appBar: _renderAppBar(),
      body: child,
      bottomNavigationBar: bottomNavigationBar,
      bottomSheet: bottomSheet,
      floatingActionButton: floatingActionButton,
    );
  }

  /// [title] 이 null 이면 AppBar 를 그리지 않는다.
  AppBar? _renderAppBar() {
    if (title == null) {
      return null;
    } else {
      return AppBar(
        actions: actions,
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: Text(
          title!,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
      );
    }
  }
}
