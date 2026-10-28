import 'package:flutter/material.dart';
import '../network/novalearn_api.dart';

/// Converts a caught error into copy a parent/child can actually act on. `ApiException.message`
/// already comes from the backend's own error translation (see
/// `interfaces/rest/common/ApiExceptionHandler`), which is already display-safe — anything else
/// (a dropped connection, a DNS failure, ...) gets one consistent, friendly fallback instead of
/// Dart's raw exception toString leaking onto the screen.
String friendlyErrorMessage(Object error) =>
    error is ApiException ? error.message : "We couldn't reach NovaLearn. Check your connection and try again.";

/// A consistent "this didn't load" state with an optional retry action, used anywhere a
/// FutureBuilder's error branch would otherwise show bare text with no way to recover short of
/// leaving and coming back.
class ErrorState extends StatelessWidget {
  const ErrorState({super.key, required this.message, this.onRetry});
  final String message;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) => Center(
      child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Icon(Icons.cloud_off_rounded,
                    size: 44, color: Theme.of(context).colorScheme.outline),
                const SizedBox(height: 16),
                Text(message,
                    textAlign: TextAlign.center, style: Theme.of(context).textTheme.bodyLarge),
                if (onRetry != null) ...<Widget>[
                  const SizedBox(height: 20),
                  OutlinedButton.icon(
                      onPressed: onRetry,
                      icon: const Icon(Icons.refresh),
                      label: const Text('Try again')),
                ],
              ])));
}
