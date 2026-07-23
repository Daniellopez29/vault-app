import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/dimens.dart';
import '../../../core/theme.dart';
import '../domain/entities.dart';
import 'providers.dart';

/// Direcciones de envío del usuario: listar, agregar, eliminar y elegir la
/// predeterminada.
class AddressesPage extends ConsumerWidget {
  const AddressesPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(addressesControllerProvider);

    return Scaffold(
      backgroundColor: VaultColors.background,
      appBar: AppBar(
        title: const Text('Direcciones de envío'),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(VaultSpacing.md),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => _openSheet(context, ref),
                style: ElevatedButton.styleFrom(
                  backgroundColor: VaultColors.primary,
                  padding:
                      const EdgeInsets.symmetric(vertical: VaultSpacing.md),
                ),
                icon: const Icon(Icons.add_location_alt_outlined),
                label: const Text('Nueva dirección'),
              ),
            ),
          ),
          Expanded(
            child: switch (state.status) {
              AddressesStatus.loading =>
                const Center(child: CircularProgressIndicator()),
              AddressesStatus.error => Center(
                  child: Text(
                    state.errorMessage ?? 'Error al cargar tus direcciones',
                    style: const TextStyle(color: VaultColors.textSecondary),
                  ),
                ),
              AddressesStatus.loaded => state.addresses.isEmpty
                  ? const _EmptyAddresses()
                  : ListView.builder(
                      padding: const EdgeInsets.all(VaultSpacing.md),
                      itemCount: state.addresses.length,
                      itemBuilder: (context, index) {
                        final address = state.addresses[index];
                        return _AddressCard(
                          address: address,
                          onSetDefault: () => ref
                              .read(addressesControllerProvider.notifier)
                              .setDefault(address.id),
                          onDelete: () => ref
                              .read(addressesControllerProvider.notifier)
                              .remove(address.id),
                        );
                      },
                    ),
            },
          ),
        ],
      ),
    );
  }

  void _openSheet(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: VaultColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius:
            BorderRadius.vertical(top: Radius.circular(VaultRadius.card)),
      ),
      builder: (_) => _AddressSheet(ref: ref),
    );
  }
}

class _EmptyAddresses extends StatelessWidget {
  const _EmptyAddresses();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(VaultSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.location_off_outlined,
                size: VaultIconSize.xl, color: VaultColors.textSecondary),
            SizedBox(height: VaultSpacing.lg),
            Text(
              'Sin direcciones guardadas',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: VaultColors.textPrimary,
              ),
            ),
            SizedBox(height: VaultSpacing.sm),
            Text(
              'Agrega una dirección para agilizar tus compras.',
              textAlign: TextAlign.center,
              style: TextStyle(color: VaultColors.textSecondary),
            ),
          ],
        ),
      ),
    );
  }
}

class _AddressCard extends StatelessWidget {
  final AddressEntity address;
  final VoidCallback onSetDefault;
  final VoidCallback onDelete;

  const _AddressCard({
    required this.address,
    required this.onSetDefault,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;

    return Container(
      margin: const EdgeInsets.only(bottom: VaultSpacing.md),
      padding: const EdgeInsets.all(VaultSpacing.md),
      decoration: BoxDecoration(
        color: VaultColors.surface,
        borderRadius: VaultRadius.cardBorder,
        border: Border.all(
          color: address.isDefault ? VaultColors.primary : VaultColors.divider,
          width: address.isDefault ? 2 : 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(child: Text(address.label, style: tt.titleMedium)),
              if (address.isDefault)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: VaultSpacing.sm,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: VaultColors.primary,
                    borderRadius: BorderRadius.circular(VaultRadius.sm),
                  ),
                  child: const Text(
                    'Predeterminada',
                    style: TextStyle(color: Colors.white, fontSize: 11),
                  ),
                ),
              IconButton(
                onPressed: onDelete,
                icon: const Icon(
                  Icons.delete_outline,
                  color: VaultColors.textSecondary,
                  size: VaultIconSize.md,
                ),
              ),
            ],
          ),
          Text(address.recipient, style: tt.bodyMedium),
          Text(
            address.summary,
            style: tt.bodyMedium?.copyWith(color: VaultColors.textSecondary),
          ),
          if (address.phone.isNotEmpty)
            Text(
              address.phone,
              style: tt.labelSmall?.copyWith(color: VaultColors.textSecondary),
            ),
          if (!address.isDefault) ...[
            const SizedBox(height: VaultSpacing.sm),
            TextButton(
              onPressed: onSetDefault,
              style: TextButton.styleFrom(
                foregroundColor: VaultColors.primary,
                padding: EdgeInsets.zero,
                minimumSize: const Size(0, 32),
              ),
              child: const Text('Usar como predeterminada'),
            ),
          ],
        ],
      ),
    );
  }
}

