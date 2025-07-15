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

//Future<List<RecentProject>> loadRecentProjects() async {
//  final jsonString = cq.storage.getString('recent_projects') ?? '[]';
//  final List<dynamic> jsonList = jsonDecode(jsonString);
//  return jsonList.map((json) => RecentProject.fromJson(json)).toList();
//}
