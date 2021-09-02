import 'package:flutter/foundation.dart';

class HttpApiException implements Exception {
  final int statusCode;
  final String message;
  final Object model;

  HttpApiException({
    @required this.statusCode,
    this.message,
    this.model,
  });

  bool get hasModel => model != null;

  @override
  String toString() => """
    statusCode: $statusCode,
    message: $message,
    model: $model,
  """;
}
