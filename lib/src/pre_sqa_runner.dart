import 'dart:io';

import 'config/pre_sqa_config.dart';
import 'models/check_result.dart';
import 'services/environment_service.dart';
import 'services/process_runner.dart';

class PreSqaRunner {
  PreSqaRunner(
      {required this.config,
      this.verbose = false,
      ProcessRunner? processRunner})
      : processRunner = processRunner ?? ProcessRunner(),
        environment = EnvironmentService();

  final PreSqaConfig config;
  final bool verbose;
  final ProcessRunner processRunner;
  final EnvironmentService environment;
  final List<CheckResult> results = [];
  String coverageSummary = 'Not generated';

  Future<int> run({
    bool strict = false,
    bool ci = false,
    bool coverage = false,
    bool skipBuild = false,
    bool skipTests = false,
    bool buildAndroid = false,
    bool buildIos = false,
  }) async {
    _printHeader();

    if (!File('pubspec.yaml').existsSync()) {
      stderr
          .writeln('pubspec.yaml not found. Run from a Flutter project root.');
      return 1;
    }

    final envCheck = await environment.verify(verbose: verbose);
    if (!envCheck.success) {
      stderr.writeln(envCheck.message);
      return 1;
    }

    await _runCommand('Flutter clean', 'flutter', ['clean'], required: true);
    await _runCommand('Get dependencies', 'flutter', ['pub', 'get'],
        required: true);

    if (config.checks.analyze) {
      await _runCommand('Static analysis', 'flutter', ['analyze'],
          required: strict || config.rules.failOnWarnings);
    }

    if (!skipTests && config.checks.tests) {
      if (coverage) {
        await _runCommand('Unit/widget tests with coverage', 'flutter',
            ['test', '--coverage'],
            required: true);
        coverageSummary = await _parseLcovCoverage('coverage/lcov.info');
      } else {
        await _runCommand('Unit/widget tests', 'flutter', ['test'],
            required: true);
      }
    }

    if (config.checks.dependencyAudit) {
      await _runCommand('Dependency audit', 'flutter', ['pub', 'outdated'],
          required: false);
    }

    await _runProjectScan();

    if (!skipBuild) {
      final runAndroid = buildAndroid || config.checks.buildAndroid;
      final runIos = buildIos || config.checks.buildIos;
      if (runAndroid) {
        await _runCommand(
            'Android debug build', 'flutter', ['build', 'apk', '--debug'],
            required: true);
        await _runCommand(
            'Android release build', 'flutter', ['build', 'apk', '--release'],
            required: true);
      }
      if (runIos) {
        await _runCommand(
            'iOS debug build', 'flutter', ['build', 'ios', '--debug'],
            required: true);
        await _runCommand(
            'iOS release build', 'flutter', ['build', 'ios', '--release'],
            required: true);
      }
    }

    _printSummary();
    return results.any((result) => result.failed && result.required) ? 1 : 0;
  }

  Future<int> runAudit() async {
    _printHeader();
    final envCheck = await environment.verify(verbose: verbose);
    if (!envCheck.success) {
      stderr.writeln(envCheck.message);
      return 1;
    }

    if (config.checks.dependencyAudit) {
      await _runCommand('Dependency audit', 'flutter', ['pub', 'outdated'],
          required: false);
    }
    await _runProjectScan();
    _printSummary();
    return results.any((result) => result.failed && result.required) ? 1 : 0;
  }

  Future<void> runFixes() async {
    await _runCommand('Format Dart code', 'dart', ['format', '.'],
        required: false);
    await _runCommand('Apply Dart fixes', 'dart', ['fix', '--apply'],
        required: false);
  }

