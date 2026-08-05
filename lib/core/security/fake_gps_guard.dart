import 'dart:io' show Platform, exit;

import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Envuelve la app (vía el `builder` de MaterialApp.router) y bloquea su uso
/// con un diálogo persistente si el dispositivo tiene activa la depuración
/// USB (ADB) o una app de ubicación simulada (Fake GPS).
///
/// La verificación se hace al arrancar y cada vez que la app vuelve a primer
/// plano (`AppLifecycleState.resumed`) -- así detecta si el usuario activó
/// alguna de las dos cosas mientras la app estaba en segundo plano.
///
/// En `kDebugMode` la verificación se omite por completo: de lo contrario no
/// sería posible depurar la app desde el propio equipo de desarrollo.
class FakeGpsGuard extends StatefulWidget {
  final Widget? child;

  const FakeGpsGuard({super.key, required this.child});

  @override
  State<FakeGpsGuard> createState() => _FakeGpsGuardState();
}

class _FakeGpsGuardState extends State<FakeGpsGuard> with WidgetsBindingObserver {
  static const _channel = MethodChannel('vault/device_integrity');
  bool _dialogShowing = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    if (!kDebugMode) {
      // Se espera al primer frame para tener un BuildContext válido con
      // Navigator ya montado (viene del builder de MaterialApp.router).
      WidgetsBinding.instance.addPostFrameCallback((_) => _checkIntegrity());
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (!kDebugMode && state == AppLifecycleState.resumed) {
      _checkIntegrity();
    }
  }

  Future<void> _checkIntegrity() async {
    bool isSafe = true;
    try {
      isSafe = await _channel.invokeMethod('isDeviceSafe');
    } on PlatformException {
      // Si el canal nativo falla (p. ej. plataforma sin implementación),
      // no se bloquea la app por un error de la propia verificación.
      isSafe = true;
    }

    if (!isSafe) {
      _showBlockingDialog();
    }
  }

  void _showBlockingDialog() {
    if (_dialogShowing || !mounted) return;
    _dialogShowing = true;

    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => PopScope(
        // Bloquea también el botón físico/gesto de "atrás".
        canPop: false,
        child: AlertDialog(
          icon: const Icon(Icons.security, color: Colors.red, size: 48),
          title: const Text('Amenaza de seguridad detectada'),
          content: const Text(
            'Vault no puede ejecutarse en este dispositivo porque se detectó '
                'depuración USB activa o una aplicación de ubicación simulada '
                '(Fake GPS).\n\nDesactiva esa opción en los ajustes del sistema '
                'y vuelve a abrir la aplicación.',
          ),
          actions: [
            TextButton(
              onPressed: _closeApp,
              child: const Text('Cerrar aplicación'),
            ),
          ],
        ),
      ),
    ).then((_) => _dialogShowing = false);
  }

  void _closeApp() {
    // SystemNavigator.pop() es el cierre "limpio" recomendado en Android
    // (respeta el ciclo de vida de la Activity). En iOS/otras plataformas
    // no hay equivalente estándar, así que se usa exit(0) como respaldo.
    if (Platform.isAndroid) {
      SystemNavigator.pop();
    } else {
      exit(0);
    }
  }

  @override
  Widget build(BuildContext context) {
    return widget.child ?? const SizedBox.shrink();
  }
}