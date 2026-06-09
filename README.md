# flutter_pre_sqa

`flutter_pre_sqa` is a developer-first Dart CLI package for validating Flutter projects before handing them to QA or SQA teams.

## Features

- Verify Flutter and Dart toolchain health
- Run static analysis and unit/widget tests
- Audit package dependencies
- Scan source code for hygiene issues like `TODO`, `FIXME`, `HACK`, `print()`, `debugPrint()`, empty catch blocks, and large files
- Generate Markdown, HTML, and JSON reports
- Produce SQA handoff and release readiness summaries
- Support per-project configuration via `pre_sqa.yaml`
- Provide CI-friendly execution with strict validation options

## Installation

Add `flutter_pre_sqa` to your project as a dev dependency:

```yaml
dev_dependencies:
  flutter_pre_sqa: ^0.1.0
```

Then install:

```bash
flutter pub get
```

Run it from your project root:

```bash
dart run flutter_pre_sqa
```

## Usage

### Create a sample config

```bash
dart run flutter_pre_sqa init
```

### Run validation and report generation

```bash
dart run flutter_pre_sqa report --markdown --html --json
```

### Run CI-friendly validation

```bash
dart run flutter_pre_sqa ci --coverage
```

### Run a dependency and hygiene audit only

```bash
dart run flutter_pre_sqa audit
```

### Skip builds for packages or libraries

```bash
dart run flutter_pre_sqa --skip-build
```

### Example with verbose logging

```bash
dart run flutter_pre_sqa ci --coverage --verbose
```

## CLI commands

- `init` — create a sample `pre_sqa.yaml`
- `doctor` — verify Flutter/Dart environment
- `report` — run checks and generate reports
- `fix` — run formatter and auto-fixes
- `clean` — delete generated reports and build artifacts
- `ci` — run strict CI validation
- `audit` — run dependency and hygiene audit only
- `version` — show package version

## Configuration: `pre_sqa.yaml`

Create or update `pre_sqa.yaml` in your project root to override defaults.

```yaml
project:
  name: My App

checks:
  analyze: true
  tests: true
  integrationTests: true
  buildAndroid: false
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

## Programmatic usage

```dart
import 'package:flutter_pre_sqa/flutter_pre_sqa.dart';

Future<void> main() async {
  final cli = FlutterPreSqaCli();
  await cli.run([]);
}
```

## Report output

When enabled, generated reports include:

- Project metadata
- Flutter and Dart versions
- Passed and failed checks
- Dependency audit notes
- Code hygiene counts
- Build and test status
- Architecture, security, and performance scores
- AI review summary

## GitHub Actions

Use the example workflow in `.github/workflows/flutter_pre_sqa.yml` for CI validation.

## License

`flutter_pre_sqa` is released under the MIT License.
