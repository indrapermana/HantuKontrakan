import 'package:flutter_test/flutter_test.dart';
import 'package:hantu_kontrakan/services/error_reporting_service.dart';

void main() {
  test(
    'consent-aware reporter is disabled by default and swallows failures',
    () async {
      final delegate = _ThrowingReporter();
      final reporter = ConsentAwareErrorReportingService(delegate: delegate);

      await reporter.record(
        StateError('off'),
        StackTrace.current,
        reason: 'test',
      );
      expect(delegate.calls, 0);

      reporter.setEnabled(true);
      await reporter.record(
        StateError('on'),
        StackTrace.current,
        reason: 'test',
      );
      expect(delegate.calls, 1);
    },
  );
}

class _ThrowingReporter implements ErrorReportingService {
  int calls = 0;

  @override
  Future<void> record(
    Object error,
    StackTrace stackTrace, {
    required String reason,
    bool fatal = false,
  }) async {
    calls += 1;
    throw StateError('provider unavailable');
  }
}
