import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:lestari_flutter/app/repositories/notifications/notification_repository.dart';
import 'package:lestari_flutter/models/notification_model.dart';

part 'notifications_event.dart';
part 'notifications_state.dart';

class NotificationsBloc extends Bloc<NotificationsEvent, NotificationsState> {
  final NotificationsRepository _repository;

  NotificationsBloc(this._repository) : super(NotificationsInitial()) {
    on<GetNotificationsEvent>(_getNotifications);
  }

  Future<void> _getNotifications(GetNotificationsEvent event, Emitter<NotificationsState> emit) async {
    emit(NotificationsLoading());
    try {
      List<NotificationModel> models = await _repository.getNotifications(event.uid);
      emit(NotificationsLoaded(models));
    } catch (e) {
      emit(NotificationsError(e.toString()));
    }
  }

}
