import 'dart:io';

import 'package:args/args.dart';

class PreSqaRunner {
  PreSqaRunner({
    required this.skipBuild,
    required this.skipTests,
    required this.skipOutdated,
    required this.failFast,
    required this.reportPath,
  });

  factory PreSqaRunner.fromArgs(List<String> arguments) {
    final parser = ArgParser()
      ..addFlag('skip-build', negatable: false, help: 'Skip flutter build apk --debug.')
      ..addFlag('skip-tests', negatable: false, help: 'Skip flutter test.')
      ..addFlag('skip-outdated', negatable: false, help: 'Skip flutter pub outdated.')
      ..addFlag('fail-fast', defaultsTo: false, help: 'Stop on first failed command.')
      ..addOption('report', defaultsTo: 'pre_sqa_report.md', help: 'Markdown report output path.');

    final result = parser.parse(arguments);

    return PreSqaRunner(
      skipBuild: result['skip-build'] as bool,
      skipTests: result['skip-tests'] as bool,
      skipOutdated: result['skip-outdated'] as bool,
      failFast: result['fail-fast'] as bool,
      reportPath: result['report'] as String,
    );
  }

  final bool skipBuild;
  final bool skipTests;
  final bool skipOutdated;
  final bool failFast;
  final String reportPath;

  final List<_CheckResult> _results = [];

  Future<int> run() async {
    _printHeader();

    if (!File('pubspec.yaml').existsSync()) {
      stderr.writeln('pubspec.yaml not found. Run this command from your Flutter project root.');
      return 1;
    }

    await _runCommand('Flutter version', 'flutter', ['--version'], required: true);
    await _runCommand('Clean project', 'flutter', ['clean'], required: true);
    await _runCommand('Get packages', 'flutter', ['pub', 'get'], required: true);
    await _runCommand('Format code', 'dart', ['format', 'lib', 'test', 'integration_test', '.']);
    await _runCommand('Static analysis', 'flutter', ['analyze'], required: true);

    if (!skipTests) {
      await _runCommand('Unit/widget tests', 'flutter', ['test']);
    }

    if (!skipOutdated) {
      await _runCommand('Dependency outdated check', 'flutter', ['pub', 'outdated']);
    }

    await _scanProjectFiles();

    if (!skipBuild) {
      await _runCommand('Android debug build', 'flutter', ['build', 'apk', '--debug'], required: true);
    }

    await _writeReport();
    _printSummary();

    return _results.any((result) => result.failed && result.required) ? 1 : 0;
  }

  Future<void> _runCommand(
    String title,
    String executable,
    List<String> arguments, {
    bool required = false,
  }) async {
    stdout.writeln('\n▶ $title');
    final result = await Process.run(executable, arguments, runInShell: true);
    final success = result.exitCode == 0;

    if (result.stdout.toString().trim().isNotEmpty) {
      stdout.writeln(result.stdout);
    }
    if (result.stderr.toString().trim().isNotEmpty) {
      stderr.writeln(result.stderr);
    }

    _results.add(_CheckResult(
      title: title,
      command: '$executable ${arguments.join(' ')}',
      exitCode: result.exitCode,
      required: required,
      notes: success ? 'Passed' : 'Failed',
    ));

    if (!success && required && failFast) {
      await _writeReport();
      exit(result.exitCode);
    }
  }

  Future<void> _scanProjectFiles() async {
    stdout.writeln('\n▶ Project hygiene scan');

    final dartFiles = Directory('lib').existsSync()
        ? Directory('lib').listSync(recursive: true).whereType<File>().where((file) => file.path.endsWith('.dart')).toList()
        : <File>[];

    var printCount = 0;
    var todoCount = 0;
    var getPutCount = 0;

    for (final file in dartFiles) {
      final text = await file.readAsString();
      printCount += RegExp(r'\bprint\s*\(').allMatches(text).length;
      todoCount += RegExp(r'\b(TODO|FIXME)\b').allMatches(text).length;
      getPutCount += RegExp(r'Get\.put\s*\(').allMatches(text).length;
    }

    final notes = <String>[
      'Dart files scanned: ${dartFiles.length}',
      'print() usages: $printCount',
      'TODO/FIXME comments: $todoCount',
      'Get.put() usages: $getPutCount',
    ].join('\n');

    stdout.writeln(notes);

    _results.add(_CheckResult(
      title: 'Project hygiene scan',
      command: 'internal scan',
      exitCode: 0,
      required: false,
      notes: notes,
    ));
  }

  Future<void> _writeReport() async {
    final buffer = StringBuffer()
      ..writeln('# Flutter Pre-SQA Report')
      ..writeln()
      ..writeln('Generated: ${DateTime.now().toIso8601String()}')
      ..writeln()
      ..writeln('## Automated Checks')
      ..writeln()
      ..writeln('| Check | Command | Status | Required |')
      ..writeln('|---|---|---|---|');

    for (final result in _results) {
      buffer.writeln('| ${result.title} | `${result.command}` | ${result.failed ? 'FAIL' : 'PASS'} | ${result.required ? 'Yes' : 'No'} |');
    }

    buffer
      ..writeln()
      ..writeln('## Manual SQA Handoff Checklist')
      ..writeln()
      ..writeln('- [ ] UI compared with Figma')
      ..writeln('- [ ] Login/signup/forgot password verified')
      ..writeln('- [ ] Required field validations verified')
      ..writeln('- [ ] API success/error/no-internet states verified')
      ..writeln('- [ ] CRUD flows verified')
      ..writeln('- [ ] Permissions verified')
      ..writeln('- [ ] Payments/subscriptions verified, if applicable')
      ..writeln('- [ ] Role-based access verified')
      ..writeln('- [ ] Small and large device layouts verified')
      ..writeln('- [ ] Regression testing completed')
      ..writeln()
      ..writeln('## Notes')
      ..writeln()
      ..writeln('Business logic still needs manual verification against client requirements.');

    await File(reportPath).writeAsString(buffer.toString());
    stdout.writeln('\nReport generated: $reportPath');
  }

  void _printHeader() {
    stdout.writeln('==============================');
    stdout.writeln(' FLUTTER PRE-SQA RUNNER');
    stdout.writeln('==============================');
  }

  void _printSummary() {
    final failedRequired = _results.where((result) => result.failed && result.required).length;
    final failedOptional = _results.where((result) => result.failed && !result.required).length;

    stdout.writeln('\n==============================');
    stdout.writeln(' SUMMARY');
    stdout.writeln('==============================');
    stdout.writeln('Required failures: $failedRequired');
    stdout.writeln('Optional failures: $failedOptional');
    stdout.writeln('Report: $reportPath');
  }
}

class _CheckResult {
  _CheckResult({
    required this.title,
    required this.command,
    required this.exitCode,
    required this.required,
    required this.notes,
  });

  final String title;
  final String command;
  final int exitCode;
  final bool required;
  final String notes;

  bool get failed => exitCode != 0;
}
