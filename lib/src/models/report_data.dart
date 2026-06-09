import '../config/pre_sqa_config.dart';
import 'check_result.dart';

class ReportData {
  ReportData({
    required this.projectName,
    required this.flutterVersion,
    required this.dartVersion,
    required this.totalWarnings,
    required this.totalErrors,
    required this.passedChecks,
    required this.failedChecks,
    required this.dependencyIssues,
    required this.todoCount,
    required this.fixmeCount,
    required this.hackCount,
    required this.printCount,
    required this.debugPrintCount,
    required this.largeFileCount,
    required this.emptyCatchCount,
    required this.buildStatus,
    required this.testStatus,
    required this.coverageSummary,
    required this.architectureScore,
    required this.securityScore,
    required this.performanceScore,
    required this.aiReviewSummary,
    required this.results,
    required this.config,
  });

  final String projectName;
  final String flutterVersion;
  final String dartVersion;
  final int totalWarnings;
  final int totalErrors;
  final int passedChecks;
  final int failedChecks;
  final List<String> dependencyIssues;
  final int todoCount;
  final int fixmeCount;
  final int hackCount;
  final int printCount;
  final int debugPrintCount;
  final int largeFileCount;
  final int emptyCatchCount;
  final String buildStatus;
  final String testStatus;
  final String coverageSummary;
  final int architectureScore;
  final int securityScore;
  final int performanceScore;
  final String aiReviewSummary;
  final List<CheckResult> results;
  final PreSqaConfig config;
}
