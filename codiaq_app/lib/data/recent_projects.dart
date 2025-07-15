import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class RecentProject {
  String name;
  String rootPath;

  RecentProject({required this.name, required this.rootPath});

  RecentProject.fromJson(Map<String, dynamic> json)
    : name = json['name'] as String,
      rootPath = json['rootPath'] as String;
  Map<String, dynamic> toJson() {
    return {'name': name, 'rootPath': rootPath};
  }
}

Future<List<RecentProject>> getRecentProjects() async {
  var _prefs = await SharedPreferences.getInstance();
  var jsonList = _prefs.getStringList("recent_projects") ?? [];
  if (jsonList.isEmpty) {
    return [];
  }
  return jsonList
      .map((json) => RecentProject.fromJson(jsonDecode(json)))
      .toList();
}

Future<void> addToRecentProjects(RecentProject project) async {
  var _prefs = await SharedPreferences.getInstance();
  var recentProjects = await getRecentProjects();
  recentProjects.removeWhere((p) => p.rootPath == project.rootPath);

  recentProjects.insert(0, project);

  var jsonList = recentProjects.map((p) => jsonEncode(p.toJson())).toList();
  _prefs.setStringList("recent_projects", jsonList);
}

//Future<List<RecentProject>> loadRecentProjects() async {
//  final jsonString = cq.storage.getString('recent_projects') ?? '[]';
//  final List<dynamic> jsonList = jsonDecode(jsonString);
//  return jsonList.map((json) => RecentProject.fromJson(json)).toList();
//}
