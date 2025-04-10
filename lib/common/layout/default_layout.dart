import 'package:ddai_community/common/const/colors.dart';
import 'package:flutter/material.dart';

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
