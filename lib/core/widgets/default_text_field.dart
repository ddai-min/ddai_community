import 'package:ddai_community/core/constants/colors.dart';
import 'package:flutter/material.dart';

/// 앱 전역에서 사용하는 공통 입력 필드.
///
/// 브랜드 색상 커서·포커스 테두리, 회색 배경, 글자 수 카운터 숨김이 기본값이다.
/// 바깥을 탭하면 포커스가 해제되고, [readOnly] 이면 글자를 회색으로 표시한다.
/// 로그인·댓글·채팅 입력 필드가 이 위젯을 감싸 각자의 스타일을 덧입힌다.
class DefaultTextField extends StatelessWidget {
  final TextEditingController? controller;
  final String? forceErrorText;
  final ValueChanged<String>? onChanged;
  final FormFieldValidator<String>? validator;
  final bool readOnly;

  /// 위아래 여백. 필드를 세로로 쌓았을 때의 간격이다. (가로 여백은 화면이 준다)
  final double padding;
  final int maxLines;
  final int maxLength;
  final bool obscureText;
  final InputBorder border;
  final InputBorder focusedBorder;
  final Color cursorColor;
  final bool filled;
  final Color focusColor;
  final String? labelText;
  final String? hintText;
  final Widget? suffixIcon;

  const DefaultTextField({
    super.key,
    this.controller,
    this.forceErrorText,
    this.onChanged,
    this.validator,
    this.readOnly = false,
    this.padding = 8.0,
    this.maxLines = 1,
    this.maxLength = 500,
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
      // 가로 여백은 [DefaultLayout.contentPadding] 이 준다.
      // 여기서 또 주면 이 필드만 버튼·본문보다 안쪽으로 들어간다.
      padding: EdgeInsets.symmetric(vertical: padding),
      child: TextFormField(
        controller: controller,
        selectionControls: materialTextSelectionControls,
        forceErrorText: forceErrorText,
        onChanged: onChanged,
        validator: validator,
        onTapOutside: (event) {
          FocusManager.instance.primaryFocus?.unfocus();
        },
        readOnly: readOnly,
        style: readOnly
            ? const TextStyle(
                color: Colors.grey,
              )
            : null,
        maxLines: maxLines,
        maxLength: maxLength,
        obscureText: obscureText,
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
          counterText: '',
        ),
      ),
    );
  }
}
