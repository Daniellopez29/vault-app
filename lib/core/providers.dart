import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'api_client.dart';

/// Instancia única del cliente HTTP, compartida por todas las features.
final apiClientProvider = Provider<ApiClient>((ref) => ApiClient());
