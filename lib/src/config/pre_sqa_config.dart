import 'dart:io';

import 'package:yaml/yaml.dart';

/// Supported report output formats for `flutter_pre_sqa`.
enum ReportFormat {
  /// Generate Markdown reports.
  markdown,

  /// Generate HTML reports.
  html,

  /// Generate JSON reports.
  json,

  /// Generate all supported report formats.
  all,
}

/// Configuration model for the `flutter_pre_sqa` package.
///
/// This class loads YAML configuration from `pre_sqa.yaml` and exposes
/// defaults when the file is missing or incomplete.
class PreSqaConfig {
  /// Creates a configuration model from the provided values.
  PreSqaConfig({
    required this.project,
    required this.checks,
    required this.rules,
    required this.report,
    required this.exclude,
    required this.scanDirectories,
  });

  /// Project metadata configuration.
  final ProjectConfig project;

  /// Validation checks configuration.
  final ChecksConfig checks;

  /// Rules that control failure behavior.
  final RulesConfig rules;

  /// Report generation configuration.
  final ReportConfig report;

  /// Glob patterns for directories and files to exclude from scanning.
  final List<String> exclude;

  /// Directories to include in source hygiene scans.
  final List<String> scanDirectories;

  /// Creates a default configuration when no config file exists.
  factory PreSqaConfig.empty() {
    return PreSqaConfig(
      project: ProjectConfig(name: 'Flutter Project'),
      checks: ChecksConfig.defaults(),
      rules: RulesConfig.defaults(),
      report: ReportConfig.defaults(),
      exclude: ['build/**', '.dart_tool/**', 'ios/Pods/**'],
      scanDirectories: ['lib', 'test', 'integration_test'],
    );
  }

  /// Creates a configuration instance from YAML content.
  factory PreSqaConfig.fromYaml(String yamlContent) {
    final map = loadYaml(yamlContent);
    if (map is! YamlMap) {
      return PreSqaConfig.empty();
    }
    return PreSqaConfig(
      project: ProjectConfig.fromYaml(map['project']),
      checks: ChecksConfig.fromYaml(map['checks']),
      rules: RulesConfig.fromYaml(map['rules']),
      report: ReportConfig.fromYaml(map['report']),
      exclude: _toStringList(map['exclude'],
          defaultValue: ['build/**', '.dart_tool/**', 'ios/Pods/**']),
      scanDirectories: _toStringList(map['scan_directories'],
          defaultValue: ['lib', 'test', 'integration_test']),
    );
  }

  /// Returns a copy of this config with updated scan directories.
  PreSqaConfig copyWith({List<String>? scanDirectories}) {
    return PreSqaConfig(
      project: project,
      checks: checks,
      rules: rules,
      report: report,
      exclude: exclude,
      scanDirectories: scanDirectories ?? this.scanDirectories,
    );
  }

  static List<String> _toStringList(dynamic value,
      {required List<String> defaultValue}) {
    if (value is YamlList) {
      return value.map((item) => item.toString()).toList();
    }
    if (value is List) {
      return value.map((item) => item.toString()).toList();
    }
    return defaultValue;
  }

  /// Loads the configuration from the given [path].
  ///
  /// If the file does not exist, default configuration values are returned.
  static Future<PreSqaConfig> load([String path = 'pre_sqa.yaml']) async {
    final file = File(path);
    if (!file.existsSync()) {
      return PreSqaConfig.empty();
    }
    final content = await file.readAsString();
    return PreSqaConfig.fromYaml(content);
  }

  /// Sample YAML configuration that can be written to disk.
  static String get sampleYaml => '''
project:
  name: My App

checks:
  analyze: true
  tests: true
  integrationTests: true
  buildAndroid: true
  buildIos: false
  scanTodos: true
  scanPrints: true
  scanFixmes: true
  scanHacks: true
  dependencyAudit: true

rules:
  failOnWarnings: false
  failOnTodos: false
  failOnPrints: true

report:
  format: markdown
  output: pre_sqa_report.md

exclude:
  - build/**
  - .dart_tool/**
  - ios/Pods/**

scan_directories:
  - lib
  - test
  - integration_test
''';
}

/// Basic project metadata configuration.
class ProjectConfig {
  /// Creates project metadata with a required [name].
  ProjectConfig({required this.name});

  /// The project display name used in reports.
  final String name;

  /// Creates project metadata from YAML parsed data.
  factory ProjectConfig.fromYaml(dynamic yaml) {
    if (yaml is YamlMap && yaml['name'] != null) {
      return ProjectConfig(name: yaml['name'].toString());
    }
    return ProjectConfig(name: 'Flutter Project');
  }
}

