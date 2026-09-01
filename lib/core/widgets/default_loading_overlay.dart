import 'package:ddai_community/core/widgets/default_circular_progress_indicator.dart';
import 'package:flutter/material.dart';

/// 화면 전체를 덮는 로딩 오버레이 제어 유틸.
///
/// 네트워크 요청 직전에 [showLoading], 응답 후 [hideLoading] 을 호출한다.
/// 배경 탭으로는 닫히지 않으므로([barrierDismissible] false) 반드시 짝을 맞춰 호출해야 한다.
class DefaultLoadingOverlay {
  static void showLoading(BuildContext context) {
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          alignment: Alignment.center,
          child: const DefaultCircularProgressIndicator(),
        ),
      ),
    );
  }

  static void hideLoading(BuildContext context) {
    Navigator.pop(context);
  }
}
