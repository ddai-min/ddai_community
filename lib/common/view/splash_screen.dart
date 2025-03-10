import 'package:ddai_community/common/const/colors.dart';
import 'package:ddai_community/common/layout/default_layout.dart';
import 'package:ddai_community/user/view/login_screen.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class SplashScreen extends StatefulWidget {
  static get routeName => 'splash';

  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();

    Future.delayed(
      const Duration(seconds: 2),
      () {
        context.goNamed(
          LoginScreen.routeName,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return const DefaultLayout(
      backgroundColor: primaryColor,
      child: Center(
        child: Text(
          'DDAI\nCommunity',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 40,
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
