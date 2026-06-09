import 'dart:io';

/// Encapsulates the result of running an external process.
class ProcessResultData {
  /// Creates a new process result.
  ProcessResultData({
    required this.stdout,
    required this.stderr,
    required this.exitCode,
  });

  /// Standard output captured from the process.
  final String stdout;

  /// Standard error captured from the process.
  final String stderr;

  /// The process exit code.
  final int exitCode;
}

/// Runs external executables and returns structured process results.
class ProcessRunner {
  /// Executes [executable] with the given [arguments].
  ///
  /// The command is run in a shell by default.
  Future<ProcessResultData> run(
    String executable,
    List<String> arguments, {
    bool runInShell = true,
  }) async {
    final result =
        await Process.run(executable, arguments, runInShell: runInShell);
    return ProcessResultData(
      stdout: result.stdout.toString().trim(),
      stderr: result.stderr.toString().trim(),
      exitCode: result.exitCode,
    );
  }
}
