import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart' as stripe;

import '../dimens.dart';
import '../theme.dart';

/// Campo de tarjeta de Stripe con el mismo estilo en cualquier pantalla que
/// cobre con tarjeta -- antes el carrito y el checkout de suscripción cada
/// uno tenía su propia copia del mismo Container+CardField, con pequeñas
/// diferencias entre sí (el del carrito pedía código postal, el de
/// suscripción no).
///
/// `enablePostalCode` queda en `false`: es un chequeo de Stripe pensado
/// para tarjetas de EEUU (ver flutter_stripe/CardField), y Vault no valida
/// ni usa ese dato para nada -- pedirlo solo confundía sin aportar nada.
class VaultCardField extends StatelessWidget {
  final ValueChanged<bool> onCompleteChanged;

  const VaultCardField({super.key, required this.onCompleteChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: VaultSpacing.md),
      decoration: BoxDecoration(
        color: VaultColors.surface,
        borderRadius: VaultRadius.cardBorder,
        border: Border.all(color: VaultColors.divider),
      ),
      child: stripe.CardField(
        enablePostalCode: false,
        onCardChanged: (details) => onCompleteChanged(details?.complete ?? false),
      ),
    );
  }
}
