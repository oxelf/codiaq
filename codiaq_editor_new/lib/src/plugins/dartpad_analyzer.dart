//import 'dart:convert';
//
//import 'dart:io';
//
//import 'package:analyzer/dart/analysis/analysis_context_collection.dart';
//import 'package:analyzer/dart/analysis/features.dart';
//import 'package:analyzer/dart/analysis/results.dart';
//import 'package:analyzer/dart/analysis/session.dart';
//import 'package:analyzer/diagnostic/diagnostic.dart' hide Diagnostic;
//import 'package:analyzer/file_system/physical_file_system.dart';
//import 'package:codiaq_editor/codiaq_editor.dart';
//import 'package:codiaq_editor/src/plugin/window_plugin.dart';
//
//// Import analyzer utilities, but HIDE its `Diagnostic` class to avoid conflict
//// with the `Diagnostic` class from this project.
//import 'package:analyzer/dart/analysis/utilities.dart';
//import 'package:analyzer/error/error.dart';
//
//class DartAnalyzerPlugin extends WindowPluginBase {
//  static const String dartPadApiUrl =
//      "https://stable.api.dartpad.dev/api/v3/analyze";
//  DartAnalyzerPlugin();
//
//  // This `Diagnostic` class now unambiguously comes from `codiaq_editor`.
//  List<Diagnostic> diagnostics = [];
//
//  @override
//  Future<void> onTyping() async {
//    for (var diagnostic in diagnostics) {
//      api.unregisterDiagnostic(diagnostic);
//    }
//    diagnostics.clear();
//
//    if (Platform.isIOS || Platform.isAndroid) {
//      print("Running on mobile, using DartPad API for analysis.");
//      await _analyzeWithDartPad();
//    } else {
//      print("Running on desktop/web, using local analyzer.");
//      //await _analyzeWithFullContext(api.filePath);
//      await _analyzeWithAnalyzerPackage();
//    }
//
//    api.dispatchEvent("diagnostics");
//    print("Diagnostics updated.");
//  }
//
//  Future<void> _analyzeWithFullContext(String filePath) async {
//    final resourceProvider = PhysicalResourceProvider.INSTANCE;
//
//    final projectRoot = Directory(filePath).parent.path;
//
//    final collection = AnalysisContextCollection(
//      includedPaths: [filePath], // Path to the file to analyze
//      resourceProvider: resourceProvider,
//    );
//    final analysisContext = collection.contextFor(filePath);
//
//    final ResolvedUnitResult result =
//        await (analysisContext.currentSession.getResolvedUnit(filePath)
//            as Future<ResolvedUnitResult>);
//
//    diagnostics.clear();
//
//    for (final error in result.errors) {
//      var lineInfo = result.lineInfo;
//      var startLocation = lineInfo.getLocation(error.offset);
//      var endLocation = lineInfo.getLocation(error.offset + error.length);
//
//      var diag = Diagnostic(
//        line: startLocation.lineNumber - 1,
//        startCol: startLocation.columnNumber - 1,
//        endCol: endLocation.columnNumber - 1,
//        message: error.message,
//        severity: _getSeverityFromAnalyzer(error.severity),
//        documentationUrl: error.errorCode.url ?? '',
//      );
//      diagnostics.add(diag);
//      api.registerDiagnostic(diag);
//    }
//
//    api.dispatchEvent("diagnostics");
//  }
//
//  /// Analyzes the code using the local 'analyzer' package.
//  Future<void> _analyzeWithAnalyzerPackage() async {
//    String code = api.lines.join("\n");
//
//    var result = parseString(
//      content: code,
//      throwIfDiagnostics: false,
//      featureSet: FeatureSet.latestLanguageVersion(),
//    );
//
//    print("result.erros: ${result.errors}");
//    for (AnalysisError error in result.errors) {
//      var lineInfo = result.lineInfo;
//      var startLocation = lineInfo.getLocation(error.offset);
//      var endLocation = lineInfo.getLocation(error.offset + error.length);
//
//      var diag = Diagnostic(
//        line: startLocation.lineNumber - 1,
//        startCol: startLocation.columnNumber - 1,
//        endCol: endLocation.columnNumber - 1,
//        message: error.message,
//        severity: _getSeverityFromAnalyzer(error.severity),
//        documentationUrl: error.errorCode.url ?? '',
//      );
//      diagnostics.add(diag);
//      api.registerDiagnostic(diag);
//    }
//  }
//
//  /// Analyzes the code using the DartPad web API.
//  Future<void> _analyzeWithDartPad() async {
//    HttpClient client = HttpClient();
//    String code = api.lines.join("\n");
//    try {
//      var request = await client.postUrl(Uri.parse(dartPadApiUrl));
//      request.headers.set("Content-Type", "application/json");
//      request.write(jsonEncode({"source": code}));
//      var response = await request.close();
//      if (response.statusCode == 200) {
//        String responseBody = await response.transform(utf8.decoder).join();
//        var jsonResponse = jsonDecode(responseBody);
//        var issues = jsonResponse["issues"] as List<dynamic>;
//
//        for (var issue in issues) {
//          var severity = _getSeverityFromString(issue["kind"]);
//          var message = issue["message"];
//          var line = issue["location"]["line"] - 1;
//          var startCol = issue["location"]["column"] - 1;
//          var endCol =
//              startCol + (issue["location"]["charLength"] as int? ?? 0);
//
//          var diag = Diagnostic(
//            line: line,
//            startCol: startCol,
//            endCol: endCol,
//            message: message,
//            severity: severity,
//            documentationUrl: issue["url"] ?? '',
//          );
//          diagnostics.add(diag);
//          api.registerDiagnostic(diag);
//        }
//      } else {
//        print("Error analyzing with DartPad API: ${response.statusCode}");
//      }
//    } catch (e) {
//      print("Exception when calling DartPad API: $e");
//    } finally {
//      client.close();
//    }
//  }
//
//  DiagnosticSeverity _getSeverityFromAnalyzer(Severity severity) {
//    print("Analyzing severity: $severity");
//    switch (severity) {
//      case Severity.error:
//        return DiagnosticSeverity.error;
//      case Severity.warning:
//        return DiagnosticSeverity.warning;
//      case Severity.info:
//        return DiagnosticSeverity.information;
//    }
//  }
//
//  DiagnosticSeverity _getSeverityFromString(String severity) {
//    switch (severity) {
//      case "error":
//        return DiagnosticSeverity.error;
//      case "warning":
//        return DiagnosticSeverity.warning;
//      case "info":
//        return DiagnosticSeverity.information;
//      default:
//        return DiagnosticSeverity.hint;
//    }
//  }
//
//  @override
//  void cleanup() {}
//}
