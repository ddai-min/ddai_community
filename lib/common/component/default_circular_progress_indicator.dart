import 'package:ddai_community/common/const/colors.dart';
import 'package:flutter/material.dart';

class DefaultCircularProgressIndicator extends StatelessWidget {
  final Color? color;

  const DefaultCircularProgressIndicator({
    super.key,
    this.color = primaryColor,
  });

  @override
  Widget build(BuildContext context) {
    return CircularProgressIndicator(
      color: color,
    );
  }
}
