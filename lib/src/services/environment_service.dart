import 'package:flutter_pre_sqa/src/services/process_runner.dart';

class EnvironmentCheck {
  EnvironmentCheck({required this.success, required this.message});
  final bool success;
  final String message;
}

class EnvironmentService {
  final ProcessRunner _runner = ProcessRunner();
  String flutterVersion = 'unknown';
  String dartVersion = 'unknown';

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
