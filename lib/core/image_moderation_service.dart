import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'vision_config.dart';

/// Resultado de la moderación de una imagen.
class ModerationResult {
  final bool isAllowed;
  final String? rejectionReason;

  const ModerationResult({required this.isAllowed, this.rejectionReason});

  static const allowed = ModerationResult(isAllowed: true);
}

/// Servicio de moderación de imágenes usando Google Cloud Vision API.
///
/// Valida dos cosas antes de permitir subir una imagen:
/// 1. Safe Search: rechaza contenido adulto, violento o ofensivo.
/// 2. Detección de personas: rechaza fotos donde aparezcan rostros humanos.
///
/// Solo se permiten imágenes de productos (sneakers, relojes, bolsos, etc).
class ImageModerationService {
  final http.Client _http;

  ImageModerationService({http.Client? httpClient})
      : _http = httpClient ?? http.Client();

  /// Modera una imagen a partir de sus bytes.
  /// Retorna [ModerationResult.allowed] si pasa, o un resultado con
  /// [rejectionReason] si no.
  Future<ModerationResult> moderate(Uint8List imageBytes) async {
    try {
      final base64Image = base64Encode(imageBytes);

      final body = jsonEncode({
        'requests': [
          {
            'image': {'content': base64Image},
            'features': [
              {'type': 'SAFE_SEARCH_DETECTION'},
              {'type': 'FACE_DETECTION', 'maxResults': 5},
              {'type': 'LABEL_DETECTION', 'maxResults': 10},
            ],
          },
        ],
      });

      final uri = Uri.parse(
        VisionConfig.endpoint + '?key=' + VisionConfig.apiKey,
      );

      final response = await _http
          .post(uri, headers: {'Content-Type': 'application/json'}, body: body)
          .timeout(const Duration(seconds: 15));

      if (response.statusCode != 200) {
        // Si Vision API falla, permitimos la imagen (fail-open)
        // para no bloquear al usuario por un error del servicio.
        return ModerationResult.allowed;
      }

      final json = jsonDecode(response.body) as Map<String, dynamic>;
      final responses = json['responses'] as List<dynamic>? ?? [];
      if (responses.isEmpty) return ModerationResult.allowed;

      final result = responses.first as Map<String, dynamic>;

      // 1. Safe Search
      final safeSearch = result['safeSearchAnnotation'] as Map<String, dynamic>?;
      if (safeSearch != null) {
        final blocked = _checkSafeSearch(safeSearch);
        if (blocked != null) return blocked;
      }

      // 2. Detección de rostros
      final faces = result['faceAnnotations'] as List<dynamic>?;
      if (faces != null && faces.isNotEmpty) {
        return const ModerationResult(
          isAllowed: false,
          rejectionReason:
              'La imagen contiene rostros de personas. Solo se permiten fotos de productos.',
        );
      }

      return ModerationResult.allowed;
    } catch (_) {
      // Fail-open: si hay error de red, permitir la imagen.
      return ModerationResult.allowed;
    }
  }

  ModerationResult? _checkSafeSearch(Map<String, dynamic> safeSearch) {
    const blocked = {'LIKELY', 'VERY_LIKELY'};

    final adult = safeSearch['adult'] as String? ?? '';
    final violence = safeSearch['violence'] as String? ?? '';
    final racy = safeSearch['racy'] as String? ?? '';

    if (blocked.contains(adult)) {
      return const ModerationResult(
        isAllowed: false,
        rejectionReason: 'La imagen contiene contenido para adultos.',
      );
    }
    if (blocked.contains(violence)) {
      return const ModerationResult(
        isAllowed: false,
        rejectionReason: 'La imagen contiene contenido violento.',
      );
    }
    if (blocked.contains(racy)) {
      return const ModerationResult(
        isAllowed: false,
        rejectionReason: 'La imagen contiene contenido inapropiado.',
      );
    }

    return null;
  }
}
