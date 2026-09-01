import 'package:ddai_community/app/app.dart';
import 'package:ddai_community/app/bootstrap.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // .env 로드 및 Firebase 초기화.
  await Bootstrap.run();

  runApp(
    const ProviderScope(
      child: App(),
    ),
  );
}
