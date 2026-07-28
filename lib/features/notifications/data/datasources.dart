import '../../../core/api_client.dart';
import '../../../core/error.dart';
import 'models.dart';

abstract class NotificationsRemoteDataSource {
  Future<List<NotificationModel>> getMyNotifications();
  Future<void> markAsRead(String id);
  Future<void> markAllAsRead();
  Future<void> delete(String id);
}

class NotificationsRemoteDataSourceImpl implements NotificationsRemoteDataSource {
  final ApiClient _client;

  NotificationsRemoteDataSourceImpl(this._client);

  @override
  Future<List<NotificationModel>> getMyNotifications() async {
    try {
      final body = await _client.get('/notifications');
      final list = body as List<dynamic>? ?? const [];
      return list.map((e) => NotificationModel.fromJson(e as Map<String, dynamic>)).toList();
    } on Failure {
      rethrow;
    } catch (e) {
      throw ServerFailure('Error al cargar las notificaciones: $e');
    }
  }

  @override
  Future<void> markAsRead(String id) async {
    try {
      await _client.put('/notifications/$id/read');
    } on Failure {
      rethrow;
    } catch (e) {
      throw ServerFailure('Error al marcar la notificación como leída: $e');
    }
  }

  @override
  Future<void> markAllAsRead() async {
    try {
      await _client.put('/notifications/read-all');
    } on Failure {
      rethrow;
    } catch (e) {
      throw ServerFailure('Error al marcar las notificaciones como leídas: $e');
    }
  }

  @override
  Future<void> delete(String id) async {
    try {
      await _client.delete('/notifications/$id');
    } on Failure {
      rethrow;
    } catch (e) {
      throw ServerFailure('Error al eliminar la notificación: $e');
    }
  }
}
