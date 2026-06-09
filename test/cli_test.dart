import 'dart:io';

import 'package:flutter_pre_sqa/flutter_pre_sqa.dart';
import 'package:test/test.dart';

void main() {
  test('version command prints package version', () async {
    final cli = FlutterPreSqaCli();
    final exitCode = await cli.run(['version']);
    expect(exitCode, 0);
  });

  test('init command creates a config file', () async {
    final file = File('test_pre_sqa.yaml');
    if (file.existsSync()) {
      file.deleteSync();
    }

    final cli = FlutterPreSqaCli();
    final exitCode = await cli.run(['init', 'test_pre_sqa.yaml']);
    expect(exitCode, 0);
    expect(file.existsSync(), isTrue);
    file.deleteSync();
  });
}
