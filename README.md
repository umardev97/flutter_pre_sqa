# flutter_pre_sqa

A reusable Flutter/Dart CLI package for running pre-SQA checks before sharing a build with QA/SQA teams.

## Features

- Runs Flutter clean and pub get
- Formats code
- Runs static analysis
- Runs unit/widget tests
- Checks outdated dependencies
- Builds Android debug APK
- Scans project hygiene issues such as `print()`, `TODO`, `FIXME`, and `Get.put()` usage
- Generates a Markdown SQA handoff report

## Install in a Flutter or Dart project

From pub.dev, add this package as a dev dependency:

```yaml
dev_dependencies:
  flutter_pre_sqa: ^0.1.0
```

Then run:

```bash
flutter pub get
dart run flutter_pre_sqa
```

Alternatively, while developing locally, add it as a path dependency:

```yaml
dev_dependencies:
  flutter_pre_sqa:
    path: ../flutter_pre_sqa
```

Then run:

```bash
flutter pub get
dart run flutter_pre_sqa
```

## Useful commands

Skip build:

```bash
dart run flutter_pre_sqa --skip-build
```

Skip tests:

```bash
dart run flutter_pre_sqa --skip-tests
```

Custom report path:

```bash
dart run flutter_pre_sqa --report qa/pre_sqa_report.md
```

Fail fast on required command failure:

```bash
dart run flutter_pre_sqa --fail-fast
```

## Recommended before SQA

Run:

```bash
dart run flutter_pre_sqa
```

Then manually verify:

- UI against Figma
- Login/signup/forgot password
- Form validations
- API error states
- Offline behavior
- CRUD flows
- Permissions
- Payments/subscriptions
- Role-based access
- Regression testing

## Important

This package helps catch technical problems before SQA, but it cannot fully verify business logic unless requirements are documented and manually checked.
