import 'dart:io';

class ProcessResultData {
  ProcessResultData({
    required this.stdout,
    required this.stderr,
    required this.exitCode,
  });

  final String stdout;
  final String stderr;
  final int exitCode;
}

class ProcessRunner {
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
