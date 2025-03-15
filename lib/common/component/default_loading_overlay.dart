import 'package:ddai_community/common/component/default_circular_progress_indicator.dart';
import 'package:flutter/material.dart';

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
