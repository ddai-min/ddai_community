import 'package:ddai_community/common/const/colors.dart';
import 'package:flutter/material.dart';

class DefaultElevatedButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final String text;
  final Color? backgroundColor;
  final Color? foregroundColor;

  const DefaultElevatedButton({
    super.key,
    this.onPressed,
    required this.text,
    this.backgroundColor = primaryColor,
    this.foregroundColor = Colors.white,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        elevation: 0,
        backgroundColor: backgroundColor,
        foregroundColor: foregroundColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(6),
        ),
      ),
      child: Text(text),
    );
  }
}
