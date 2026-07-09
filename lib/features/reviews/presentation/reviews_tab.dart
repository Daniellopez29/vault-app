import 'package:flutter/material.dart';
import '../../../core/theme.dart';

class ReviewsTab extends StatelessWidget {
  const ReviewsTab({super.key});

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.star_outline, size: 64, color: VaultColors.textSecondary),
          const SizedBox(height: 16),
          Text(
            'Mis Reseñas',
            style: tt.headlineMedium,
          ),
          const SizedBox(height: 8),
          Text(
            'Aquí verás las valoraciones\nque tus clientes te han dejado',
            textAlign: TextAlign.center,
            style: tt.bodyMedium,
          ),
        ],
      ),
    );
  }
}