import 'package:ddai_community/common/const/colors.dart';
import 'package:flutter/material.dart';

class DefaultElevatedButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final String text;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final OutlinedBorder? shape;
  final EdgeInsetsGeometry? padding;

  const DefaultElevatedButton({
    super.key,
    this.onPressed,
    required this.text,
    this.backgroundColor = primaryColor,
    this.foregroundColor = Colors.white,
    this.shape,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        elevation: 0,
        padding: padding,
        backgroundColor: backgroundColor,
        foregroundColor: foregroundColor,
        shape: shape ??
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(6),
            ),
      ),
      child: Text(text),
    );
  }
}
