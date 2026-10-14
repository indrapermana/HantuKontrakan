import 'dart:async';

abstract interface class ErrorReportingService {
  Future<void> record(
    Object error,
    StackTrace stackTrace, {
    required String reason,
    bool fatal = false,
  });
}

class NoopErrorReportingService implements ErrorReportingService {
  const NoopErrorReportingService();

  @override
  Future<void> record(
    Object error,
    StackTrace stackTrace, {
    required String reason,
    bool fatal = false,
  }) async {}
}

class ConsentAwareErrorReportingService implements ErrorReportingService {
  ConsentAwareErrorReportingService({
    ErrorReportingService delegate = const NoopErrorReportingService(),
  }) : _delegate = delegate;

  final ErrorReportingService _delegate;
  bool _enabled = false;

  bool get enabled => _enabled;
  void setEnabled(bool value) => _enabled = value;

  @override
  Future<void> record(
    Object error,
    StackTrace stackTrace, {
    required String reason,
    bool fatal = false,
  }) async {
    if (!_enabled) return;
    try {
      await _delegate.record(error, stackTrace, reason: reason, fatal: fatal);
    } on Object {
      // Reporting is best-effort and must never interrupt local gameplay.
    }
  }
}
