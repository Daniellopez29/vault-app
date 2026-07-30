import 'package:dartz/dartz.dart';
import '../../../core/error.dart';
import '../../../core/realtime_socket.dart';
import '../domain/entities.dart';
import '../domain/repositories.dart';
import 'datasources.dart';
import 'models.dart';

class NotificationsRepositoryImpl implements NotificationsRepository {
  final NotificationsRemoteDataSource remoteDataSource;
  final RealtimeSocket _ws;

  NotificationsRepositoryImpl({required this.remoteDataSource, required RealtimeSocket ws})
      : _ws = ws;

  @override
  Stream<NotificationEntity> incomingNotifications() {
    return _ws.events().where((e) => e['event'] == 'notification').map(NotificationModel.fromJson);
  }

  @override
  Future<Either<Failure, List<NotificationEntity>>> getMyNotifications() async {
    try {
      final list = await remoteDataSource.getMyNotifications();
      return Right(list);
    } on Failure catch (f) {
      return Left(f);
    } catch (_) {
      return const Left(ServerFailure('Error al cargar las notificaciones.'));
    }
  }

  @override
  Future<Either<Failure, Unit>> markAsRead(String id) async {
    try {
      await remoteDataSource.markAsRead(id);
      return const Right(unit);
    } on Failure catch (f) {
      return Left(f);
    } catch (_) {
      return const Left(ServerFailure('Error al marcar la notificación como leída.'));
    }
  }

  @override
  Future<Either<Failure, Unit>> markAllAsRead() async {
    try {
      await remoteDataSource.markAllAsRead();
      return const Right(unit);
    } on Failure catch (f) {
      return Left(f);
    } catch (_) {
      return const Left(ServerFailure('Error al marcar las notificaciones como leídas.'));
    }
  }

  @override
  Future<Either<Failure, Unit>> delete(String id) async {
    try {
      await remoteDataSource.delete(id);
      return const Right(unit);
    } on Failure catch (f) {
      return Left(f);
    } catch (_) {
      return const Left(ServerFailure('Error al eliminar la notificación.'));
    }
  }

  @override
  Future<Either<Failure, Unit>> registerFcmToken(String token, {String? platform}) async {
    try {
      await remoteDataSource.registerFcmToken(token, platform: platform);
      return const Right(unit);
    } on Failure catch (f) {
      return Left(f);
    } catch (_) {
      return const Left(ServerFailure('Error al registrar el token de notificaciones.'));
    }
  }

  @override
  Future<Either<Failure, Unit>> deleteFcmToken(String token) async {
    try {
      await remoteDataSource.deleteFcmToken(token);
      return const Right(unit);
    } on Failure catch (f) {
      return Left(f);
    } catch (_) {
      return const Left(ServerFailure('Error al eliminar el token de notificaciones.'));
    }
  }
}
