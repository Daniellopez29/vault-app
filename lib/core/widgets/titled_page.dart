import 'package:flutter/material.dart';
import '../theme.dart';

/// Envuelve un contenido que no trae Scaffold propio para poder abrirlo como
/// pantalla con título y botón de regreso.
///
/// Útil para vistas que antes vivían dentro del IndexedStack del shell y
/// ahora se navegan desde el Perfil.
class TitledPage extends StatelessWidget {
  final String title;
  final Widget child;

  const TitledPage({super.key, required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: VaultColors.background,
      appBar: AppBar(
        title: Text(title),
        centerTitle: true,
      ),
      body: SafeArea(child: child),
    );
  }
}
