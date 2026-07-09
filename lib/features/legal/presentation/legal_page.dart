import 'package:flutter/material.dart';
import '../../../core/dimens.dart';
import '../../../core/theme.dart';
import 'legal_content.dart';

/// Vista con los documentos legales de Vault (Términos y Privacidad),
/// mostrados dentro de la app en vez de enlazar a una página externa.
class LegalPage extends StatelessWidget {
  /// 0 = Términos y Condiciones, 1 = Política de Privacidad.
  final int initialIndex;

  const LegalPage({super.key, this.initialIndex = 0});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      initialIndex: initialIndex,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Legal'),
          bottom: const TabBar(
            indicatorColor: VaultColors.primary,
            labelColor: VaultColors.primary,
            unselectedLabelColor: VaultColors.textSecondary,
            tabs: [
              Tab(text: 'Términos'),
              Tab(text: 'Privacidad'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            _LegalDocumentView(document: kTermsOfService),
            _LegalDocumentView(document: kPrivacyPolicy),
          ],
        ),
      ),
    );
  }
}

class _LegalDocumentView extends StatelessWidget {
  final LegalDocumentContent document;

  const _LegalDocumentView({required this.document});

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(VaultSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(document.title, style: tt.headlineMedium),
          const SizedBox(height: VaultSpacing.xs),
          Text(
            'Última actualización: ${document.lastUpdated}',
            style: tt.labelSmall,
          ),
          const SizedBox(height: VaultSpacing.lg),
          Text(document.intro, style: tt.bodyLarge?.copyWith(height: 1.5)),
          const SizedBox(height: VaultSpacing.xl),
          for (final section in document.sections) ...[
            Text(section.heading, style: tt.titleLarge),
            const SizedBox(height: VaultSpacing.xs),
            Text(section.body, style: tt.bodyLarge?.copyWith(height: 1.5)),
            const SizedBox(height: VaultSpacing.lg),
          ],
        ],
      ),
    );
  }
}
