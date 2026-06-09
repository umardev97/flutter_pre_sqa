import 'dart:io';

import 'package:flutter_pre_sqa/flutter_pre_sqa.dart';

Future<void> main(List<String> arguments) async {
  final cli = FlutterPreSqaCli();
  final exitCode = await cli.run(arguments);
  if (exitCode != 0) {
    exit(exitCode);
  }
}
