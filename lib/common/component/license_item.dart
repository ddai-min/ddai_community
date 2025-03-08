import 'package:flutter/material.dart';

class LicenseItem extends StatelessWidget {
  final String title;
  final String url;
  final String copyright;
  final String license;

  const LicenseItem({
    super.key,
    required this.title,
    required this.url,
    required this.copyright,
    required this.license,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(title),
        Text(url),
        Text(copyright),
        Text(license),
      ],
    );
  }
}
