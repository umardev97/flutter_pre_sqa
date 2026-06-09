import 'package:flutter_pre_sqa/src/services/process_runner.dart';

/// Represents the result of an environment verification pass.
class EnvironmentCheck {
  /// Creates a new environment check result.
  EnvironmentCheck({required this.success, required this.message});

  /// `true` when the environment check succeeded.
  final bool success;

  /// A human-readable message describing the environment state.
  final String message;
}

/// Verifies that Flutter and Dart are available in the current shell.
class EnvironmentService {
  final ProcessRunner _runner = ProcessRunner();

  /// The detected Flutter version string.
  String flutterVersion = 'unknown';

  /// The detected Dart version string.
  String dartVersion = 'unknown';

  /// Verifies Flutter and Dart availability.
  ///
  /// When [verbose] is enabled, the returned message includes additional
  /// environment details.
  Future<EnvironmentCheck> verify({bool verbose = false}) async {
    final buffer = StringBuffer();
    final flutterResult = await _runner.run('flutter', ['--version']);
    if (flutterResult.exitCode != 0) {
      return EnvironmentCheck(
        success: false,
        message:
            'Flutter is not available or returned an error: ${flutterResult.stderr}',
      );
    }
    flutterVersion = flutterResult.stdout.split('\n').first;
    buffer.writeln('Flutter: $flutterVersion');

    final dartResult = await _runner.run('dart', ['--version']);
    if (dartResult.exitCode != 0) {
      return EnvironmentCheck(
        success: false,
        message:
            'Dart is not available or returned an error: ${dartResult.stderr}',
      );
    }
    dartVersion =
        dartResult.stderr.isNotEmpty ? dartResult.stderr : dartResult.stdout;
    buffer.writeln('Dart: $dartVersion');

    if (verbose) {
      buffer.writeln('Environment verification completed successfully.');
    }

    return EnvironmentCheck(success: true, message: buffer.toString());
  }
}
