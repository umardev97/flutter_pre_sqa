/// Represents the result of a single validation check.
class CheckResult {
  /// Creates a new check result.
  CheckResult({
    required this.title,
    required this.command,
    required this.exitCode,
    required this.required,
    required this.notes,
  });

  /// The human-readable title of the check.
  final String title;

  /// The command that was executed for the check.
  final String command;

  /// The exit code returned by the command.
  final int exitCode;

  /// Whether the check is required for successful publication.
  final bool required;

  /// Notes or diagnostic output from the check.
  final String notes;

  /// Returns true when the check result indicates failure.
  bool get failed => exitCode != 0;
}
