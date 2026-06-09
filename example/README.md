# flutter_pre_sqa Example

This example shows how to execute `flutter_pre_sqa` programmatically.

```dart
import 'package:flutter_pre_sqa/flutter_pre_sqa.dart';

Future<void> main() async {
  final cli = FlutterPreSqaCli();
  await cli.run([]);
}
```

For command-line usage, run:

```bash
dart run flutter_pre_sqa
```
