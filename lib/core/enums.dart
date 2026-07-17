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

  /// Debe coincidir exactamente con el CHECK constraint de `users.role`
  /// en la base de datos real (init.sql): usuario/vendedor/restaurador/servicio.
  String get value {
    switch (this) {
      case UserRole.user:     return 'usuario';
      case UserRole.seller:   return 'vendedor';
      case UserRole.restorer: return 'restaurador';
      case UserRole.service:  return 'servicio';
    }
  }

  static UserRole fromValue(String value) {
    switch (value) {
      case 'vendedor':    return UserRole.seller;
      case 'restaurador': return UserRole.restorer;
      case 'servicio':    return UserRole.service;
    // Compatibilidad con datos previos (fixtures/Firebase en inglés).
      case 'seller':   return UserRole.seller;
      case 'restorer': return UserRole.restorer;
      case 'service':  return UserRole.service;
      case 'usuario':
      case 'user':
      case 'general':
      case 'collector':
      default:
        return UserRole.user;
    }
  }
}