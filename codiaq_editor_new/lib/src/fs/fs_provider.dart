abstract class FSProvider {
  Future<String> readAsString(String path);
  Future<List<int>> readAsBytes(String path);
  String readAsStringSync(String path);
  List<int> readAsBytesSync(String path);
  Future<void> writeAsString(String path, String contents);
  Future<void> writeAsBytes(String path, List<int> bytes);
  Future<void> appendAsString(String path, String contents);
  Future<void> appendAsBytes(String path, List<int> bytes);
  Future<bool> exists(String path);
  bool existsSync(String path);
  Future<void> delete(String path, {bool recursive = false});
  Future<void> createFile(String path, {bool recursive = false});
  Future<void> createDirectory(String path, {bool recursive = false});
  Future<List<FsEntity>> list(String path, {bool recursive = false});
  Future<FsEntity> getEntity(String path);
  Stream<FsEvent> watch(String path, {bool recursive = false});

  const FSProvider();
}

class FsEntity {
  final String path;

  FsEntity(this.path);
}

class FsDirectory extends FsEntity {
  FsDirectory(super.path);
}

class FsFile extends FsEntity {
  FsFile(super.path);
}

enum FsEventType { created, modified, deleted }

class FsEvent {
  final FsEventType type;
  final String path;

  FsEvent(this.type, this.path);
}
