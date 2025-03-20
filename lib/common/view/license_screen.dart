import 'package:ddai_community/common/const/license.dart';
import 'package:ddai_community/common/layout/default_layout.dart';
import 'package:flutter/material.dart';

class LicenseScreen extends StatelessWidget {
  static get routeName => 'license';

  const LicenseScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultLayout(
      title: '오픈소스 라이센스',
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: Column(
            children: [
              ListView.separated(
                physics: const NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                itemCount: license.length,
                itemBuilder: (context, index) => _LicenseItem(
                  title: license[index].title,
                  url: license[index].url,
                  copyright: license[index].copyright,
                  license: license[index].license,
                ),
                separatorBuilder: (context, index) =>
                    const SizedBox(height: 16),
              ),
              const SizedBox(height: 20),
              ListView.separated(
                physics: const NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                itemCount: licenseDescription.length,
                itemBuilder: (context, index) => _LicenseDescriptionItem(
                  title: licenseDescription[index].title,
                  description: licenseDescription[index].description,
                ),
                separatorBuilder: (context, index) =>
                    const SizedBox(height: 16),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LicenseItem extends StatelessWidget {
  final String title;
  final String url;
  final String copyright;
  final String license;

  const _LicenseItem({
    required this.title,
    required this.url,
    required this.copyright,
    required this.license,
  });

  @override
  Widget build(BuildContext context) {
    final contentTextStyle = TextStyle(
      fontSize: 14.0,
      color: Colors.grey[700],
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 20.0,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8.0),
        Text(
          url,
          style: contentTextStyle,
        ),
        Text(
          copyright,
          style: contentTextStyle,
        ),
        Text(
          license,
          style: contentTextStyle,
        ),
      ],
    );
  }
}

class _LicenseDescriptionItem extends StatelessWidget {
  final String title;
  final String description;

  const _LicenseDescriptionItem({
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 20.0,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8.0),
          Text(
            description,
            style: TextStyle(
              fontSize: 14.0,
              color: Colors.grey[700],
            ),
          ),
        ],
      ),
    );
  }
}