/// Configuration for the validation checks that should run.
class ChecksConfig {
  /// Creates a checks configuration.
  ChecksConfig({
    required this.analyze,
    required this.tests,
    required this.integrationTests,
    required this.buildAndroid,
    required this.buildIos,
    required this.scanTodos,
    required this.scanPrints,
    required this.scanFixmes,
    required this.scanHacks,
    required this.dependencyAudit,
  });

  /// Enable static analysis.
  final bool analyze;

  /// Enable unit/widget tests.
  final bool tests;

  /// Enable integration tests.
  final bool integrationTests;

  /// Enable Android build checks.
  final bool buildAndroid;

  /// Enable iOS build checks.
  final bool buildIos;

  /// Enable scanning for TODO items.
  final bool scanTodos;

  /// Enable scanning for print statements.
  final bool scanPrints;

  /// Enable scanning for FIXME items.
  final bool scanFixmes;

  /// Enable scanning for HACK items.
  final bool scanHacks;

  /// Enable dependency audit checks.
  final bool dependencyAudit;

  /// Returns the default checks configuration.
  factory ChecksConfig.defaults() {
    return ChecksConfig(
      analyze: true,
      tests: true,
      integrationTests: true,
      buildAndroid: true,
      buildIos: false,
      scanTodos: true,
      scanPrints: true,
      scanFixmes: true,
      scanHacks: true,
      dependencyAudit: true,
    );
  }

  /// Creates a checks configuration from YAML parsed values.
  factory ChecksConfig.fromYaml(dynamic yaml) {
    if (yaml is! YamlMap) return ChecksConfig.defaults();
    return ChecksConfig(
      analyze: _valueAsBool(yaml['analyze'], true),
      tests: _valueAsBool(yaml['tests'], true),
      integrationTests: _valueAsBool(yaml['integrationTests'], true),
      buildAndroid: _valueAsBool(yaml['buildAndroid'], true),
      buildIos: _valueAsBool(yaml['buildIos'], false),
      scanTodos: _valueAsBool(yaml['scanTodos'], true),
      scanPrints: _valueAsBool(yaml['scanPrints'], true),
      scanFixmes: _valueAsBool(yaml['scanFixmes'], true),
      scanHacks: _valueAsBool(yaml['scanHacks'], true),
      dependencyAudit: _valueAsBool(yaml['dependencyAudit'], true),
    );
  }
}

/// Rules that govern when validation should fail.
class RulesConfig {
  /// Creates a rules configuration.
  RulesConfig({
    required this.failOnWarnings,
    required this.failOnTodos,
    required this.failOnPrints,
  });

  /// Fail when warnings are present.
  final bool failOnWarnings;

  /// Fail when TODO items are present.
  final bool failOnTodos;

  /// Fail when `print()` or `debugPrint()` artifacts are present.
  final bool failOnPrints;

  /// Returns the default rules configuration.
  factory RulesConfig.defaults() {
    return RulesConfig(
      failOnWarnings: false,
      failOnTodos: false,
      failOnPrints: true,
    );
  }

  /// Creates a rules configuration from YAML parsed values.
  factory RulesConfig.fromYaml(dynamic yaml) {
    if (yaml is! YamlMap) return RulesConfig.defaults();
    return RulesConfig(
      failOnWarnings: _valueAsBool(yaml['failOnWarnings'], false),
      failOnTodos: _valueAsBool(yaml['failOnTodos'], false),
      failOnPrints: _valueAsBool(yaml['failOnPrints'], true),
    );
  }
}

/// Report output configuration.
class ReportConfig {
  /// Creates report output configuration.
  ReportConfig({required this.format, required this.output});

  /// The desired report format.
  final ReportFormat format;

  /// The base file path used for generated reports.
  final String output;

  /// Returns the default report configuration.
  factory ReportConfig.defaults() {
    return ReportConfig(
        format: ReportFormat.markdown, output: 'pre_sqa_report.md');
  }

  /// Creates report configuration from YAML parsed values.
  factory ReportConfig.fromYaml(dynamic yaml) {
    if (yaml is! YamlMap) return ReportConfig.defaults();

    final formatName = yaml['format']?.toString().toLowerCase();
    return ReportConfig(
      format: _parseFormat(formatName),
      output: yaml['output']?.toString() ?? 'pre_sqa_report.md',
    );
  }
}

bool _valueAsBool(dynamic value, bool defaultValue) {
  if (value is bool) return value;
  if (value is String) return value.toLowerCase() == 'true';
  return defaultValue;
}

ReportFormat _parseFormat(String? value) {
  switch (value) {
    case 'html':
      return ReportFormat.html;
    case 'json':
      return ReportFormat.json;
    case 'all':
      return ReportFormat.all;
    case 'markdown':
    default:
      return ReportFormat.markdown;
  }
}
