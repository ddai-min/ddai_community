import 'package:flutter/material.dart';

class SplashScreen extends StatelessWidget {
  static get routeName => 'splash';
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text('Splash Screen'),
    );
  }
}
