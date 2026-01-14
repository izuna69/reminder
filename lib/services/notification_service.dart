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

  // Task ID와 관련된 모든 알림을 취소합니다. (Payload 기반)
  Future<void> cancelNotificationsForTask(int taskId) async {
    final pendingRequests =
        await _flutterLocalNotificationsPlugin.pendingNotificationRequests();
    for (var request in pendingRequests) {
      if (request.payload == taskId.toString()) {
        await _flutterLocalNotificationsPlugin.cancel(request.id);
      }
    }
  }

  // 알림 예약
  Future<void> scheduleNotification(Task task) async {
    // 0. ID가 없으면 예약 불가
    if (task.id == 0) {
      print("Task ID is 0, cannot schedule notification.");
      return;
    }

    // 1. 이 Task와 관련된 모든 기존 알림을 취소합니다.
    await cancelNotificationsForTask(task.id);

    // 2. 알람이 비활성화 상태이면 여기서 종료
    if (!task.isAlarmEnabled) {
      return;
    }

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

    // 3. 주간 반복 (요일 선택) 처리
    if (task.recurrenceRule.type == RecurrenceType.weekly &&
        task.recurrenceRule.daysOfWeek.isNotEmpty) {
      for (int day in task.recurrenceRule.daysOfWeek) {
        final tz.TZDateTime scheduledDate =
            _nextInstanceOfDay(task.dueDate, day);

        // 각 요일별로 고유 ID 생성 (음수 ID 충돌 방지 및 식별 용이성)
        // Task ID와 요일을 조합하여 고유성을 보장합니다.
        final int notificationId = (task.id * 10) + day;

        await _flutterLocalNotificationsPlugin.zonedSchedule(
          notificationId,
          task.title,
          '매주 ${['월', '화', '수', '목', '금', '토', '일'][day - 1]}요일 반복',
          scheduledDate,
          notificationDetails,
          payload: task.id.toString(), // Task ID를 payload에 저장
          androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
          matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime,
        );
      }
    } else {
      // 4. 그 외(매일, 매월, 매년, 없음) 반복 처리
      final tz.TZDateTime scheduledDate = tz.TZDateTime.from(
        task.dueDate,
        tz.local,
      );

      DateTimeComponents? matchDateTimeComponents;
      switch (task.recurrenceRule.type) {
        case RecurrenceType.daily:
          matchDateTimeComponents = DateTimeComponents.time;
          break;
        case RecurrenceType.monthly:
          matchDateTimeComponents = DateTimeComponents.dayOfMonthAndTime;
          break;
        case RecurrenceType.yearly:
          matchDateTimeComponents = DateTimeComponents.dateAndTime;
          break;
        case RecurrenceType.weekly: // daysOfWeek가 비어있는 경우
        case RecurrenceType.none:
          break;
      }

      await _flutterLocalNotificationsPlugin.zonedSchedule(
        task.id, // 기본 Task ID 사용
        task.title,
        '예정된 할 일이 있습니다.',
        scheduledDate,
        notificationDetails,
        payload: task.id.toString(), // Task ID를 payload에 저장
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        matchDateTimeComponents: matchDateTimeComponents,
      );
    }
  }

  // 특정 요일에 맞는 다음 날짜 및 시간 계산
  tz.TZDateTime _nextInstanceOfDay(DateTime dateTime, int day) {
    tz.TZDateTime scheduledDate = tz.TZDateTime.from(dateTime, tz.local);
    // 현재 날짜의 요일과 목표 요일이 다르면, 다음 날로 이동하며 요일 맞춤
    while (scheduledDate.weekday != day) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }
    // 만약 계산된 날짜/시간이 현재 시간보다 이전이면 다음 주로 점프
    if (scheduledDate.isBefore(tz.TZDateTime.now(tz.local))) {
      scheduledDate = scheduledDate.add(const Duration(days: 7));
    }
    return scheduledDate;
  }
}
