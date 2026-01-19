import 'package:flutter/material.dart';
import 'package:logging/logging.dart';

class ErrorBoundary extends StatefulWidget {
  final Widget child;
  final Widget Function(BuildContext context, dynamic error, StackTrace? stack)?
      errorBuilder;

  const ErrorBoundary({
    super.key,
    required this.child,
    this.errorBuilder,
  });

  @override
  State<ErrorBoundary> createState() => _ErrorBoundaryState();
}

class _ErrorBoundaryState extends State<ErrorBoundary> {
  static final Logger _log = Logger('ErrorBoundary');
  dynamic _error;
  StackTrace? _stackTrace;
  ErrorWidgetBuilder? _previousErrorBuilder;

  @override
  void initState() {
    super.initState();
    _previousErrorBuilder = ErrorWidget.builder;
    ErrorWidget.builder = (FlutterErrorDetails details) {
      _log.severe(
          'UI Error caught by ErrorBoundary', details.exception, details.stack);

      // Update state if mounted
      if (mounted) {
        setState(() {
          _error = details.exception;
          _stackTrace = details.stack;
        });
      }

      // Return a temporary blank widget while we transition to error UI
      return const SizedBox.shrink();
    };
  }

  @override
  void dispose() {
    ErrorWidget.builder = _previousErrorBuilder!;
    super.dispose();
  }

  // Also catch via FlutterError.onError if possible, though it's usually global
  // In Flutter 3.3+, we can use ErrorWidget.builder

  void _resetError() {
    setState(() {
      _error = null;
      _stackTrace = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_error != null) {
      if (widget.errorBuilder != null) {
        return widget.errorBuilder!(context, _error, _stackTrace);
      }
      return _buildDefaultErrorUI();
    }

    return widget.child;
  }

  Widget _buildDefaultErrorUI() {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: 80,
                color: colorScheme.error,
              ),
              const SizedBox(height: 24),
              Text(
                '¡Ups! Algo salió mal',
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Ha ocurrido un error inesperado en la interfaz. Por favor, intenta reiniciar la aplicación.',
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 32),
              ElevatedButton.icon(
                onPressed: _resetError,
                icon: const Icon(Icons.refresh),
                label: const Text('Intentar recuperar'),
                style: ElevatedButton.styleFrom(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                ),
              ),
              const SizedBox(height: 12),
              TextButton(
                onPressed: () {
                  // Simply pop or go home if using a router
                  Navigator.of(context).popUntil((route) => route.isFirst);
                  _resetError();
                },
                child: const Text('Regresar al inicio'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
