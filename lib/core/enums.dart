enum UserRole {
  user,
  seller,
  restorer,
  service;

  String get displayName {
    switch (this) {
      case UserRole.user:     return 'Coleccionista';
      case UserRole.seller:   return 'Vendedor';
      case UserRole.restorer: return 'Restaurador';
      case UserRole.service:  return 'Servicio';
    }
  }

  String get description {
    switch (this) {
      case UserRole.user:
        return 'Administra tu colección, historial y comunidad.';
      case UserRole.seller:
        return 'Publica y vende tus activos de valor en el marketplace.';
      case UserRole.restorer:
        return 'Ofrece servicios de mantenimiento y restauración.';
      case UserRole.service:
        return 'Taller o negocio especializado en activos de valor.';
    }
  }

  String get value {
    switch (this) {
      case UserRole.user:     return 'user';
      case UserRole.seller:   return 'seller';
      case UserRole.restorer: return 'restorer';
      case UserRole.service:  return 'service';
    }
  }

  static UserRole fromValue(String value) {
    switch (value) {
      case 'seller':   return UserRole.seller;
      case 'restorer': return UserRole.restorer;
      case 'service':  return UserRole.service;
    // Compatibilidad con cuentas previas ('general'/'collector' = Coleccionista).
      case 'user':
      case 'general':
      case 'collector':
      default:
        return UserRole.user;
    }
  }
}