import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:reminder/models/task.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  // Singleton pattern
  NotificationService._privateConstructor();
  static final NotificationService instance =
      NotificationService._privateConstructor();

  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  static const AndroidNotificationChannel _channel = AndroidNotificationChannel(
    'reminder_channel_id', // id
    '리마인더 알림', // name
    description: '예약된 할 일에 대한 알림을 표시합니다.', // description
    importance: Importance.max,
    playSound: true,
  );

  // 초기화 메서드
  Future<void> init() async {
    // Timezone 데이터베이스 초기화
    tz.initializeTimeZones();
    // 로컬 시간대 설정 (flutter_timezone 사용)
    final localTimezone = await FlutterTimezone.getLocalTimezone();
    tz.setLocalLocation(tz.getLocation(localTimezone.identifier));

    // 알림 채널 생성 (Android)
    final androidPlugin = _flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();
    if (androidPlugin != null) {
      await androidPlugin.createNotificationChannel(_channel);
    }

    // Android 초기화 설정
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    // iOS 초기화 설정
    const DarwinInitializationSettings initializationSettingsIOS =
        DarwinInitializationSettings(
          requestAlertPermission: true,
          requestBadgePermission: true,
          requestSoundPermission: true,
        );

    final InitializationSettings initializationSettings =
        InitializationSettings(
          android: initializationSettingsAndroid,
          iOS: initializationSettingsIOS,
        );

    // 플러그인 초기화
    await _flutterLocalNotificationsPlugin.initialize(initializationSettings);

    // 권한 요청
    await _requestPermissions();
  }

  // 권한 요청
  Future<void> _requestPermissions() async {
    final plugin = _flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();
    if (plugin != null) {
      await plugin.requestNotificationsPermission();
      await plugin.requestExactAlarmsPermission();
    }
  }

  // 알림 예약
  Future<void> scheduleNotification(Task task) async {
    // task.id가 null이면 예외 발생 또는 다른 방식으로 처리
    if (task.id == null) {
      print("Task ID is null, cannot schedule notification.");
      return;
    }

    if (!task.isAlarmEnabled) {
      await cancelNotification(task.id!);
      return;
    }

    final tz.TZDateTime scheduledDate = tz.TZDateTime.from(
      task.dueDate,
      tz.local,
    );

    final AndroidNotificationDetails androidNotificationDetails =
        AndroidNotificationDetails(
      _channel.id,
      _channel.name,
      channelDescription: _channel.description,
      importance: Importance.max,
      priority: Priority.high,
      showWhen: false,
    );
    final NotificationDetails notificationDetails = NotificationDetails(
      android: androidNotificationDetails,
    );

    await _flutterLocalNotificationsPlugin.zonedSchedule(
      task.id! as int, // non-null 보장
      task.title,
      '예정된 할 일이 있습니다.',
      scheduledDate,
      notificationDetails,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
    );
  }

  // 알림 취소
  Future<void> cancelNotification(int id) async {
    await _flutterLocalNotificationsPlugin.cancel(id);
  }
}
