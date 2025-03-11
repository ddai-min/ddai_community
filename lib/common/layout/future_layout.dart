import 'package:flutter/material.dart';

class FutureLayout<T> extends StatelessWidget {
  final Future<T> future;
  final Widget loadingDataWidget;
  final Widget nullDataWidget;
  final Widget Function(AsyncSnapshot<T> snapshot) widget;

  const FutureLayout({
    super.key,
    required this.future,
    required this.loadingDataWidget,
    required this.nullDataWidget,
    required this.widget,
  });

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<T>(
      future: future,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done &&
            !snapshot.hasData) {
          return loadingDataWidget;
        }

        if (snapshot.data == null) {
          return nullDataWidget;
        }

        return widget(snapshot);
      },
    );
  }
}
