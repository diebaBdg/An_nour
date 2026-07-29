import 'package:flutter/material.dart';

import '../errors/app_exceptions.dart';

abstract final class ErrorHandler {
  static String getMessage(Object error) {
    if (error is AppException) return error.message;
    return 'Une erreur inattendue s\'est produite';
  }

  static void showSnackBar(BuildContext context, Object error) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(getMessage(error)),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}
