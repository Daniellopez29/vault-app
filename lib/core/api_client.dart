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

  Future<dynamic> patch(String path, {Object? body, bool auth = true}) async {
    try {
      final response = await _http
          .patch(
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
