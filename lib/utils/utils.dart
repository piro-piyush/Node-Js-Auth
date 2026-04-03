import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

/// Show a simple SnackBar with [text] message
void showSnackBar(BuildContext context, String text) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(text),
      behavior: SnackBarBehavior.floating,
    ),
  );
}

/// Handles HTTP responses consistently
///
/// Example usage:
/// ```dart
/// httpErrorHandle(
///   response: response,
///   context: context,
///   onSuccess: () { /* do something */ },
/// );
/// ```
void httpErrorHandle({
  required http.Response response,
  required BuildContext context,
  required VoidCallback onSuccess,
}) {
  try {
    final Map<String, dynamic> resBody = jsonDecode(response.body);

    switch (response.statusCode) {
      case 200:
        onSuccess();
        break;

      case 400:
      // Some backends may return 'message' or 'msg' key
        showSnackBar(context, resBody['msg'] ?? resBody['message'] ?? 'Bad request');
        break;

      case 500:
        showSnackBar(context, resBody['error'] ?? 'Server error');
        break;

      default:
        showSnackBar(context, response.body);
    }
  } catch (e) {
    // In case response body is not JSON or parsing fails
    showSnackBar(context, 'Unexpected error: $e');
  }
}
