part of 'notifications_bloc.dart';

abstract class NotificationsEvent extends Equatable {
  const NotificationsEvent();
}

class GetNotificationsEvent extends NotificationsEvent {
  final String uid;
  const GetNotificationsEvent(this.uid);

  @override
  List<Object?> get props => [uid];
}