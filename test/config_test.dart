import 'package:flutter_pre_sqa/src/config/pre_sqa_config.dart';
import 'package:test/test.dart';

void main() {
  test('loads default config when file is missing', () async {
    final config = PreSqaConfig.empty();
    expect(config.project.name, 'Flutter Project');
    expect(config.checks.analyze, isTrue);
    expect(config.report.output, equals('pre_sqa_report.md'));
  });

  test('parses sample YAML into config values', () {
    final yaml = PreSqaConfig.sampleYaml;
    final config = PreSqaConfig.fromYaml(yaml);
    expect(config.project.name, 'My App');
    expect(config.checks.buildAndroid, isTrue);
    expect(config.checks.buildIos, isFalse);
    expect(config.report.format, equals(ReportFormat.markdown));
    expect(config.exclude, contains('.dart_tool/**'));
  });
}
