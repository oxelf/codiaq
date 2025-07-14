class GeneralCommandLine {
  String executable;
  List<String> arguments;
  String? workingDirectory;
  Map<String, String>? environment;

  GeneralCommandLine(
    this.executable, {
    this.arguments = const [],
    this.workingDirectory,
    this.environment,
  });

  /// Convert to `ProcessStart`-ready arguments
  List<String> get fullCommand => [executable, ...arguments];
}
