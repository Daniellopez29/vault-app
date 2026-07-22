import 'package:dartz/dartz.dart';
import '../../../core/error.dart';
import '../../../core/usecase.dart';
import 'entities.dart';
import 'repositories.dart';

class GetMyNotificationsUseCase implements UseCase<List<NotificationEntity>, NoParams> {
  final NotificationsRepository repository;

  GetMyNotificationsUseCase(this.repository);

  @override
  Future<Either<Failure, List<NotificationEntity>>> call(NoParams params) {
    return repository.getMyNotifications();
  }
}

class MarkNotificationAsReadUseCase implements UseCase<Unit, String> {
  final NotificationsRepository repository;

  MarkNotificationAsReadUseCase(this.repository);

  @override
  Future<Either<Failure, Unit>> call(String id) {
    return repository.markAsRead(id);
  }
}

class DeleteNotificationUseCase implements UseCase<Unit, String> {
  final NotificationsRepository repository;

  DeleteNotificationUseCase(this.repository);

  @override
  Future<Either<Failure, Unit>> call(String id) {
    return repository.delete(id);
  }
}
