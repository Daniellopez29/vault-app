import 'package:equatable/equatable.dart';

/// Un aviso del usuario (asset publicado, comentario, review, etc.).
/// `type`/`subtype` son los que define `api/` (p.ej. type="post",
/// subtype="like"); la UI solo los usa para elegir el ícono.
class NotificationEntity extends Equatable {
  final String id;
  final String type;
  final String subtype;
  final String title;
  final String body;
  final bool read;
  final String createdAt;

  const NotificationEntity({
    required this.id,
    required this.type,
    required this.subtype,
    required this.title,
    required this.body,
    required this.read,
    required this.createdAt,
  });

  NotificationEntity copyWith({bool? read}) {
    return NotificationEntity(
      id: id,
      type: type,
      subtype: subtype,
      title: title,
      body: body,
      read: read ?? this.read,
      createdAt: createdAt,
    );
  }

  @override
  List<Object?> get props => [id, type, subtype, title, body, read, createdAt];
}
