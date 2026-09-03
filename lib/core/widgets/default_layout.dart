import 'package:ddai_community/core/constants/colors.dart';
import 'package:flutter/material.dart';

/// 앱 전역에서 사용하는 공통 Scaffold 레이아웃.
///
/// [title] 이 주어지면 브랜드 색상의 AppBar 를 렌더링하고,
/// null 이면 AppBar 없이 [child] 만 표시한다.
///
/// 본문 여백([padding])도 여기서 준다. 화면마다 따로 `Padding` 을 씌우지 않는다.
class DefaultLayout extends StatelessWidget {
  /// 모든 화면이 공유하는 본문 여백. [padding] 의 기본값이다.
  ///
  /// 화면마다 8/16 이 제각각이던 것을 한 값으로 모았다.
  /// 여백을 달리해야 하는 화면은 [padding] 으로 넘기고, 이 값을 고치지 않는다.
  static const EdgeInsets contentPadding = EdgeInsets.symmetric(
    vertical: 16,
    horizontal: 24,
  );

  final Widget child;

  /// 본문 여백. 기본값은 [contentPadding] 이다.
  ///
  /// 목록을 화면 끝까지 붙여야 하는 화면(게시판·채팅)만 [EdgeInsets.zero] 를 넘긴다.
  /// 그 밖에는 기본값을 그대로 둬야 화면끼리 어긋나지 않는다.
  /// 개별 화면에서 `Padding` 을 덧씌우면 이 값에 더해지므로 그러지 않는다.
  /// (말풍선·리스트 아이템처럼 위젯 **안쪽** 여백은 별개다)
  final EdgeInsetsGeometry padding;
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
    this.padding = contentPadding,
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
      body: SafeArea(
        child: Padding(
          padding: padding,
          child: child,
        ),
      ),
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
