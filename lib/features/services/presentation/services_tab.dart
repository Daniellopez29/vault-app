import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/dimens.dart';
import '../../../core/router.dart';
import '../../../core/theme.dart';
import '../../business/domain/entities.dart';
import '../../business/presentation/providers.dart';

/// Servicios que el usuario ofrece a través de su negocio.
///
/// Cualquiera puede registrar un negocio y publicar servicios, sin importar
/// su rol -- pero primero hace falta el negocio (el catálogo vive bajo
/// `businesses/{id}/services`, ver `businessservices` en `api/`).
class ServicesTab extends ConsumerWidget {
  const ServicesTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final businessState = ref.watch(businessControllerProvider);

    switch (businessState.status) {
      case BusinessStatus.loading:
        return const Center(child: CircularProgressIndicator());
      case BusinessStatus.error:
        return Center(
          child: Text(businessState.errorMessage ?? 'Error al cargar tu negocio'),
        );
      case BusinessStatus.loaded:
        final business = businessState.business;
        if (business == null) {
          return _NoBusinessPrompt(
            onRegister: () => context.push(AppRoutes.registerBusiness),
          );
        }
        return _ServicesList(businessId: business.id);
    }
  }
}

class _NoBusinessPrompt extends StatelessWidget {
  final VoidCallback onRegister;

  const _NoBusinessPrompt({required this.onRegister});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(VaultSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.storefront_outlined, size: VaultIconSize.xl, color: VaultColors.textSecondary),
            const SizedBox(height: VaultSpacing.lg),
            const Text(
              'Registra tu negocio para publicar servicios',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: VaultSpacing.sm),
            const Text(
              'Tu catálogo de servicios (limpieza, restauración, reparación) '
              'vive dentro de tu negocio en Vault.',
              textAlign: TextAlign.center,
              style: TextStyle(color: VaultColors.textSecondary),
            ),
            const SizedBox(height: VaultSpacing.xl),
            ElevatedButton.icon(
              onPressed: onRegister,
              style: ElevatedButton.styleFrom(
                backgroundColor: VaultColors.primary,
                padding: const EdgeInsets.symmetric(vertical: VaultSpacing.md, horizontal: VaultSpacing.lg),
              ),
              icon: const Icon(Icons.add),
              label: const Text('Registrar negocio'),
            ),
          ],
        ),
      ),
    );
  }
}

class _ServicesList extends ConsumerWidget {
  final String businessId;

  const _ServicesList({required this.businessId});

  void _openSheet(BuildContext context, WidgetRef ref, {BusinessServiceEntity? service}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: VaultColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(VaultRadius.card)),
      ),
      builder: (_) => _ServiceSheet(businessId: businessId, ref: ref, existing: service),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(businessServicesControllerProvider(businessId));

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(VaultSpacing.md),
          child: SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => _openSheet(context, ref),
              style: ElevatedButton.styleFrom(
                backgroundColor: VaultColors.primary,
                padding: const EdgeInsets.symmetric(vertical: VaultSpacing.md),
              ),
              icon: const Icon(Icons.add),
              label: const Text('Nuevo servicio'),
            ),
          ),
        ),
        Expanded(
          child: state.status == BusinessServicesStatus.loading
              ? const Center(child: CircularProgressIndicator())
              : state.services.isEmpty
                  ? const _EmptyServices()
                  : ListView.builder(
                      padding: const EdgeInsets.all(VaultSpacing.md),
                      itemCount: state.services.length,
                      itemBuilder: (context, index) {
                        final service = state.services[index];
                        return _ServiceCard(
                          service: service,
                          onTap: () => _openSheet(context, ref, service: service),
                          onDelete: () => ref
                              .read(businessServicesControllerProvider(businessId).notifier)
                              .removeService(service.id),
                        );
                      },
                    ),
        ),
      ],
    );
  }
}

