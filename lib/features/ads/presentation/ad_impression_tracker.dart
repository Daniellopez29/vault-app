import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/entities.dart';
import 'providers.dart';

/// Envuelve la card visual de un anuncio (`_AdCard`/`_AdGridCard`/
/// `_AdFeedCard`) para registrar impressions/clicks contra el backend
/// (`POST /ads/:id/impression|click`, ya existían sin ningún llamador).
///
/// La impresión se registra una sola vez al montarse -- es una
/// aproximación razonable de "se mostró", no un tracker real de
/// visibilidad en viewport (no hay un paquete de ese tipo entre las
/// dependencias todavía).
class AdImpressionTracker extends ConsumerStatefulWidget {
  final AdEntity ad;
  final Widget child;

  /// Se llama además de registrar el clic -- por ejemplo, para navegar al
  /// producto si se encuentra en la lista ya cargada.
  final VoidCallback? onTap;

  const AdImpressionTracker({super.key, required this.ad, required this.child, this.onTap});

  @override
  ConsumerState<AdImpressionTracker> createState() => _AdImpressionTrackerState();
}

class _AdImpressionTrackerState extends ConsumerState<AdImpressionTracker> {
  @override
  void initState() {
    super.initState();
    ref.read(registerAdImpressionUseCaseProvider)(widget.ad.id);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        ref.read(registerAdClickUseCaseProvider)(widget.ad.id);
        widget.onTap?.call();
      },
      child: widget.child,
    );
  }
}
