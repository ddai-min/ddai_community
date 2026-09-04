import 'package:ddai_community/core/constants/colors.dart';
import 'package:flutter/material.dart';

/// 앱 전역 테마 정의.
///
/// 폰트(NotoSans)·텍스트 선택 색상·모서리 둥글기 등 브랜드 스타일을 한곳에서 관리한다.
/// [App] 의 `MaterialApp.router` 에 주입된다.
class AppTheme {
  const AppTheme._();

  /// 다이얼로그와 버튼이 공유하는 모서리 둥글기.
  ///
  /// **위젯에서 각자 지정하지 않는다.** 예전에는 버튼만 6 을 박아 두고 다이얼로그는
  /// 아무것도 주지 않아 Material 기본값(28)으로 그려졌고, 다이얼로그 안에 버튼이
  /// 들어가는 구조라 둘이 나란히 어긋나 보였다.
  /// 값을 바꾸면 두 곳이 함께 바뀐다.
  static const double borderRadius = 10;

  /// [borderRadius] 를 적용한 공통 모양.
  static final RoundedRectangleBorder _shape = RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(borderRadius),
  );

  static ThemeData get light => ThemeData(
    fontFamily: 'NotoSans',
    textSelectionTheme: const TextSelectionThemeData(
      selectionColor: Colors.grey,
      selectionHandleColor: primaryColor,
    ),
    dialogTheme: DialogThemeData(
      shape: _shape,
    ),
    // 버튼은 `styleFrom(shape: ...)` 을 비워 두면 이 테마를 따른다.
    // 모양을 달리해야 하는 버튼(EULA 하단의 각진 버튼)만 위젯에서 넘긴다.
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(shape: _shape),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(shape: _shape),
    ),
  );
}
