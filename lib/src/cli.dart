import 'dart:io';

import 'package:args/args.dart';

import 'config/pre_sqa_config.dart';
import 'pre_sqa_runner.dart';
import 'services/environment_service.dart';
import 'reports/report_generator.dart';

/// CLI entrypoint for the `flutter_pre_sqa` package.
///
/// This class handles command parsing and delegates execution to the runner
/// and report generator.
class FlutterPreSqaCli {
  /// The package name used by the CLI.
  static const packageName = 'flutter_pre_sqa';

  /// A short description of the package functionality.
  static const packageDescription =
      'A developer-first Flutter pre-SQA automation tool for Flutter projects.';

  /// The current package version.
  static const packageVersion = '0.1.0';

  /// Runs the CLI with the provided [arguments].
  ///
  /// Returns an exit code suitable for process termination.
  Future<int> run(List<String> arguments) async {
    final command = arguments.isEmpty ? 'run' : arguments.first;
    final commandArgs = arguments.skip(1).toList();

    switch (command) {
      case 'init':
        return _handleInit(commandArgs);
      case 'doctor':
        return _handleDoctor(commandArgs);
      case 'report':
        return _handleReport(commandArgs);
      case 'fix':
        return _handleFix(commandArgs);
      case 'clean':
        return _handleClean(commandArgs);
      case 'ci':
        return _handleCi(commandArgs);
      case 'audit':
        return _handleAudit(commandArgs);
      case 'version':
        return _handleVersion();
      case 'help':
      case '-h':
      case '--help':
        _printUsage();
        return 0;
      default:
        return _handleRun(arguments);
    }
  }

  /// Creates a sample configuration file.
  int _handleInit(List<String> arguments) {
    final fileName = arguments.isNotEmpty ? arguments.first : 'pre_sqa.yaml';
    if (File(fileName).existsSync()) {
      stderr.writeln('Config file already exists: $fileName');
      return 1;
    }

    final sample = PreSqaConfig.sampleYaml;
    File(fileName).writeAsStringSync(sample);
    stdout.writeln('Created sample config: $fileName');
    return 0;
  }

  /// Verifies the local Flutter and Dart environment.
  Future<int> _handleDoctor(List<String> arguments) async {
    final verbose = arguments.contains('--verbose');
    final env = EnvironmentService();
    final result = await env.verify(verbose: verbose);
    stdout.writeln(result.message);
    return result.success ? 0 : 1;
  }

  /// Runs validation report generation using the `report` command.
  Future<int> _handleReport(List<String> arguments) async {
    final parser = ArgParser()
      ..addFlag('json', negatable: false, help: 'Generate JSON report.')
      ..addFlag('html', negatable: false, help: 'Generate HTML report.')
      ..addFlag('markdown', negatable: false, help: 'Generate Markdown report.')
      ..addOption('output',
          defaultsTo: 'pre_sqa_report',
          help: 'Base output path without extension.')
      ..addFlag('verbose', negatable: false, help: 'Show diagnostic logs.');

    final result = parser.parse(arguments);
    final config = await PreSqaConfig.load();
    final runner =
        PreSqaRunner(config: config, verbose: result['verbose'] as bool);
    final score = await runner.run();

    final reportGenerator = ReportGenerator(
      results: runner.results,
      config: config,
      projectName: config.project.name,
    );

    await reportGenerator.writeReports(
      basePath: result['output'] as String,
      includeJson: result['json'] as bool,
      includeHtml: result['html'] as bool,
      includeMarkdown: result['markdown'] as bool,
    );

    return score;
  }

  /// Runs formatting and fix actions.
  Future<int> _handleFix(List<String> arguments) async {
    final parser = ArgParser()
      ..addFlag('verbose', negatable: false, help: 'Show diagnostic logs.');

    final result = parser.parse(arguments);
    final verbose = result['verbose'] as bool;
    final runner =
        PreSqaRunner(config: await PreSqaConfig.load(), verbose: verbose);

    stdout.writeln('Running formatter and basic fix actions...');
    await runner.runFixes();
    stdout.writeln(
        'Fix actions complete. Review output for any additional manual changes.');
    return 0;
  }

  /// Deletes generated reports, coverage output, and temporary build directories.
  Future<int> _handleClean(List<String> arguments) async {
    final directories = <String>['build', '.dart_tool', 'coverage'];
    for (final dir in directories) {
      final entity = Directory(dir);
      if (entity.existsSync()) {
        entity.deleteSync(recursive: true);
        stdout.writeln('Removed $dir');
      }
    }
    final reports = [
      'pre_sqa_report.md',
      'pre_sqa_report.html',
      'pre_sqa_report.json'
    ];
    for (final report in reports) {
      final file = File(report);
      if (file.existsSync()) {
        file.deleteSync();
        stdout.writeln('Removed $report');
      }
    }
    return 0;
  }

