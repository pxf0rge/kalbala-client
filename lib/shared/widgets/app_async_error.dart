import 'package:flutter/material.dart';
import 'package:rahmani_project/core/errors/exception_mapper.dart';
import 'package:rahmani_project/shared/widgets/app_error_widget.dart';

/// Maps thrown errors to a Persian [AppErrorWidget] with optional retry.
class AppAsyncError extends StatelessWidget {
  const AppAsyncError({
    required this.error,
    this.onRetry,
    super.key,
  });

  final Object error;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    return AppErrorWidget(
      message: friendlyErrorMessage(error),
      onRetry: onRetry,
    );
  }
}
