import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/dimens.dart';
import '../../../core/router.dart';
import '../../../core/theme.dart';
import 'providers.dart';

/// Paso de direccion dentro del flujo de compra.
///
/// Si el usuario ya tiene direcciones, elige una; si no, la registra aqui
/// mismo antes de continuar al pago.
class CheckoutAddressPage extends ConsumerStatefulWidget {
  const CheckoutAddressPage({super.key});

  @override
  ConsumerState<CheckoutAddressPage> createState() =>
      _CheckoutAddressPageState();
}

class _CheckoutAddressPageState extends ConsumerState<CheckoutAddressPage> {
  String? _selectedId;

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final state = ref.watch(addressesControllerProvider);

    // Preselecciona la predeterminada, o la primera disponible.
    if (_selectedId == null && state.addresses.isNotEmpty) {
      final defaultAddress = state.addresses.firstWhere(
        (a) => a.isDefault,
        orElse: () => state.addresses.first,
      );
      _selectedId = defaultAddress.id;
    }

    return Scaffold(
      backgroundColor: VaultColors.background,
      appBar: AppBar(
        title: const Text('Direccion de entrega'),
        centerTitle: true,
      ),
      body: switch (state.status) {
        AddressesStatus.loading => const Center(
          child: CircularProgressIndicator(),
        ),
        AddressesStatus.error => Center(
          child: Text(
            state.errorMessage ?? 'Error al cargar tus direcciones',
            style: TextStyle(color: VaultColors.textSecondary),
          ),
        ),
        AddressesStatus.loaded =>
          state.addresses.isEmpty
              ? _EmptyPrompt(onAdd: () => context.push(AppRoutes.addresses))
              : ListView(
                  padding: const EdgeInsets.all(VaultSpacing.md),
                  children: [
                    Text(
                      'Elige donde recibir tu pedido',
                      style: tt.titleMedium,
                    ),
                    const SizedBox(height: VaultSpacing.md),
                    ...state.addresses.map(
                      (address) => _AddressOption(
                        label: address.label,
                        recipient: address.recipient,
                        summary: address.summary,
                        selected: address.id == _selectedId,
                        onTap: () => setState(() => _selectedId = address.id),
                      ),
                    ),
                    const SizedBox(height: VaultSpacing.sm),
                    TextButton.icon(
                      onPressed: () => context.push(AppRoutes.addresses),
                      style: TextButton.styleFrom(
                        foregroundColor: VaultColors.primary,
                      ),
                      icon: const Icon(Icons.add),
                      label: const Text('Agregar otra direccion'),
                    ),
                  ],
                ),
      },
      bottomNavigationBar: state.addresses.isEmpty
          ? null
          : SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(VaultSpacing.md),
                child: ElevatedButton(
                  onPressed: _selectedId == null
                      ? null
                      : () => context.push(AppRoutes.paymentMethod),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: VaultColors.accent,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      vertical: VaultSpacing.md,
                    ),
                  ),
                  child: const Text('Continuar al pago'),
                ),
              ),
            ),
    );
  }
}

/// Cuando no hay ninguna direccion registrada.
class _EmptyPrompt extends StatelessWidget {
  final VoidCallback onAdd;

  const _EmptyPrompt({required this.onAdd});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(VaultSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.location_off_outlined,
              size: VaultIconSize.xl,
              color: VaultColors.textSecondary,
            ),
            const SizedBox(height: VaultSpacing.lg),
            Text(
              'Necesitamos una direccion',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: VaultColors.textPrimary,
              ),
            ),
            const SizedBox(height: VaultSpacing.sm),
            Text(
              'Registra donde quieres recibir tu pedido para continuar.',
              textAlign: TextAlign.center,
              style: TextStyle(color: VaultColors.textSecondary),
            ),
            const SizedBox(height: VaultSpacing.xl),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: onAdd,
                style: ElevatedButton.styleFrom(
                  backgroundColor: VaultColors.primary,
                  padding: const EdgeInsets.symmetric(
                    vertical: VaultSpacing.md,
                  ),
                ),
                icon: const Icon(Icons.add_location_alt_outlined),
                label: const Text('Agregar direccion'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Opcion seleccionable de direccion, con el mismo lenguaje visual que la
/// seleccion de metodo de pago.
class _AddressOption extends StatelessWidget {
  final String label;
  final String recipient;
  final String summary;
  final bool selected;
  final VoidCallback onTap;

  const _AddressOption({
    required this.label,
    required this.recipient,
    required this.summary,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: VaultSpacing.md),
        padding: const EdgeInsets.all(VaultSpacing.md),
        decoration: BoxDecoration(
          color: VaultColors.surface,
          borderRadius: VaultRadius.cardBorder,
          border: Border.all(
            color: selected ? VaultColors.accent : VaultColors.divider,
            width: selected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label, style: tt.titleMedium),
                  Text(recipient, style: tt.bodyMedium),
                  Text(
                    summary,
                    style: tt.labelSmall?.copyWith(
                      color: VaultColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              selected
                  ? Icons.radio_button_checked
                  : Icons.radio_button_unchecked,
              color: selected ? VaultColors.accent : VaultColors.textSecondary,
              size: VaultIconSize.md,
            ),
          ],
        ),
      ),
    );
  }
}
