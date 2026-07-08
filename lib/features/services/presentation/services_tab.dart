import 'package:flutter/material.dart';
import '../../../core/theme.dart';

class ServicesTab extends StatelessWidget {
  const ServicesTab({super.key});

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.build_outlined, size: 64, color: VaultColors.textSecondary),
          const SizedBox(height: 16),
          Text(
            'Mis Servicios',
            style: tt.headlineMedium,
          ),
          const SizedBox(height: 8),
          Text(
            'Próximamente podrás publicar\ntus servicios profesionales aquí',
            textAlign: TextAlign.center,
            style: tt.bodyMedium,
          ),
        ],
      ),
    );
  }
}