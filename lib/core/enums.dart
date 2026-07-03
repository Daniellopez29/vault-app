enum UserRole {
  general,
  collector,
  restorer;

  String get displayName {
    switch (this) {
      case UserRole.general:    return 'Usuario General';
      case UserRole.collector:  return 'Coleccionista';
      case UserRole.restorer:   return 'Restaurador';
    }
  }

  String get description {
    switch (this) {
      case UserRole.general:
        return 'Gestiona y conserva tus activos personales de valor.';
      case UserRole.collector:
        return 'Administra múltiples activos, estadísticas y tendencias.';
      case UserRole.restorer:
        return 'Ofrece servicios profesionales de restauración y mantenimiento.';
    }
  }

  String get value {
    switch (this) {
      case UserRole.general:   return 'general';
      case UserRole.collector: return 'collector';
      case UserRole.restorer:  return 'restorer';
    }
  }

  static UserRole fromValue(String value) {
    switch (value) {
      case 'collector': return UserRole.collector;
      case 'restorer':  return UserRole.restorer;
      default:          return UserRole.general;
    }
  }
}