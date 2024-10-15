import 'package:flutter_local_notifications/flutter_local_notifications.dart';

final NotificationInstance = NotificationManager();

class NotificationManager{
  final FlutterLocalNotificationsPlugin np =FlutterLocalNotificationsPlugin();

  init()async{
    //初始化
    FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

    flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>()?.requestNotificationsPermission();
    var android = const AndroidInitializationSettings("@mipmap/notification");
    await np.initialize(InitializationSettings(android: android),
        onDidReceiveNotificationResponse: onDidResponse);

  }

  void onDidResponse(NotificationResponse response){

  }

  void sendNotification(String title,String body, {int? notificationId, String? params})async{
    var androidNotification = const AndroidNotificationDetails(
      "MomoToki", "问候/生日",importance: Importance.defaultImportance,
    );
    var details = NotificationDetails(android: androidNotification);
    np.show(notificationId??DateTime.now().millisecondsSinceEpoch >> 10, title, body, details);
  }

  ///清除所有通知
  void cleanNotification() {
    np.cancelAll();
  }

  ///清除指定id的通知
  /// `tag`参数指定Android标签。 如果提供，
  /// 那么同时匹配 id 和 tag 的通知将会
  /// 被取消。 `tag` 对其他平台没有影响。
  void cancelNotification(int id, {String? tag}) {
    np.cancel(id, tag: tag);
  }

}