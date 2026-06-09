import '../config/pre_sqa_config.dart';
import 'check_result.dart';

/// A structured data model representing a generated validation report.
class ReportData {
  /// Creates a report data object from validation results.
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

  /// The configured project name.
  final String projectName;

  /// The detected Flutter SDK version.
  final String flutterVersion;

  /// The detected Dart SDK version.
  final String dartVersion;

  /// The number of warnings found during execution.
  final int totalWarnings;

  /// The number of failed checks found during execution.
  final int totalErrors;

  /// The number of passed checks.
  final int passedChecks;

  /// The number of failed checks.
  final int failedChecks;

  /// A list of dependency audit notes and warnings.
  final List<String> dependencyIssues;

  /// The number of detected TODO comments.
  final int todoCount;

  /// The number of detected FIXME comments.
  final int fixmeCount;

  /// The number of detected HACK comments.
  final int hackCount;

  /// The number of `print()` usages detected.
  final int printCount;

  /// The number of `debugPrint()` usages detected.
  final int debugPrintCount;

  /// The number of large files detected by the scan.
  final int largeFileCount;

  /// The number of empty catch blocks detected.
  final int emptyCatchCount;

  /// The evaluated build status.
  final String buildStatus;

  /// The evaluated test status.
  final String testStatus;

  /// A summary of coverage results.
  final String coverageSummary;

  /// The computed architecture score.
  final int architectureScore;

  /// The computed security score.
  final int securityScore;

  /// The computed performance score.
  final int performanceScore;

  /// A human-readable AI review summary.
  final String aiReviewSummary;

  /// The raw list of check results.
  final List<CheckResult> results;

  /// The effective package configuration used for the report.
  final PreSqaConfig config;
}
