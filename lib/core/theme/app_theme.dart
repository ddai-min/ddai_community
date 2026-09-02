import 'package:ddai_community/core/constants/colors.dart';
import 'package:flutter/material.dart';

/// 앱 전역 테마 정의.
///
/// 폰트(NotoSans)·텍스트 선택 색상 등 브랜드 스타일을 한곳에서 관리한다.
/// [App] 의 `MaterialApp.router` 에 주입된다.
class AppTheme {
  const AppTheme._();

  static ThemeData get light => ThemeData(
    fontFamily: 'NotoSans',
    textSelectionTheme: const TextSelectionThemeData(
      selectionColor: Colors.grey,
      selectionHandleColor: primaryColor,
    ),
  );
}
