/// Convierte una fecha ISO 8601 (como la que devuelve el API de Go en
/// created_at) a un texto relativo simple en español.
String timeAgoFrom(String isoDate) {
  final DateTime? date = DateTime.tryParse(isoDate);
  if (date == null) return '';

  final diff = DateTime.now().toUtc().difference(date.toUtc());
  if (diff.inSeconds < 60) return 'Ahora';
  if (diff.inMinutes < 60) return 'hace ${diff.inMinutes} min';
  if (diff.inHours < 24) return 'hace ${diff.inHours} h';
  if (diff.inDays < 7) return 'hace ${diff.inDays} d';
  if (diff.inDays < 30) return 'hace ${(diff.inDays / 7).floor()} sem';
  return 'hace ${(diff.inDays / 30).floor()} mes';
}
