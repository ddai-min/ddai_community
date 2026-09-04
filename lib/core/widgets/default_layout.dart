import 'package:ddai_community/core/constants/colors.dart';
import 'package:flutter/material.dart';

/// 앱 전역에서 사용하는 공통 Scaffold 레이아웃.
///
/// [title] 이 주어지면 브랜드 색상의 AppBar 를 렌더링하고,
/// null 이면 AppBar 없이 [child] 만 표시한다.
///
/// 본문 여백([padding])도 여기서 준다. 화면마다 따로 `Padding` 을 씌우지 않는다.
/// 본문은 기본으로 [SingleChildScrollView] 에 담긴다 — 화면마다 따로 씌우지 않는다.
/// ([isScrollable] 로 끌 수 있다)
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

  /// 본문을 [SingleChildScrollView] 로 감쌀지. 기본값은 `true` 다.
  ///
  /// **다음 화면은 반드시 `false` 로 꺼야 한다.** 스크롤뷰 안에서는 높이 제약이
  /// 무한이라 그대로 터지거나 레이아웃이 뭉개진다.
  /// - 자체 스크롤 위젯을 쓰는 화면 — `ListView` · `TabBarView` · 웹뷰
  /// - `Expanded`·`Spacer` 로 남은 높이를 나눠 갖는 화면 (예외 없이 예외를 던진다)
  /// - `Center` 나 `MainAxisAlignment.center` 로 세로 가운데 정렬하는 화면
  ///   (죽지는 않지만 내용 높이만큼 줄어들어 가운데 정렬이 무의미해진다)
  final bool isScrollable;

  /// 본문 스크롤 컨트롤러. [isScrollable] 이 `true` 일 때만 쓰인다.
  ///
  /// 스크롤 위치로 다음 페이지를 불러오는 화면(게시글 상세)이 넘긴다.
  final ScrollController? scrollController;

  /// 본문 스크롤뷰의 클리핑. 기본값은 [Clip.none] 이다.
  ///
  /// 여백([padding])이 스크롤뷰 **바깥**에 있어서, 잘라내면 내용이 여백 경계에서
  /// 딱 끊겨 어색하다. 그래서 자르지 않는 쪽을 기본으로 둔다.
  final Clip clipBehavior;

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
    this.isScrollable = true,
    this.scrollController,
    this.clipBehavior = Clip.none,
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
          child: _renderBody(),
        ),
      ),
      bottomNavigationBar: bottomNavigationBar,
      bottomSheet: bottomSheet,
      floatingActionButton: floatingActionButton,
    );
  }

  /// [isScrollable] 이면 본문을 스크롤뷰에 담아 돌려준다.
  Widget _renderBody() {
    if (!isScrollable) {
      return child;
    }

    return SingleChildScrollView(
      controller: scrollController,
      clipBehavior: clipBehavior,
      child: child,
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