class _EmptyServices extends StatelessWidget {
  const _EmptyServices();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(VaultSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.build_outlined,
                size: VaultIconSize.xl, color: VaultColors.textSecondary),
            SizedBox(height: VaultSpacing.lg),
            Text(
              'Aún no ofreces servicios',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: VaultColors.textPrimary,
              ),
            ),
            SizedBox(height: VaultSpacing.sm),
            Text(
              'Publica lo que sabes hacer: limpieza, restauración, reparación. '
              'Otros usuarios podrán encontrarte.',
              textAlign: TextAlign.center,
              style: TextStyle(color: VaultColors.textSecondary),
            ),
          ],
        ),
      ),
    );
  }
}

class _ServiceCard extends StatelessWidget {
  final BusinessServiceEntity service;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const _ServiceCard({
    required this.service,
    required this.onTap,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;

    return Container(
      margin: const EdgeInsets.only(bottom: VaultSpacing.md),
      decoration: BoxDecoration(
        color: VaultColors.surface,
        borderRadius: VaultRadius.cardBorder,
        border: Border.all(color: VaultColors.divider),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(VaultSpacing.md),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(service.title, style: tt.titleMedium),
                    if (service.description.isNotEmpty) ...[
                      const SizedBox(height: VaultSpacing.xs),
                      Text(
                        service.description,
                        style: tt.bodyMedium?.copyWith(
                          color: VaultColors.textSecondary,
                        ),
                      ),
                    ],
                    const SizedBox(height: VaultSpacing.sm),
                    Text(
                      service.price > 0
                          ? '\$${service.price.toStringAsFixed(0)}'
                          : 'A convenir',
                      style: tt.titleMedium?.copyWith(
                        color: VaultColors.accent,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
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
        ),
      ),
    );
  }
}

/// Formulario para publicar o editar un servicio.
class _ServiceSheet extends StatefulWidget {
  final String businessId;
  final WidgetRef ref;
  final BusinessServiceEntity? existing;

  const _ServiceSheet({
    required this.businessId,
    required this.ref,
    this.existing,
  });

  @override
  State<_ServiceSheet> createState() => _ServiceSheetState();
}

class _ServiceSheetState extends State<_ServiceSheet> {
  late final TextEditingController _titleController;
  late final TextEditingController _descController;
  late final TextEditingController _priceController;
  bool _saving = false;

  bool get _isEditing => widget.existing != null;

  @override
  void initState() {
    super.initState();
    final e = widget.existing;
    _titleController = TextEditingController(text: e?.title ?? '');
    _descController = TextEditingController(text: e?.description ?? '');
    _priceController = TextEditingController(
      text: (e != null && e.price > 0) ? e.price.toStringAsFixed(0) : '',
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final title = _titleController.text.trim();
    final description = _descController.text.trim();
    final price = double.tryParse(_priceController.text.trim()) ?? 0;
    // El backend exige precio > 0 (BusinessServiceRequest.Validate en
    // api/) -- a diferencia del catálogo viejo, ya no admite "a convenir".
    if (title.isEmpty || price <= 0) return;
    setState(() => _saving = true);

    final notifier =
        widget.ref.read(businessServicesControllerProvider(widget.businessId).notifier);

    if (_isEditing) {
      await notifier.updateService(
        widget.existing!.id,
        title: title,
        description: description,
        price: price,
      );
    } else {
      await notifier.addService(title: title, description: description, price: price);
    }

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
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            _isEditing ? 'Editar servicio' : 'Nuevo servicio',
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: VaultSpacing.md),
          TextField(
            controller: _titleController,
            decoration: const InputDecoration(
              labelText: 'Título',
              hintText: 'Limpieza profunda de sneakers',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: VaultSpacing.md),
          TextField(
            controller: _descController,
            maxLines: 3,
            decoration: const InputDecoration(
              labelText: 'Descripción',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: VaultSpacing.md),
          TextField(
            controller: _priceController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'Precio',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: VaultSpacing.lg),
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
                : Text(_isEditing ? 'Guardar cambios' : 'Publicar'),
          ),
        ],
      ),
    );
  }
}
