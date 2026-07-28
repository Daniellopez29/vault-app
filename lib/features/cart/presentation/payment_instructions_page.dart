import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import '../../../core/dimens.dart';
import '../../../core/router.dart';
import '../../../core/theme.dart';
import '../domain/entities.dart';

/// Instrucciones de pago para transferencia y efectivo.
///
/// La referencia se genera una vez por intento de pago (antes era el mismo
/// string fijo para cualquier usuario, '9021 4471 8830 2265' -- no servía
/// para identificar de quién era un depósito). Sigue siendo del lado del
/// cliente, sin persistir en ningún lado: `POST /orders` es exclusivo de
/// pagos con tarjeta vía Stripe (ver `CreateOrderUseCase.go` en `payment/`),
/// no existe todavía un endpoint que registre órdenes de transferencia/
/// efectivo y las concilie contra un depósito real -- esa es una pieza de
/// backend aparte, no algo que se resuelva solo del lado de la app.
class PaymentInstructionsPage extends StatefulWidget {
  final PaymentType type;

  const PaymentInstructionsPage({super.key, required this.type});

  @override
  State<PaymentInstructionsPage> createState() => _PaymentInstructionsPageState();
}

class _PaymentInstructionsPageState extends State<PaymentInstructionsPage> {
  late final String _reference = _generateReference();

  String _generateReference() {
    final random = Random();
    final digits = List.generate(16, (_) => random.nextInt(10)).join();
    return [for (var i = 0; i < 16; i += 4) digits.substring(i, i + 4)].join(' ');
  }

  @override
  Widget build(BuildContext context) {
    final isTransfer = widget.type == PaymentType.transfer;

    return Scaffold(
      backgroundColor: VaultColors.background,
      appBar: AppBar(
        title: Text(isTransfer ? 'Transferencia' : 'Pago en efectivo'),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(VaultSpacing.md),
        children: [
          _ReferenceCard(reference: _reference),
          const SizedBox(height: VaultSpacing.lg),
          if (isTransfer) const _TransferDetails() else const _CashDetails(),
          const SizedBox(height: VaultSpacing.lg),
          const _Warning(),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(VaultSpacing.md),
          child: ElevatedButton(
            onPressed: () => context.push(AppRoutes.orderSuccess),
            style: ElevatedButton.styleFrom(
              backgroundColor: VaultColors.accent,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: VaultSpacing.md),
            ),
            child: const Text('Ya realice el pago'),
          ),
        ),
      ),
    );
  }
}

/// Referencia destacada, copiable con un toque.
class _ReferenceCard extends StatelessWidget {
  final String reference;

  const _ReferenceCard({required this.reference});

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(VaultSpacing.lg),
      decoration: BoxDecoration(
        color: VaultColors.primary,
        borderRadius: VaultRadius.cardBorder,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Referencia de pago',
            style: tt.labelSmall?.copyWith(color: Colors.white70),
          ),
          const SizedBox(height: VaultSpacing.xs),
          Text(
            reference,
            style: tt.headlineSmall?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.5,
            ),
          ),
          const SizedBox(height: VaultSpacing.sm),
          TextButton.icon(
            onPressed: () {
              Clipboard.setData(ClipboardData(text: reference));
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Referencia copiada')),
              );
            },
            style: TextButton.styleFrom(
              foregroundColor: Colors.white,
              padding: EdgeInsets.zero,
              minimumSize: const Size(0, 32),
            ),
            icon: const Icon(Icons.copy, size: VaultIconSize.sm),
            label: const Text('Copiar'),
          ),
        ],
      ),
    );
  }
}

class _TransferDetails extends StatelessWidget {
  const _TransferDetails();

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Datos para la transferencia', style: tt.titleMedium),
        const SizedBox(height: VaultSpacing.sm),
        const _InfoCard(
          rows: [
            ['Banco', 'BBVA Mexico'],
            ['Titular', 'Vault Plataforma SA de CV'],
            ['CLABE', '012 180 01234567890 1'],
            ['Concepto', 'Usa tu referencia'],
          ],
        ),
      ],
    );
  }
}

class _CashDetails extends StatelessWidget {
  const _CashDetails();

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Donde pagar', style: tt.titleMedium),
        const SizedBox(height: VaultSpacing.sm),
        const _InfoCard(
          rows: [
            ['Establecimientos', 'OXXO, Farmacias del Ahorro, 7-Eleven'],
            ['Que presentar', 'La referencia de arriba'],
            ['Comision', 'Segun el establecimiento'],
          ],
        ),
      ],
    );
  }
}

class _InfoCard extends StatelessWidget {
  final List<List<String>> rows;

  const _InfoCard({required this.rows});

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;

    return Container(
      decoration: BoxDecoration(
        color: VaultColors.surface,
        borderRadius: VaultRadius.cardBorder,
        border: Border.all(color: VaultColors.divider),
      ),
      child: Column(
        children: [
          for (var i = 0; i < rows.length; i++) ...[
            Padding(
              padding: const EdgeInsets.all(VaultSpacing.md),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: 120,
                    child: Text(
                      rows[i][0],
                      style: tt.bodyMedium?.copyWith(
                        color: VaultColors.textSecondary,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Text(rows[i][1], style: tt.bodyMedium),
                  ),
                ],
              ),
            ),
            if (i < rows.length - 1)
              const Divider(height: 1, color: VaultColors.divider),
          ],
        ],
      ),
    );
  }
}

class _Warning extends StatelessWidget {
  const _Warning();

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.all(VaultSpacing.md),
      decoration: BoxDecoration(
        color: VaultColors.surface,
        borderRadius: VaultRadius.cardBorder,
        border: Border.all(color: VaultColors.divider),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.info_outline,
              color: VaultColors.textSecondary, size: VaultIconSize.md),
          const SizedBox(width: VaultSpacing.md),
          Expanded(
            child: Text(
              'Tu pedido se confirma cuando registremos el pago. Conserva tu '
              'comprobante hasta entonces.',
              style: tt.labelSmall?.copyWith(color: VaultColors.textSecondary),
            ),
          ),
        ],
      ),
    );
  }
}