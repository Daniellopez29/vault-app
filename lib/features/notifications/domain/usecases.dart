import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
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

class MarkAllNotificationsAsReadUseCase implements UseCase<Unit, NoParams> {
  final NotificationsRepository repository;

  MarkAllNotificationsAsReadUseCase(this.repository);

  @override
  Future<Either<Failure, Unit>> call(NoParams params) {
    return repository.markAllAsRead();
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

class RegisterFcmTokenParams extends Equatable {
  final String token;
  final String? platform;

  const RegisterFcmTokenParams({required this.token, this.platform});

  @override
  List<Object?> get props => [token, platform];
}

class RegisterFcmTokenUseCase implements UseCase<Unit, RegisterFcmTokenParams> {
  final NotificationsRepository repository;

  RegisterFcmTokenUseCase(this.repository);

  @override
  Future<Either<Failure, Unit>> call(RegisterFcmTokenParams params) {
    return repository.registerFcmToken(params.token, platform: params.platform);
  }
}

class DeleteFcmTokenUseCase implements UseCase<Unit, String> {
  final NotificationsRepository repository;

  DeleteFcmTokenUseCase(this.repository);

  @override
  Future<Either<Failure, Unit>> call(String token) {
    return repository.deleteFcmToken(token);
  }
}
