import 'package:lestari_flutter/models/notification_model.dart';

abstract class BaseNotificationsRepository {
  Future<List<NotificationModel>> getNotifications(String uid);
  Future<void> updateNotification(NotificationModel notificationModel, String uid);
}
