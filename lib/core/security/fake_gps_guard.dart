import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class FakeGpsGuard extends StatefulWidget {
  final Widget child;

  const FakeGpsGuard({super.key, required this.child});

  @override
  State<FakeGpsGuard> createState() => _FakeGpsGuardState();
}

class _FakeGpsGuardState extends State<FakeGpsGuard> with WidgetsBindingObserver {
  static const _channel = MethodChannel('vault/device_integrity');
  bool _isSafe = true;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _checkIntegrity();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Al regresar a la app, vuelve a evaluar la seguridad
    if (state == AppLifecycleState.resumed) {
      _checkIntegrity();
    }
  }

  Future<void> _checkIntegrity() async {
    setState(() => _isLoading = true);
    try {
      // ⚠️ AQUÍ: Debe llamar a 'isDeviceSafe', NO solo a 'isFakeGpsEnabled'
      final bool isDeviceSafe = await _channel.invokeMethod('isDeviceSafe');
      setState(() {
        _isSafe = isDeviceSafe;
        _isLoading = false;
      });
    } on PlatformException catch (_) {
      setState(() {
        _isSafe = true;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Scaffold(
          body: Center(child: CircularProgressIndicator()),
        ),
      );
    }

    if (!_isSafe) {
      return MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Scaffold(
          backgroundColor: Colors.black,
          body: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.security, color: Colors.red, size: 80),
                const SizedBox(height: 20),
                const Text(
                  'Amenaza de Seguridad Detectada',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Vault no puede ejecutarse si el dispositivo tiene activada la depuración USB o aplicaciones de ubicación simulada (Fake GPS).',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey, fontSize: 14),
                ),
                const SizedBox(height: 30),
                ElevatedButton(
                  onPressed: _checkIntegrity,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  ),
                  child: const Text('Volver a comprobar', style: TextStyle(color: Colors.white)),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return widget.child;
  }
}