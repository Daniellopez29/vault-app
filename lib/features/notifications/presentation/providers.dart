import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/providers.dart';
import '../../../core/usecase.dart';
import '../data/datasources.dart';
import '../data/repositories.dart';
import '../domain/entities.dart';
import '../domain/repositories.dart';
import '../domain/usecases.dart';

final notificationsRepositoryProvider = Provider<NotificationsRepository>((ref) {
  return NotificationsRepositoryImpl(
    remoteDataSource: NotificationsRemoteDataSourceImpl(ref.read(apiClientProvider)),
    ws: ref.read(realtimeSocketProvider),
  );
});

final getMyNotificationsUseCaseProvider = Provider<GetMyNotificationsUseCase>((ref) {
  return GetMyNotificationsUseCase(ref.read(notificationsRepositoryProvider));
});

final markNotificationAsReadUseCaseProvider = Provider<MarkNotificationAsReadUseCase>((ref) {
  return MarkNotificationAsReadUseCase(ref.read(notificationsRepositoryProvider));
});

final deleteNotificationUseCaseProvider = Provider<DeleteNotificationUseCase>((ref) {
  return DeleteNotificationUseCase(ref.read(notificationsRepositoryProvider));
});

final markAllNotificationsAsReadUseCaseProvider = Provider<MarkAllNotificationsAsReadUseCase>((ref) {
  return MarkAllNotificationsAsReadUseCase(ref.read(notificationsRepositoryProvider));
});

enum NotificationsStatus { loading, loaded, error }

class NotificationsState {
  final NotificationsStatus status;
  final List<NotificationEntity> notifications;
  final String? errorMessage;

  const NotificationsState({
    this.status = NotificationsStatus.loading,
    this.notifications = const [],
    this.errorMessage,
  });

  NotificationsState copyWith({
    NotificationsStatus? status,
    List<NotificationEntity>? notifications,
    String? errorMessage,
  }) {
    return NotificationsState(
      status: status ?? this.status,
      notifications: notifications ?? this.notifications,
      errorMessage: errorMessage,
    );
  }
}

class NotificationsController extends StateNotifier<NotificationsState> {
  final GetMyNotificationsUseCase _getMyNotifications;
  final MarkNotificationAsReadUseCase _markAsRead;
  final MarkAllNotificationsAsReadUseCase _markAllAsRead;
  final DeleteNotificationUseCase _delete;
  StreamSubscription<NotificationEntity>? _subscription;

  NotificationsController(
    this._getMyNotifications,
    this._markAsRead,
    this._markAllAsRead,
    this._delete,
    NotificationsRepository repository,
  ) : super(const NotificationsState()) {
    load();
    // Recarga la lista en cuanto llega una notificación nueva por
    // WebSocket -- antes esto solo se refrescaba al reabrir la pantalla.
    _subscription = repository.incomingNotifications().listen((_) => load());
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  Future<void> load() async {
    state = state.copyWith(status: NotificationsStatus.loading);
    final result = await _getMyNotifications(const NoParams());
    result.fold(
      (failure) => state = state.copyWith(
        status: NotificationsStatus.error,
        errorMessage: failure.message,
      ),
      (notifications) => state = state.copyWith(
        status: NotificationsStatus.loaded,
        notifications: notifications,
      ),
    );
  }

  Future<void> markAsRead(String id) async {
    final current = state.notifications;
    final index = current.indexWhere((n) => n.id == id);
    if (index < 0 || current[index].read) return;

    final optimistic = [...current];
    optimistic[index] = optimistic[index].copyWith(read: true);
    state = state.copyWith(notifications: optimistic);

    final result = await _markAsRead(id);
    result.fold(
      (failure) => state = state.copyWith(notifications: current, errorMessage: failure.message),
      (_) {},
    );
  }

  /// Marca todo lo pendiente como leído -- se llama al abrir la pantalla,
  /// para que las notificaciones viejas dejen de contarse como pendientes
  /// (badge de la barra inferior) sin tener que tocarlas una por una.
  Future<void> markAllAsRead() async {
    final current = state.notifications;
    if (current.every((n) => n.read)) return;

    final optimistic = current.map((n) => n.copyWith(read: true)).toList();
    state = state.copyWith(notifications: optimistic);

    final result = await _markAllAsRead(const NoParams());
    result.fold(
      (failure) => state = state.copyWith(notifications: current, errorMessage: failure.message),
      (_) {},
    );
  }

  Future<void> delete(String id) async {
    final current = state.notifications;
    state = state.copyWith(notifications: current.where((n) => n.id != id).toList());

    final result = await _delete(id);
    result.fold(
      (failure) => state = state.copyWith(notifications: current, errorMessage: failure.message),
      (_) {},
    );
  }
}

final notificationsControllerProvider =
    StateNotifierProvider<NotificationsController, NotificationsState>((ref) {
  return NotificationsController(
    ref.read(getMyNotificationsUseCaseProvider),
    ref.read(markNotificationAsReadUseCaseProvider),
    ref.read(markAllNotificationsAsReadUseCaseProvider),
    ref.read(deleteNotificationUseCaseProvider),
    ref.read(notificationsRepositoryProvider),
  );
});
