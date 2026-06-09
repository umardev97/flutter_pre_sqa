# flutter_pre_sqa

A developer-first Flutter pre-SQA automation tool for validating Flutter projects before handing them to QA/SQA teams.

## What it does

- Validates Flutter project structure and toolchain
- Runs analysis, tests, dependency audits, and builds
- Scans code hygiene for `print()`, `debugPrint()`, `TODO`, `FIXME`, `HACK`, empty catch blocks, and large files
- Generates Markdown, HTML, and JSON reports
- Supports `pre_sqa.yaml` configuration for project-specific checks
- Provides CLI commands for init, doctor, report, fix, clean, ci, audit, and version

## Install

Add to your Flutter or Dart project as a dev dependency:

```yaml
dev_dependencies:
  flutter_pre_sqa: ^0.1.0
```

Then run:

```bash
flutter pub get
dart run flutter_pre_sqa
```

Or install globally with `dart pub global activate` if preferred.

## CLI commands

```bash
# Default validation run
dart run flutter_pre_sqa

# Create a sample configuration
dart run flutter_pre_sqa init

# Verify Flutter/Dart toolchain
dart run flutter_pre_sqa doctor

# Generate reports
dart run flutter_pre_sqa report --markdown --html --json

# Apply formatting fixes
dart run flutter_pre_sqa fix

# Clean generated reports and build artifacts
dart run flutter_pre_sqa clean

# Run CI-friendly validation
dart run flutter_pre_sqa ci --coverage

# Run dependency and hygiene audit only
dart run flutter_pre_sqa audit

# Show package version
dart run flutter_pre_sqa version
```

## CLI flags

- `--fix`
- `--strict`
- `--ci`
- `--skip-build`
- `--skip-tests`
- `--android`
- `--ios`
- `--coverage`
- `--json`
- `--html`
- `--markdown`
- `--verbose`

Example:

```bash
dart run flutter_pre_sqa --strict --coverage --html --json
```

## Configuration: `pre_sqa.yaml`

Create or update `pre_sqa.yaml` in your project root.

```yaml
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
```

## Example usage

```bash
dart run flutter_pre_sqa audit --verbose
```

## Example programmatic usage

```dart
import 'package:flutter_pre_sqa/flutter_pre_sqa.dart';

Future<void> main() async {
  final cli = FlutterPreSqaCli();
  await cli.run([]);
}
```

## Report outputs

Reports include:

- Project name
- Flutter and Dart versions
- Total warnings and errors
- Passed and failed checks
- Dependency issues
- TODO/FIXME/HACK counts
- Print/debugPrint counts
- Build and test status

## Publishing to pub.dev

1. Confirm the package name is available on pub.dev.
2. Update `version` in `pubspec.yaml`.
3. Run `dart pub publish --dry-run`.
4. If successful, run `dart pub publish`.

## CI/CD examples

See `.github/workflows/flutter_pre_sqa.yml`, `.gitlab-ci.yml`, `bitbucket-pipelines.yml`, `codemagic.yaml`, and `Jenkinsfile`.

## Important

This CLI helps catch technical and hygiene issues before QA, but it does not replace manual business logic validation or design review.
