import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:reminder/providers/theme_provider.dart';
import 'package:reminder/screens/home_screen.dart';
import 'package:reminder/services/notification_service.dart';

void main() async {
  // runApp 전에 비동기 작업을 수행하기 위해 필요합니다.
  WidgetsFlutterBinding.ensureInitialized();

  // Isar 데이터베이스 서비스를 초기화합니다.

  // 알림 서비스를 초기화합니다. (웹에서는 작동하지 않을 수 있음)
  if (!kIsWeb) {
    await NotificationService.instance.init();
  }

  // 앱 전체를 ProviderScope로 감싸서 Riverpod를 사용할 수 있도록 합니다.
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeProvider);

    return MaterialApp(
      title: '리마인더',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.deepOrange,
          brightness: Brightness.light,
        ),
        useMaterial3: true,
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.deepOrange,
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      themeMode: themeMode,
      home: const HomeScreen(),
    );
  }
}
