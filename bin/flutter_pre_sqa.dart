import 'package:flutter_pre_sqa/flutter_pre_sqa.dart';

Future<void> main(List<String> arguments) async {
  final runner = PreSqaRunner.fromArgs(arguments);
  final exitCode = await runner.run();
  if (exitCode != 0) {
    throw Exception('Pre-SQA checks failed with exit code $exitCode');
  }
}
