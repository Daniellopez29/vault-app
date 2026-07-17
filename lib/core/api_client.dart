import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import 'error.dart';

/// URL base del API de Go, ajustable en tiempo de ejecución (ver
/// [ApiConfig.setOverride]). El default apunta al backend ya desplegado en
/// Railway (HTTPS, alcanzable desde cualquier red, no solo la LAN del
/// desarrollador) -- por eso ya no hace falta distinguir emulador/celular
/// físico ni el permiso de tráfico sin cifrar para el caso normal. El
/// override en Configuración sigue sirviendo para apuntar a un backend
/// local (p.ej. `http://192.168.x.x:8080/api/v1`) mientras se depura algo
/// que no se puede probar contra producción.
class ApiConfig {
  static const _overrideKey = 'vault_api_base_url';

  static const _productionDefault =
      'https://humorous-nurturing-production-9cd4.up.railway.app/api/v1';

  static String? _override;

  static String get baseUrl {
    if (_override != null && _override!.isNotEmpty) return _override!;
    return _productionDefault;
  }

  /// Se llama una vez al arrancar la app (ver main.dart) para recuperar
  /// una URL guardada manualmente desde Configuración.
  static Future<void> loadOverride() async {
    final prefs = await SharedPreferences.getInstance();
    _override = prefs.getString(_overrideKey);
  }

  static Future<void> setOverride(String? url) async {
    _override = (url == null || url.trim().isEmpty) ? null : url.trim();
    final prefs = await SharedPreferences.getInstance();
    if (_override == null) {
      await prefs.remove(_overrideKey);
    } else {
      await prefs.setString(_overrideKey, _override!);
    }
  }
}

/// Cliente HTTP central: agrega el token de sesión, decodifica JSON y
/// traduce códigos de estado a los [Failure] que ya entiende el resto de
/// la app (dartz Either en los repositorios).
class ApiClient {
  final http.Client _http;

  /// Sin esto, un servidor inalcanzable (IP equivocada, backend caído,
  /// firewall que descarta paquetes en silencio) deja el Future de la
  /// petición colgado indefinidamente -- la UI se queda "cargando" para
  /// siempre en vez de mostrar un error.
  static const _requestTimeout = Duration(seconds: 15);

  ApiClient({http.Client? httpClient}) : _http = httpClient ?? http.Client();

  String get baseUrl => ApiConfig.baseUrl;

  static const _tokenKey = 'vault_auth_token';

  Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
  }

  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  Future<void> clearToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
  }

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

  /// Devuelve el body decodificado: `Map<String, dynamic>` para un objeto,
  /// `List<dynamic>` para un arreglo, o `null` si el body viene vacío
  /// (204, o respuestas sin contenido).
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

  Future<dynamic> get(String path, {Map<String, String>? query, bool auth = true}) async {
    try {
      final response = await _http
          .get(_uri(path, query), headers: await _headers(withAuth: auth))
          .timeout(_requestTimeout, onTimeout: _throwTimeout);
      return _handle(response);
    } on Failure {
      rethrow;
    } catch (e) {
      throw ServerFailure('No se pudo conectar con el servidor: $e');
    }
  }

  Future<dynamic> post(String path, {Object? body, bool auth = true}) async {
    try {
      final response = await _http
          .post(
            _uri(path),
            headers: await _headers(withAuth: auth),
            body: body != null ? jsonEncode(body) : null,
          )
          .timeout(_requestTimeout, onTimeout: _throwTimeout);
      return _handle(response);
    } on Failure {
      rethrow;
    } catch (e) {
      throw ServerFailure('No se pudo conectar con el servidor: $e');
    }
  }

  Future<dynamic> put(String path, {Object? body, bool auth = true}) async {
    try {
      final response = await _http
          .put(
            _uri(path),
            headers: await _headers(withAuth: auth),
            body: body != null ? jsonEncode(body) : null,
          )
          .timeout(_requestTimeout, onTimeout: _throwTimeout);
      return _handle(response);
    } on Failure {
      rethrow;
    } catch (e) {
      throw ServerFailure('No se pudo conectar con el servidor: $e');
    }
  }

  /// Sube un archivo como multipart/form-data. [fieldName] debe coincidir
  /// con el nombre que el backend espera en el form (p.ej. "image" en
  /// PUT /users/{id}/image o POST /posts/{id}/photos).
  Future<dynamic> _multipart(
    String method,
    String path, {
    required List<int> bytes,
    required String filename,
    required String fieldName,
    bool auth = true,
  }) async {
    try {
      final request = http.MultipartRequest(method, _uri(path));
      final headers = await _headers(withAuth: auth);
      headers.remove('Content-Type'); // http arma el boundary multipart solo
      request.headers.addAll(headers);
      request.files.add(http.MultipartFile.fromBytes(fieldName, bytes, filename: filename));

      final streamed = await _http.send(request).timeout(_requestTimeout, onTimeout: _throwTimeout);
      final response = await http.Response.fromStream(streamed);
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

  Future<dynamic> delete(String path, {bool auth = true}) async {
    try {
      final response = await _http
          .delete(_uri(path), headers: await _headers(withAuth: auth))
          .timeout(_requestTimeout, onTimeout: _throwTimeout);
      return _handle(response);
    } on Failure {
      rethrow;
    } catch (e) {
      throw ServerFailure('No se pudo conectar con el servidor: $e');
    }
  }
}