  /// Runs strict CI validation.
  Future<int> _handleCi(List<String> arguments) async {
    final config = await PreSqaConfig.load();
    final runner =
        PreSqaRunner(config: config, verbose: arguments.contains('--verbose'));
    final exitCode = await runner.run(
        strict: true, ci: true, coverage: arguments.contains('--coverage'));
    return exitCode;
  }

  /// Runs dependency audit and hygiene scan only.
  Future<int> _handleAudit(List<String> arguments) async {
    final parser = ArgParser()
      ..addFlag('verbose', negatable: false, help: 'Show diagnostic logs.');

    final result = parser.parse(arguments);
    final config = await PreSqaConfig.load();
    final runner =
        PreSqaRunner(config: config, verbose: result['verbose'] as bool);
    return await runner.runAudit();
  }

  /// Prints the package version.
  int _handleVersion() {
    stdout.writeln('$packageName $packageVersion');
    return 0;
  }

  /// Runs the default validation flow.
  Future<int> _handleRun(List<String> arguments) async {
    final parser = ArgParser()
      ..addFlag('fix', negatable: false, help: 'Run fix actions after checks.')
      ..addFlag('strict',
          negatable: false, help: 'Fail on warnings and optional issues.')
      ..addFlag('ci',
          negatable: false, help: 'Run in CI mode with JSON output.')
      ..addFlag('skip-build',
          negatable: false, help: 'Skip Android and iOS builds.')
      ..addFlag('skip-tests', negatable: false, help: 'Skip tests.')
      ..addFlag('android', negatable: false, help: 'Run Android builds.')
      ..addFlag('ios', negatable: false, help: 'Run iOS builds.')
      ..addFlag('coverage', negatable: false, help: 'Generate coverage report.')
      ..addFlag('json', negatable: false, help: 'Generate JSON report.')
      ..addFlag('html', negatable: false, help: 'Generate HTML report.')
      ..addFlag('markdown', negatable: false, help: 'Generate Markdown report.')
      ..addFlag('verbose', negatable: false, help: 'Show verbose logs.')
      ..addOption('scan-dirs',
          defaultsTo: 'lib,test,integration_test',
          help: 'Comma-separated directories to scan for hygiene issues.')
      ..addOption('report',
          defaultsTo: 'pre_sqa_report',
          help: 'Base output path for generated reports.');

    final result = parser.parse(arguments);
    final config = await PreSqaConfig.load();
    final overrideScanDirs = (result['scan-dirs'] as String)
        .split(',')
        .map((segment) => segment.trim())
        .where((segment) => segment.isNotEmpty)
        .toList();

    final runner = PreSqaRunner(
      config: config.copyWith(scanDirectories: overrideScanDirs),
      verbose: result['verbose'] as bool,
    );

    final exitCode = await runner.run(
      strict: result['strict'] as bool,
      ci: result['ci'] as bool,
      coverage: result['coverage'] as bool,
      skipBuild: result['skip-build'] as bool,
      skipTests: result['skip-tests'] as bool,
      buildAndroid: result['android'] as bool,
      buildIos: result['ios'] as bool,
    );

    final reportGenerator = ReportGenerator(
      results: runner.results,
      config: runner.config,
      projectName: runner.config.project.name,
      flutterVersion: runner.environment.flutterVersion,
      dartVersion: runner.environment.dartVersion,
    );

    await reportGenerator.writeReports(
      basePath: result['report'] as String,
      includeJson: result['json'] as bool || result['ci'] as bool,
      includeHtml: result['html'] as bool,
      includeMarkdown: result['markdown'] as bool ||
          !(result['json'] as bool) && !(result['html'] as bool),
    );

    if (result['fix'] as bool) {
      await runner.runFixes();
    }

    return exitCode;
  }

  /// Prints CLI usage information.
  void _printUsage() {
    stdout.writeln('Usage: flutter_pre_sqa [command] [options]');
    stdout.writeln('Commands:');
    stdout.writeln('  init       Create a sample pre_sqa.yaml config file.');
    stdout.writeln('  doctor     Verify Flutter, Dart, and toolchain.');
    stdout.writeln('  report     Run checks and generate reports.');
    stdout.writeln('  fix        Run formatter and basic auto-fixes.');
    stdout
        .writeln('  clean      Delete generated reports and build artifacts.');
    stdout.writeln('  ci         Run strict CI validation.');
    stdout.writeln('  audit      Run dependency and hygiene audit only.');
    stdout.writeln('  version    Show package version.');
    stdout.writeln('  help       Show this help message.');
    stdout.writeln(
        'If no command is provided, the default validation run is executed.');
  }
}
