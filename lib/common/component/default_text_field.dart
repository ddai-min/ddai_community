import 'package:ddai_community/common/const/colors.dart';
import 'package:flutter/material.dart';

class DefaultTextField extends StatelessWidget {
  final TextEditingController? controller;
  final ValueChanged<String>? onChanged;
  final double? padding;
  final bool? obscureText;
  final InputBorder? border;
  final InputBorder? focusedBorder;
  final Color? cursorColor;
  final Color? focusColor;
  final String? labelText;
  final String? hintText;

  const DefaultTextField({
    super.key,
    this.controller,
    this.onChanged,
    this.padding = 8.0,
    this.obscureText = false,
    this.border = const OutlineInputBorder(),
    this.focusedBorder = const OutlineInputBorder(
      borderSide: BorderSide(
        color: primaryColor,
      ),
    ),
    this.cursorColor = primaryColor,
    this.focusColor = primaryColor,
    this.labelText,
    this.hintText,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(padding!),
      child: TextFormField(
        controller: controller,
        onChanged: onChanged,
        obscureText: obscureText!,
        cursorColor: cursorColor,
        decoration: InputDecoration(
          border: border,
          labelText: labelText,
          hintText: hintText,
          focusColor: focusColor,
          focusedBorder: focusedBorder,
        ),
      ),
    );
  }
}
