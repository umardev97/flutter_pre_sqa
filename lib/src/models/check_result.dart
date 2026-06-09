class CheckResult {
  CheckResult({
    required this.title,
    required this.command,
    required this.exitCode,
    required this.required,
    required this.notes,
  });

  final String title;
  final String command;
  final int exitCode;
  final bool required;
  final String notes;

  bool get failed => exitCode != 0;
}
