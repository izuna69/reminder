import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// 테마 상태를 관리하는 Notifier
class ThemeNotifier extends Notifier<ThemeMode> {
  @override
  ThemeMode build() {
    // 초기 테마는 시스템 설정을 따릅니다.
    return ThemeMode.system;
  }

  // 테마를 변경하는 메서드
  void toggleTheme() {
    // 현재 테마가 'dark'이면 'light'로, 아니면 'dark'로 변경
    state = state == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
  }
}

// ThemeNotifier를 사용하기 위한 Provider 정의
final themeProvider = NotifierProvider<ThemeNotifier, ThemeMode>(() {
  return ThemeNotifier();
});

// 사용자가 선택한 테마 전용 색상을 저장하는 장소입니다. (기본값: 파랑)
class ColorNotifier extends Notifier<Color> {
  @override
  Color build() => Colors.blue; // 기본색

  void setColor(Color color) => state = color;
}

final seedColorProvider = NotifierProvider<ColorNotifier, Color>(() => ColorNotifier());

