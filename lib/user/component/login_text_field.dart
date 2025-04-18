import 'package:ddai_community/common/component/default_text_field.dart';
import 'package:flutter/material.dart';

class LoginTextField extends StatelessWidget {
  final TextEditingController? controller;
  final FormFieldValidator<String>? validator;
  final ValueChanged<String>? onChanged;
  final String? labelText;
  final String? hintText;
  final bool obscureText;

  const LoginTextField({
    super.key,
    this.controller,
    this.validator,
    this.onChanged,
    this.labelText,
    this.hintText,
    this.obscureText = false,
  });

  @override
  Widget build(BuildContext context) {
    return DefaultTextField(
      controller: controller,
      validator: validator,
      onChanged: onChanged,
      labelText: labelText,
      hintText: hintText,
      obscureText: obscureText,
      filled: false,
      maxLength: 50,
    );
  }
}
