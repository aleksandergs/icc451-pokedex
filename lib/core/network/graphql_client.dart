import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import '../errors/failure.dart';

const int defaultTimeout = 15;

/// Cliente GraphQL HTTP de lectura
class GraphQlClient {
  GraphQlClient({
    required this.endpoint,
    http.Client? httpClient,
    this.timeout = const Duration(seconds: defaultTimeout),
  }) : _http = httpClient ?? http.Client();

  final Uri endpoint;
  final Duration timeout;
  final http.Client _http;

  /// ejecuta una consulta y devuelve el objeto `data` de la respuesta.
  Future<Map<String, dynamic>> query(
    String document, {
    Map<String, dynamic>? variables,
  }) async {
    final String body = jsonEncode(<String, dynamic>{
      'query': document,
      if (variables != null && variables.isNotEmpty) 'variables': variables,
    });

    http.Response response;
    try {
      response = await _http
          .post(
            endpoint,
            headers: const <String, String>{
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
            body: body,
          )
          .timeout(timeout);
    } on TimeoutException {
      throw const AppFailure(FailureType.timeout);
    } on SocketException catch (error) {
      throw AppFailure(FailureType.noConnection, message: error.message);
    } on http.ClientException catch (error) {
      throw AppFailure(FailureType.noConnection, message: error.message);
    }

    if (response.statusCode >= 400) {
      throw AppFailure(
        FailureType.serverError,
        message: 'HTTP ${response.statusCode}',
      );
    }

    late final Map<String, dynamic> decoded;
    try {
      decoded =
          jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
    } on FormatException catch (error) {
      throw AppFailure(FailureType.responseError, message: error.message);
    }

    final dynamic errors = decoded['errors'];
    if (errors is List && errors.isNotEmpty) {
      final String message = errors
          .map(
            (dynamic error) => error is Map ? '${error['message']}' : '$error',
          )
          .join(' | ');
      throw AppFailure(FailureType.serverError, message: message);
    }

    final dynamic data = decoded['data'];
    if (data is! Map<String, dynamic>) {
      throw const AppFailure(FailureType.responseError);
    }
    return data;
  }

  void dispose() => _http.close();
}
