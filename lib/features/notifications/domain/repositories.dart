import 'package:dartz/dartz.dart';
import '../../../core/error.dart';
import 'entities.dart';

abstract class NotificationsRepository {
  Future<Either<Failure, List<NotificationEntity>>> getMyNotifications();
  Future<Either<Failure, Unit>> markAsRead(String id);
  Future<Either<Failure, Unit>> delete(String id);
}
