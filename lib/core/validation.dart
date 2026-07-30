final RegExp _emailPattern =
    RegExp(r'^[a-zA-Z0-9._%+\-]+@[a-zA-Z0-9.\-]+\.[a-zA-Z]{2,}$');

/// Solo permite caracteres válidos de correo: letras, números, punto, guión,
/// guión bajo, arroba. Rechaza llaves, paréntesis, espacios, etc. -- mismo
/// patrón que `core/validation` en api/ (ver ese paquete: antes solo se
/// checaba que el correo contuviera un "@", así que cualquier caracter
/// pasaba, incluyendo cosas como "<script>...").
bool isValidEmail(String email) {
  final trimmed = email.trim();
  if (trimmed.isEmpty) return false;
  return _emailPattern.hasMatch(trimmed);
}
