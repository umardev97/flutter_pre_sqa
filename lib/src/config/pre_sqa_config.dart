import 'dart:io';

import 'package:yaml/yaml.dart';

enum ReportFormat { markdown, html, json, all }

class PreSqaConfig {
  PreSqaConfig({
    required this.project,
    required this.checks,
    required this.rules,
    required this.report,
    required this.exclude,
    required this.scanDirectories,
  });

  final ProjectConfig project;
  final ChecksConfig checks;
  final RulesConfig rules;
  final ReportConfig report;
  final List<String> exclude;
  final List<String> scanDirectories;

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

  static Future<PreSqaConfig> load([String path = 'pre_sqa.yaml']) async {
    final file = File(path);
    if (!file.existsSync()) {
      return PreSqaConfig.empty();
    }
    final content = await file.readAsString();
    return PreSqaConfig.fromYaml(content);
  }

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

class ProjectConfig {
  ProjectConfig({required this.name});
  final String name;

  factory ProjectConfig.fromYaml(dynamic yaml) {
    if (yaml is YamlMap && yaml['name'] != null) {
      return ProjectConfig(name: yaml['name'].toString());
    }
    return ProjectConfig(name: 'Flutter Project');
  }
}

class ChecksConfig {
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

  final bool analyze;
  final bool tests;
  final bool integrationTests;
  final bool buildAndroid;
  final bool buildIos;
  final bool scanTodos;
  final bool scanPrints;
  final bool scanFixmes;
  final bool scanHacks;
  final bool dependencyAudit;

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

class RulesConfig {
  RulesConfig({
    required this.failOnWarnings,
    required this.failOnTodos,
    required this.failOnPrints,
  });

  final bool failOnWarnings;
  final bool failOnTodos;
  final bool failOnPrints;

  factory RulesConfig.defaults() {
    return RulesConfig(
      failOnWarnings: false,
      failOnTodos: false,
      failOnPrints: true,
    );
  }

  factory RulesConfig.fromYaml(dynamic yaml) {
    if (yaml is! YamlMap) return RulesConfig.defaults();
    return RulesConfig(
      failOnWarnings: _valueAsBool(yaml['failOnWarnings'], false),
      failOnTodos: _valueAsBool(yaml['failOnTodos'], false),
      failOnPrints: _valueAsBool(yaml['failOnPrints'], true),
    );
  }
}

class ReportConfig {
  ReportConfig({required this.format, required this.output});
  final ReportFormat format;
  final String output;

  factory ReportConfig.defaults() {
    return ReportConfig(
        format: ReportFormat.markdown, output: 'pre_sqa_report.md');
  }

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
