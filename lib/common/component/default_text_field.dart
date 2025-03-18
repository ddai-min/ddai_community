import 'package:ddai_community/common/const/colors.dart';
import 'package:flutter/material.dart';

class DefaultTextField extends StatelessWidget {
  final TextEditingController? controller;
  final String? forceErrorText;
  final ValueChanged<String>? onChanged;
  final double? padding;
  final int? maxLines;
  final bool? obscureText;
  final InputBorder? border;
  final InputBorder? focusedBorder;
  final Color? cursorColor;
  final bool? filled;
  final Color? focusColor;
  final String? labelText;
  final String? hintText;
  final Widget? suffixIcon;

  const DefaultTextField({
    super.key,
    this.controller,
    this.forceErrorText,
    this.onChanged,
    this.padding = 8.0,
    this.maxLines = 1,
    this.obscureText = false,
    this.border = const OutlineInputBorder(),
    this.focusedBorder = const OutlineInputBorder(
      borderSide: BorderSide(
        color: primaryColor,
      ),
    ),
    this.cursorColor = primaryColor,
    this.filled = true,
    this.focusColor = primaryColor,
    this.labelText,
    this.hintText,
    this.suffixIcon,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(padding!),
      child: TextFormField(
        controller: controller,
        forceErrorText: forceErrorText,
        onChanged: onChanged,
        onTapOutside: (event) {
          FocusManager.instance.primaryFocus?.unfocus();
        },
        maxLines: maxLines,
        obscureText: obscureText!,
        cursorColor: cursorColor,
        decoration: InputDecoration(
          contentPadding: const EdgeInsets.all(10),
          filled: filled,
          fillColor: textFieldBackgroundColor,
          border: border,
          labelText: labelText,
          labelStyle: const TextStyle(
            color: primaryColor,
          ),
          hintText: hintText,
          focusColor: focusColor,
          focusedBorder: focusedBorder,
          suffixIcon: suffixIcon,
        ),
      ),
    );
  }
}
