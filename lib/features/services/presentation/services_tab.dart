import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/dimens.dart';
import '../../../core/theme.dart';
import '../../auth/presentation/providers.dart';
import '../../profile/domain/entities.dart';
import '../../profile/presentation/providers.dart';

/// Servicios que el usuario ofrece como especialista.
///
/// Cualquiera puede publicar servicios, sin importar su rol: el contenido
/// depende de lo que la persona realmente ofrece.
class ServicesTab extends ConsumerWidget {
  const ServicesTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userId = ref.watch(authControllerProvider).user?.id;
    if (userId == null) {
      return const Center(child: Text('Inicia sesión para ver tus servicios'));
    }

    final state = ref.watch(restorerProfileControllerProvider(userId));
    final services = state.profile?.services ?? const <RestorerServiceEntity>[];

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(VaultSpacing.md),
          child: SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => _openSheet(context, ref, userId),
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
          child: state.status == RestorerProfileStatus.loading
              ? const Center(child: CircularProgressIndicator())
              : services.isEmpty
                  ? const _EmptyServices()
                  : ListView.builder(
                      padding: const EdgeInsets.all(VaultSpacing.md),
                      itemCount: services.length,
                      itemBuilder: (context, index) {
                        final service = services[index];
                        return _ServiceCard(
                          service: service,
                          onTap: () =>
                              _openSheet(context, ref, userId, service: service),
                          onDelete: () => ref
                              .read(restorerProfileControllerProvider(userId)
                                  .notifier)
                              .removeService(service.id),
                        );
                      },
                    ),
        ),
      ],
    );
  }

  /// Abre el formulario. Si recibe un servicio, lo edita; si no, crea uno nuevo.
  void _openSheet(
    BuildContext context,
    WidgetRef ref,
    String userId, {
    RestorerServiceEntity? service,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: VaultColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius:
            BorderRadius.vertical(top: Radius.circular(VaultRadius.card)),
      ),
      builder: (_) =>
          _ServiceSheet(userId: userId, ref: ref, existing: service),
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
  final RestorerServiceEntity service;
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
  final String userId;
  final WidgetRef ref;
  final RestorerServiceEntity? existing;

  const _ServiceSheet({
    required this.userId,
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
    if (_titleController.text.trim().isEmpty) return;
    setState(() => _saving = true);

    final service = RestorerServiceEntity(
      id: widget.existing?.id ??
          DateTime.now().millisecondsSinceEpoch.toString(),
      title: _titleController.text.trim(),
      description: _descController.text.trim(),
      price: double.tryParse(_priceController.text.trim()) ?? 0,
    );

    final notifier = widget.ref
        .read(restorerProfileControllerProvider(widget.userId).notifier);

    if (_isEditing) {
      await notifier.updateService(service);
    } else {
      await notifier.addService(service);
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
              labelText: 'Precio (opcional)',
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