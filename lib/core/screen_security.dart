import 'package:flutter/services.dart';

/// Activa/desactiva FLAG_SECURE en Android para impedir capturas de
/// pantalla y bloquear la miniatura en el selector de apps recientes.
///
/// No tiene efecto en plataformas sin implementación nativa (iOS, web,
/// desktop): las llamadas fallan en silencio.
class ScreenSecurity {
  static const _channel = MethodChannel('com.example.vault_app/security');

  static Future<void> enable() async {
    try {
      await _channel.invokeMethod('enableSecureMode');
    } catch (_) {
      // Plataforma sin soporte nativo: no-op.
    }
  }

  static Future<void> disable() async {
    try {
      await _channel.invokeMethod('disableSecureMode');
    } catch (_) {
      // Plataforma sin soporte nativo: no-op.
    }
  }
}