  Future<void> _runProjectScan() async {
    final directories = config.scanDirectories
        .where((dir) => Directory(dir).existsSync())
        .toList();
    final dartFiles = directories
        .expand(
            (dir) => Directory(dir).listSync(recursive: true).whereType<File>())
        .where((file) => file.path.endsWith('.dart'))
        .toList();

    var printCount = 0;
    var debugPrintCount = 0;
    var todoCount = 0;
    var fixmeCount = 0;
    var hackCount = 0;
    var emptyCatchCount = 0;
    var largeFileCount = 0;

    for (final file in dartFiles) {
      final text = await file.readAsString();
      printCount += RegExp(r'\bprint\s*\(').allMatches(text).length;
      debugPrintCount += RegExp(r'\bdebugPrint\s*\(').allMatches(text).length;
      todoCount += RegExp(r'\bTODO\b').allMatches(text).length;
      fixmeCount += RegExp(r'\bFIXME\b').allMatches(text).length;
      hackCount += RegExp(r'\bHACK\b').allMatches(text).length;
      emptyCatchCount +=
          RegExp(r'catch\s*\([^)]*\)\s*\{\s*\}').allMatches(text).length;
      if (text.split('\n').length > 500) {
        largeFileCount += 1;
      }
    }

    final notes = <String>[
      'Directories scanned: ${directories.join(', ')}',
      'Dart files scanned: ${dartFiles.length}',
      'print() usages: $printCount',
      'debugPrint() usages: $debugPrintCount',
      'TODO comments: $todoCount',
      'FIXME comments: $fixmeCount',
      'HACK comments: $hackCount',
      'Empty catch blocks: $emptyCatchCount',
      'Large files >500 lines: $largeFileCount',
    ].join('\n');

    results.add(CheckResult(
      title: 'Project hygiene scan',
      command: 'internal scan',
      exitCode: 0,
      required: false,
      notes: notes,
    ));
  }

  Future<void> _runCommand(
      String title, String executable, List<String> arguments,
      {bool required = false}) async {
    stdout.writeln('\n▶ $title');
    final result = await processRunner.run(executable, arguments);
    if (result.stdout.isNotEmpty) {
      stdout.writeln(result.stdout);
    }
    if (result.stderr.isNotEmpty) {
      stderr.writeln(result.stderr);
    }

    if (verbose && result.stdout.isEmpty && result.stderr.isEmpty) {
      stdout.writeln('Command completed with exit code ${result.exitCode}.');
    }

    results.add(CheckResult(
      title: title,
      command: '$executable ${arguments.join(' ')}',
      exitCode: result.exitCode,
      required: required,
      notes: result.stderr.isNotEmpty
          ? result.stderr
          : result.stdout.isNotEmpty
              ? result.stdout
              : 'Passed',
    ));
  }

  Future<String> _parseLcovCoverage(String path) async {
    final file = File(path);
    if (!file.existsSync()) return 'Coverage file not found: $path';

    final lines = await file.readAsLines();
    var total = 0;
    var covered = 0;

    for (final line in lines) {
      if (line.startsWith('DA:')) {
        total += 1;
        final parts = line.substring(3).split(',');
        if (parts.length == 2 &&
            int.tryParse(parts[1]) != null &&
            int.parse(parts[1]) > 0) {
          covered += 1;
        }
      }
    }

    if (total == 0) return 'No coverage data available.';
    final percent = (covered / total * 100).toStringAsFixed(1);
    return 'Coverage: $covered/$total lines ($percent%).';
  }

  void _printHeader() {
    stdout.writeln('==============================');
    stdout.writeln(' FLUTTER PRE-SQA VALIDATION');
    stdout.writeln('==============================');
    stdout.writeln('Project: ${config.project.name}');
  }

  void _printSummary() {
    final failedRequired =
        results.where((result) => result.failed && result.required).length;
    final failedOptional =
        results.where((result) => result.failed && !result.required).length;
    stdout.writeln('\n==============================');
    stdout.writeln(' SUMMARY');
    stdout.writeln('==============================');
    stdout.writeln('Required failures: $failedRequired');
    stdout.writeln('Optional failures: $failedOptional');
    stdout.writeln('Coverage: $coverageSummary');
  }
}
