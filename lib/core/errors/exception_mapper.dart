import 'dart:async';

import 'package:rahmani_project/core/errors/exceptions.dart';
import 'package:rahmani_project/core/errors/failures.dart';

/// Maps data-layer exceptions to domain failures.
Failure mapExceptionToFailure(Object error) {
  if (error is Failure) return error;

  if (error is AppException) {
    return switch (error) {
      ServerException(:final message) =>
        ServerFailure(_persianOrDefault(message, const ServerFailure().message)),
      NetworkException(:final message) =>
        NetworkFailure(_persianOrDefault(message, const NetworkFailure().message)),
      AuthException(:final message) =>
        AuthFailure(_persianOrDefault(message, const AuthFailure().message)),
      ValidationException(:final message) => ValidationFailure(message),
      NotFoundException(:final message) =>
        NotFoundFailure(_persianOrDefault(message, const NotFoundFailure().message)),
    };
  }

  if (_isNetworkError(error)) {
    return const NetworkFailure();
  }

  final text = error.toString();
  if (_looksTechnical(text)) {
    return const UnknownFailure();
  }

  return UnknownFailure(text);
}

/// User-facing Persian message for UI error states.
String friendlyErrorMessage(Object error) {
  final failure = mapExceptionToFailure(error);
  final message = failure.message.trim();
  if (message.isEmpty || _looksTechnical(message)) {
    if (failure is NetworkFailure) return const NetworkFailure().message;
    if (failure is AuthFailure) return const AuthFailure().message;
    if (failure is ServerFailure) return const ServerFailure().message;
    return const UnknownFailure().message;
  }
  return message;
}

bool _isNetworkError(Object error) {
  if (error is TimeoutException) return true;
  final typeName = error.runtimeType.toString().toLowerCase();
  if (typeName.contains('socket') ||
      typeName.contains('clientexception') ||
      typeName.contains('handshake')) {
    return true;
  }
  final text = error.toString().toLowerCase();
  return text.contains('socketexception') ||
      text.contains('clientexception') ||
      text.contains('handshakeexception') ||
      text.contains('failed host lookup') ||
      text.contains('network is unreachable') ||
      text.contains('connection refused') ||
      text.contains('connection reset') ||
      text.contains('timed out') ||
      text.contains('timeout') ||
      text.contains('offline');
}

bool _looksTechnical(String message) {
  final lower = message.toLowerCase();
  return lower.contains('exception') ||
      lower.contains('error:') ||
      lower.contains('socket') ||
      lower.contains('http://') ||
      lower.contains('https://') ||
      lower.contains('postgrest') ||
      lower.contains('supabase') ||
      RegExp(r'\b[A-Z][a-zA-Z]+Exception\b').hasMatch(message);
}

String _persianOrDefault(String message, String fallback) {
  final trimmed = message.trim();
  if (trimmed.isEmpty || _looksTechnical(trimmed)) return fallback;
  final mapped = _mapKnownServerMessage(trimmed);
  if (mapped != null) return mapped;
  final hasPersian = RegExp(r'[\u0600-\u06FF]').hasMatch(trimmed);
  if (hasPersian) return trimmed;
  if (trimmed.length > 120) return fallback;
  return trimmed;
}

String? _mapKnownServerMessage(String message) {
  final lower = message.toLowerCase();
  if (lower.contains('not authenticated')) {
    return const AuthFailure().message;
  }
  if (lower.contains('seller_verification_required')) {
    return 'ابتدا احراز هویت فروشنده را انجام دهید و منتظر تأیید ادمین بمانید.';
  }
  if (lower.contains('pending_booth_application_exists')) {
    return 'یک درخواست فروشگاه در انتظار بررسی دارید.';
  }
  if (lower.contains('booth_application_forbidden') ||
      (lower.contains('row-level security') &&
          lower.contains('booth_application'))) {
    return 'اجازه ثبت درخواست فروشگاه ندارید. دوباره وارد شوید و تلاش کنید.';
  }
  if (lower.contains('row-level security') && lower.contains('products')) {
    return 'برای ثبت محصول باید حداقل یک فروشگاه تأییدشده داشته باشید.';
  }
  if (lower.contains('row-level security') &&
      (lower.contains('storage') || lower.contains('objects'))) {
    return 'اجازه آپلود این فایل را ندارید. دوباره تلاش کنید.';
  }
  if (lower.contains('new row violates row-level security policy')) {
    return 'اجازه انجام این عملیات را ندارید. اگر در حال ثبت محصول هستید، فروشگاه تأییدشده لازم است.';
  }
  if (lower.contains('row-level security policy')) {
    return 'اجازه انجام این عملیات را ندارید.';
  }
  if (lower.contains('listing not available')) {
    return 'این محصول در دسترس نیست یا فروشگاه عمومی نیست.';
  }
  if (lower.contains('insufficient stock')) {
    return 'موجودی کافی نیست.';
  }
  if (lower.contains('invalid quantity')) {
    return 'تعداد نامعتبر است.';
  }
  return null;
}
