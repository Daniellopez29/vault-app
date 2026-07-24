import 'package:safe_device/safe_device.dart';

class SecurityService {
  static Future<bool> isDeviceSafe({bool isTestingFakeGps = true}) async {
    try {
      bool isJailBroken = await SafeDevice.isJailBroken;
      bool isMockLocation = await SafeDevice.isMockLocation;
      bool isRealDevice = await SafeDevice.isRealDevice;
      bool isDevelopmentMode = await SafeDevice.isDevelopmentModeEnable;

      print('--- [DIAGNÓSTICO DE SEGURIDAD] ---');
      print('1. Rooteado (Jailbreak/Root): $isJailBroken');
      print('2. Ubicación Falsa (Mock Location): $isMockLocation');
      print('3. Dispositivo Real: $isRealDevice');
      print('4. Modo Depuración/Desarrollador: $isDevelopmentMode');
      print('----------------------------------');

      // Si estamos en modo prueba, ignoramos temporalmente la depuración USB/dispositivo real
      // para enfocarnos exclusivamente en la detección de Fake GPS.
      if (isTestingFakeGps) {
        if (isMockLocation) {
          print('🚨 AMENAZA DETECTADA: Ubicación Falsa (Fake GPS)');
          return false;
        }
        return true;
      }

      // Lógica de Producción Final:
      if (isJailBroken || isMockLocation || !isRealDevice || isDevelopmentMode) {
        return false;
      }

      return true;
    } catch (e) {
      print('Error evaluando la seguridad del dispositivo: $e');
      return false; // Ante cualquier falla imprevista, bloquea por seguridad
    }
  }
}