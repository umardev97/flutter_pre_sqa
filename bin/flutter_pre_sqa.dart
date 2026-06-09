import 'dart:io';

import 'package:flutter_pre_sqa/flutter_pre_sqa.dart';

/// The executable entrypoint for the `flutter_pre_sqa` CLI.
///
/// This entrypoint delegates execution to [FlutterPreSqaCli].
Future<void> main(List<String> arguments) async {
  final cli = FlutterPreSqaCli();
  final exitCode = await cli.run(arguments);
  if (exitCode != 0) {
    exit(exitCode);
  }
}
