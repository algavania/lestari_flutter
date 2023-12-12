import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:lestari_flutter/app/repositories/notifications/base_notification_repository.dart';
import 'package:lestari_flutter/models/notification_model.dart';

class NotificationsRepository extends BaseNotificationsRepository {
  @override
  Future<List<NotificationModel>> getNotifications(String uid) async {
    List<NotificationModel> models = [];
    try {
      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .collection('notifications')
          .orderBy('created_at', descending: true)
          .get();
      for (var element in snapshot.docs) {
        Map<String, dynamic> map = element.data() as Map<String, dynamic>;
        map['id'] = element.id;
        NotificationModel model = NotificationModel.fromMap(map);
        models.add(model);
      }
      return models;
    } catch (e) {
      throw e.toString();
    }
  }

  @override
  Future<void> updateNotification(NotificationModel notificationModel, String uid) async {
    await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('notifications')
        .doc(notificationModel.id)
        .update(notificationModel.toMap());
  }
}