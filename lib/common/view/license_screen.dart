import 'package:ddai_community/common/layout/default_layout.dart';
import 'package:flutter/material.dart';

class LicenseScreen extends StatelessWidget {
  static get routeName => 'license';

  const LicenseScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultLayout(
      title: '오픈소스 라이센스',
      child: Column(),
    );
  }
}