/// Formulario para agregar una dirección.
class _AddressSheet extends StatefulWidget {
  final WidgetRef ref;

  const _AddressSheet({required this.ref});

  @override
  State<_AddressSheet> createState() => _AddressSheetState();
}

class _AddressSheetState extends State<_AddressSheet> {
  final _labelController = TextEditingController();
  final _recipientController = TextEditingController();
  final _phoneController = TextEditingController();
  final _streetController = TextEditingController();
  final _cityController = TextEditingController();
  final _stateController = TextEditingController();
  final _postalController = TextEditingController();
  final _referencesController = TextEditingController();
  bool _saving = false;

  @override
  void dispose() {
    _labelController.dispose();
    _recipientController.dispose();
    _phoneController.dispose();
    _streetController.dispose();
    _cityController.dispose();
    _stateController.dispose();
    _postalController.dispose();
    _referencesController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_recipientController.text.trim().isEmpty ||
        _streetController.text.trim().isEmpty) {
      return;
    }
    setState(() => _saving = true);

    final address = AddressEntity(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      label: _labelController.text.trim().isEmpty
          ? 'Dirección'
          : _labelController.text.trim(),
      recipient: _recipientController.text.trim(),
      phone: _phoneController.text.trim(),
      street: _streetController.text.trim(),
      city: _cityController.text.trim(),
      state: _stateController.text.trim(),
      postalCode: _postalController.text.trim(),
      references: _referencesController.text.trim(),
    );

    await widget.ref.read(addressesControllerProvider.notifier).add(address);

    if (mounted) {
      setState(() => _saving = false);
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Padding(
      padding: EdgeInsets.fromLTRB(
        VaultSpacing.lg,
        VaultSpacing.lg,
        VaultSpacing.lg,
        VaultSpacing.lg + bottomInset,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text('Nueva dirección',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
            const SizedBox(height: VaultSpacing.md),
            _field(_labelController, 'Etiqueta', hint: 'Casa, Oficina'),
            _field(_recipientController, 'Quién recibe'),
            _field(_phoneController, 'Teléfono',
                keyboard: TextInputType.phone),
            _field(_streetController, 'Calle y número'),
            _field(_cityController, 'Ciudad'),
            _field(_stateController, 'Estado'),
            _field(_postalController, 'Código postal',
                keyboard: TextInputType.number),
            _field(_referencesController, 'Referencias (opcional)'),
            const SizedBox(height: VaultSpacing.md),
            ElevatedButton(
              onPressed: _saving ? null : _save,
              style: ElevatedButton.styleFrom(
                backgroundColor: VaultColors.primary,
                padding: const EdgeInsets.symmetric(vertical: VaultSpacing.md),
              ),
              child: _saving
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: Colors.white))
                  : const Text('Guardar'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _field(
    TextEditingController controller,
    String label, {
    String? hint,
    TextInputType? keyboard,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: VaultSpacing.md),
      child: TextField(
        controller: controller,
        keyboardType: keyboard,
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          border: const OutlineInputBorder(),
        ),
      ),
    );
  }
}