import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:reminder/providers/theme_provider.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 제시할 컬러 테마 리스트 (임의의 컬러들)
    final List<Color> themeOptions = [
      Colors.blue, Colors.red, Colors.green, Colors.orange, Colors.purple, Colors.teal
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('설정')),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text("테마 색상 선택", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Wrap(
              spacing: 15,
              children: themeOptions.map((color) {
                return GestureDetector(
                  onTap: () {
                    // 선택한 색상을 저장소에 반영합니다.
                    ref.read(seedColorProvider.notifier).setColor(color);
                  },
                  child: CircleAvatar(
                    backgroundColor: color,
                    // 현재 선택된 색상에만 체크 표시를 합니다.
                    child: ref.watch(seedColorProvider) == color
                        ? const Icon(Icons.check, color: Colors.white)
                        : null,
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}