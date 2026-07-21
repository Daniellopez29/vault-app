import 'package:flutter/material.dart';
import '../../../core/dimens.dart';
import '../../../core/theme.dart';
import 'package:go_router/go_router.dart';
import '../../../core/router.dart';
import '../../subscription/domain/entities.dart';

/// Pestaña "Mi negocio". Por ahora es solo el esqueleto visual.
/// El estado real (¿tiene negocio?, sus datos) vivirá en un provider de la
/// feature business cuando conectemos domain/data. Aquí uso un bool local
/// TEMPORAL solo para poder previsualizar ambos estados.
class MyBusinessTab extends StatefulWidget {
  const MyBusinessTab({super.key});

  @override
  State<MyBusinessTab> createState() => _MyBusinessTabState();
}

class _MyBusinessTabState extends State<MyBusinessTab> {
  // TEMPORAL: se reemplaza por el estado del provider (business).
  bool _hasBusiness = false;

  @override
  Widget build(BuildContext context) {
    return _hasBusiness ? _buildAdminView() : _buildEmptyView();
  }

  Widget _buildEmptyView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(VaultSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.storefront_outlined,
                size: VaultIconSize.xl, color: VaultColors.textSecondary),
            const SizedBox(height: VaultSpacing.lg),
            const Text(
              "No tienes un negocio registrado",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: VaultColors.textPrimary,
              ),
            ),
            const SizedBox(height: VaultSpacing.sm),
            const Text(
              "Crea tu negocio para gestionar tus datos, horarios y ubicación.",
              textAlign: TextAlign.center,
              style: TextStyle(color: VaultColors.textSecondary),
            ),
            const SizedBox(height: VaultSpacing.xl),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: VaultColors.primary,
                  padding: const EdgeInsets.symmetric(vertical: VaultSpacing.md),
                ),
                // TEMPORAL: luego navega al formulario real de alta de negocio.
                onPressed: () => setState(() => _hasBusiness = true),
                icon: const Icon(Icons.add),
                label: const Text("Agregar negocio"),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAdminView() {
    return ListView(
      padding: const EdgeInsets.all(VaultSpacing.md),
      children: [
        _section(
          title: "Imágenes",
          child: SizedBox(
            height: 96,
            child: Row(
              children: [
                Expanded(child: _imagePlaceholder()),
                const SizedBox(width: VaultSpacing.sm),
                Expanded(child: _imagePlaceholder()),
                const SizedBox(width: VaultSpacing.sm),
                Expanded(child: _imagePlaceholder(isAdd: true)),
              ],
            ),
          ),
        ),
        _section(
          title: "Dirección",
          child: const TextField(
            decoration: InputDecoration(
              hintText: "Calle, número, colonia",
              border: OutlineInputBorder(),
            ),
          ),
        ),
        _section(
          title: "Días de atención",
          child: Wrap(
            spacing: VaultSpacing.sm,
            children: [
              _dayChip("Lun"),
              _dayChip("Mar"),
              _dayChip("Mié"),
              _dayChip("Jue"),
              _dayChip("Vie"),
              _dayChip("Sáb"),
              _dayChip("Dom"),
            ],
          ),
        ),
        const SizedBox(height: VaultSpacing.lg),
        _BusinessSubscriptionCard(
          onTap: () => context.push(
            AppRoutes.subscription,
            extra: SubscriptionType.business,
          ),
        ),
      ],
    );
  }

  Widget _section({required String title, required Widget child}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: VaultSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              color: VaultColors.textPrimary,
            ),
          ),
          const SizedBox(height: VaultSpacing.sm),
          child,
        ],
      ),
    );
  }

  Widget _imagePlaceholder({bool isAdd = false}) {
    return Container(
      decoration: BoxDecoration(
        color: VaultColors.surface,
        borderRadius: BorderRadius.circular(VaultRadius.sm),
        border: Border.all(color: VaultColors.divider),
      ),
      child: Icon(
        isAdd ? Icons.add_a_photo_outlined : Icons.image_outlined,
        color: VaultColors.textSecondary,
      ),
    );
  }

  Widget _dayChip(String label) {
    return FilterChip(
      label: Text(label),
      selected: false,
      onSelected: (_) {},
    );
  }
}



/// Card de suscripción del negocio, al fondo de la administración.
/// Fondo accent (señal de compra). El texto viene de SubscriptionCopy
/// (dominio), no hardcodeado. Navega a la pantalla de planes de negocio.
class _BusinessSubscriptionCard extends StatelessWidget {
  final VoidCallback onTap;

  const _BusinessSubscriptionCard({required this.onTap});

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;

    return Material(
      color: VaultColors.accent,
      borderRadius: BorderRadius.circular(VaultRadius.card),
      child: InkWell(
        borderRadius: BorderRadius.circular(VaultRadius.card),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(VaultSpacing.lg),
          child: Row(
            children: [
              const Icon(Icons.campaign_outlined,
                  color: Colors.white, size: VaultIconSize.lg),
              const SizedBox(width: VaultSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      SubscriptionCopy.titleFor(SubscriptionType.business),
                      style: tt.titleMedium?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: VaultSpacing.xs),
                    Text(
                      SubscriptionCopy.subtitleFor(SubscriptionType.business),
                      style: tt.bodySmall?.copyWith(color: Colors.white),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: Colors.white),
            ],
          ),
        ),
      ),
    );
  }
}
