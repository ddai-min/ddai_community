import 'package:ddai_community/common/const/colors.dart';
import 'package:ddai_community/common/layout/default_layout.dart';
import 'package:flutter/material.dart';

class SplashScreen extends StatelessWidget {
  static get routeName => 'splash';

  const SplashScreen({super.key});

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
