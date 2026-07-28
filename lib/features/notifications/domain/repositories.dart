import 'package:dartz/dartz.dart';
import '../../../core/error.dart';
import 'entities.dart';

abstract class NotificationsRepository {
  Future<Either<Failure, List<NotificationEntity>>> getMyNotifications();
  Future<Either<Failure, Unit>> markAsRead(String id);
  Future<Either<Failure, Unit>> markAllAsRead();
  Future<Either<Failure, Unit>> delete(String id);

  /// Notificaciones nuevas en vivo (WebSocket), a medida que llegan.
  Stream<NotificationEntity> incomingNotifications();
}
