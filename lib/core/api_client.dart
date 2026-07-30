import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import 'api_config.dart';
import 'error.dart';
import 'token_storage.dart';

class ApiClient {
  final http.Client _http;
  final TokenStorage _tokenStorage;

  static const _requestTimeout = Duration(seconds: 15);

  ApiClient({http.Client? httpClient, TokenStorage? tokenStorage})
      : _http = httpClient ?? http.Client(),
        _tokenStorage = tokenStorage ?? TokenStorage();

  String get baseUrl => ApiConfig.baseUrl;

  Future<void> saveToken(String token) => _tokenStorage.save(token);

  Future<String?> getToken() => _tokenStorage.read();

  Future<void> clearToken() => _tokenStorage.clear();

  Future<Map<String, String>> _headers({bool withAuth = true}) async {
    final headers = {'Content-Type': 'application/json'};
    if (withAuth) {
      final token = await getToken();
      if (token != null) headers['Authorization'] = 'Bearer $token';
    }
    return headers;
  }

  Uri _uri(String path, [Map<String, String>? query]) =>
      Uri.parse('$baseUrl$path').replace(queryParameters: query);

  dynamic _decode(http.Response response) {
    if (response.body.isEmpty) return null;
    return jsonDecode(response.body);
  }

  Never _throwForStatus(http.Response response) {
    String message = 'Error en el servidor. Intenta nuevamente.';
    final body = _decode(response);
    if (body is Map<String, dynamic> && body['error'] is String) {
      message = body['error'] as String;
    }

    switch (response.statusCode) {
      case 401:
        throw AuthFailure(message);
      case 422:
      case 503:
        throw ModerationFailure(message);
      default:
        throw ServerFailure(message);
    }
  }

  dynamic _handle(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return _decode(response);
    }
    _throwForStatus(response);
  }

  Never _throwTimeout() => throw ServerFailure(
        'El servidor no respondió a tiempo. Revisa tu conexión o la URL del '
        'servidor en Configuración → Avanzado.',
      );

  /// Reintenta UNA vez, tras una breve espera, si el primer intento falla
  /// por timeout o error de conexión -- Railway duerme los servicios tras
  /// un rato sin uso, así que la primera petición de la sesión (que suele
  /// disparar varias pantallas casi a la vez: perfil, notificaciones, chat)
  /// puede tardar más que el timeout mientras el contenedor despierta.
  /// Antes de esto, esa lentitud puntual se veía como TODAS esas pantallas
  /// cayendo a la vez en su estado de error, obligando a tocar "Reintentar"
  /// a mano en cada una. No reintenta errores reales del servidor (401,
  /// 404, 500...) -- esos ya implican que SÍ hubo respuesta.
  Future<http.Response> _sendWithRetry(Future<http.Response> Function() send) async {
    try {
      return await send().timeout(_requestTimeout);
    } catch (_) {
      await Future.delayed(const Duration(seconds: 2));
      return await send().timeout(_requestTimeout, onTimeout: _throwTimeout);
    }
  }

  Future<dynamic> get(String path, {Map<String, String>? query, bool auth = true}) async {
    try {
      final response = await _sendWithRetry(
        () async => _http.get(_uri(path, query), headers: await _headers(withAuth: auth)),
      );
      return _handle(response);
    } on Failure {
      rethrow;
    } catch (e) {
      throw ServerFailure('No se pudo conectar con el servidor: $e');
    }
  }

  Future<dynamic> post(String path, {Object? body, bool auth = true}) async {
    try {
      final response = await _sendWithRetry(
        () async => _http.post(
          _uri(path),
          headers: await _headers(withAuth: auth),
          body: body != null ? jsonEncode(body) : null,
        ),
      );
      return _handle(response);
    } on Failure {
      rethrow;
    } catch (e) {
      throw ServerFailure('No se pudo conectar con el servidor: $e');
    }
  }

  Future<dynamic> put(String path, {Object? body, bool auth = true}) async {
    try {
      final response = await _sendWithRetry(
        () async => _http.put(
          _uri(path),
          headers: await _headers(withAuth: auth),
          body: body != null ? jsonEncode(body) : null,
        ),
      );
      return _handle(response);
    } on Failure {
      rethrow;
    } catch (e) {
      throw ServerFailure('No se pudo conectar con el servidor: $e');
    }
  }

  Future<dynamic> patch(String path, {Object? body, bool auth = true}) async {
    try {
      final response = await _sendWithRetry(
        () async => _http.patch(
          _uri(path),
          headers: await _headers(withAuth: auth),
          body: body != null ? jsonEncode(body) : null,
        ),
      );
      return _handle(response);
    } on Failure {
      rethrow;
    } catch (e) {
      throw ServerFailure('No se pudo conectar con el servidor: $e');
    }
  }

  Future<dynamic> _multipart(
    String method,
    String path, {
    required List<int> bytes,
    required String filename,
    required String fieldName,
    bool auth = true,
  }) async {
    try {
      // Un MultipartRequest solo se puede enviar una vez (su stream de
      // archivo se consume en send()) -- _sendWithRetry puede llamar a este
      // closure una segunda vez, así que arma un request NUEVO en cada
      // intento en vez de reutilizar uno solo.
      Future<http.Response> attempt() async {
        final request = http.MultipartRequest(method, _uri(path));
        final headers = await _headers(withAuth: auth);
        headers.remove('Content-Type'); // http arma el boundary multipart solo
        request.headers.addAll(headers);
        request.files.add(http.MultipartFile.fromBytes(fieldName, bytes, filename: filename));
        final streamed = await _http.send(request);
        return http.Response.fromStream(streamed);
      }

      final response = await _sendWithRetry(attempt);
      return _handle(response);
    } on Failure {
      rethrow;
    } catch (e) {
      throw ServerFailure('No se pudo subir la imagen: $e');
    }
  }

  Future<dynamic> putMultipart(
    String path, {
    required List<int> bytes,
    required String filename,
    required String fieldName,
    bool auth = true,
  }) =>
      _multipart('PUT', path, bytes: bytes, filename: filename, fieldName: fieldName, auth: auth);

  Future<dynamic> postMultipart(
    String path, {
    required List<int> bytes,
    required String filename,
    required String fieldName,
    bool auth = true,
  }) =>
      _multipart('POST', path,
          bytes: bytes, filename: filename, fieldName: fieldName, auth: auth);

  Future<dynamic> delete(String path, {Object? body, bool auth = true}) async {
    try {
      final response = await _sendWithRetry(
        () async => _http.delete(
          _uri(path),
          headers: await _headers(withAuth: auth),
          body: body != null ? jsonEncode(body) : null,
        ),
      );
      return _handle(response);
    } on Failure {
      rethrow;
    } catch (e) {
      throw ServerFailure('No se pudo conectar con el servidor: $e');
    }
  }
}
