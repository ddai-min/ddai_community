import 'package:ddai_community/core/widgets/default_text_field.dart';
import 'package:flutter/material.dart';

/// 로그인·회원가입 폼 전용 입력 필드.
///
/// [DefaultTextField] 에서 배경을 없애고 최대 50자로 제한한 형태다.
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
