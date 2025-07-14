import 'dart:async';
import 'dart:io';

import 'package:watcher/watcher.dart';

import 'fs_provider.dart';

class LocalFSProvider extends FSProvider {
  const LocalFSProvider() : super();
  @override
  Future<String> readAsString(String path) {
    return File(path).readAsString();
  }

  @override
  Future<List<int>> readAsBytes(String path) {
    return File(path).readAsBytes();
  }

  @override
  String readAsStringSync(String path) {
    return File(path).readAsStringSync();
  }

  @override
  List<int> readAsBytesSync(String path) {
    return File(path).readAsBytesSync();
  }

  @override
  Future<void> writeAsString(String path, String contents) {
    return File(path).writeAsString(contents);
  }

  @override
  Future<void> writeAsBytes(String path, List<int> bytes) {
    return File(path).writeAsBytes(bytes);
  }

  @override
  Future<void> appendAsString(String path, String contents) async {
    final file = File(path);
    await file.writeAsString(contents, mode: FileMode.append);
  }

  @override
  Future<void> appendAsBytes(String path, List<int> bytes) async {
    final file = File(path);
    await file.writeAsBytes(bytes, mode: FileMode.append);
  }

  @override
  Future<bool> exists(String path) async {
    final entity = FileSystemEntity.typeSync(path);
    return entity != FileSystemEntityType.notFound;
  }

  @override
  bool existsSync(String path) {
    final entity = FileSystemEntity.typeSync(path);
    return entity != FileSystemEntityType.notFound;
  }

  @override
  Future<void> delete(String path, {bool recursive = false}) async {
    final entityType = FileSystemEntity.typeSync(path);
    if (entityType == FileSystemEntityType.directory) {
      await Directory(path).delete(recursive: recursive);
    } else if (entityType == FileSystemEntityType.file) {
      await File(path).delete();
    }
  }

  @override
  Future<void> createFile(String path, {bool recursive = false}) async {
    final file = File(path);
    if (recursive) {
      await file.parent.create(recursive: true);
    }
    await file.create();
  }

  @override
  Future<void> createDirectory(String path, {bool recursive = false}) {
    return Directory(path).create(recursive: recursive);
  }

  @override
  Future<List<FsEntity>> list(String path, {bool recursive = false}) async {
    final dir = Directory(path);
    if (!await dir.exists()) return [];

    final entities = <FsEntity>[];
    await for (var entity in dir.list(
      recursive: recursive,
      followLinks: false,
    )) {
      final type = await FileSystemEntity.type(entity.path);
      if (type == FileSystemEntityType.directory) {
        entities.add(FsDirectory(entity.path));
      } else if (type == FileSystemEntityType.file) {
        entities.add(FsFile(entity.path));
      }
    }

    return entities;
  }

  @override
  Future<FsEntity> getEntity(String path) async {
    final type = await FileSystemEntity.type(path);
    switch (type) {
      case FileSystemEntityType.directory:
        return FsDirectory(path);
      case FileSystemEntityType.file:
        return FsFile(path);
      default:
        throw FileSystemException('No such file or directory', path);
    }
  }

  @override
  Stream<FsEvent> watch(String path, {bool recursive = false}) {
    final controller = StreamController<FsEvent>(
      onCancel: () {
        // Cleanup will be handled by individual watchers
      },
    );

    // Check if the path exists and is a directory
    if (!Directory(path).existsSync()) {
      controller.addError(
        FileSystemException('Directory does not exist', path),
      );
      controller.close();
      return controller.stream;
    }

    // Watch the given directory
    final watcher = DirectoryWatcher(path);
    watcher.events.listen(
      (event) {
        controller.add(
          FsEvent(_mapChangeTypeToFsEventType(event.type), event.path),
        );
      },
      onError: (error) => controller.addError(error),
      onDone: () => controller.close(),
    );

    // Handle recursive watching
    if (recursive) {
      Directory(path).list(recursive: true, followLinks: false).listen((
        entity,
      ) async {
        if (await FileSystemEntity.isDirectory(entity.path)) {
          final subWatcher = DirectoryWatcher(entity.path);
          subWatcher.events.listen((event) {
            controller.add(
              FsEvent(_mapChangeTypeToFsEventType(event.type), event.path),
            );
          }, onError: (error) => controller.addError(error));
        }
      }, onError: (error) => controller.addError(error));
    }

    return controller.stream;
  }

  FsEventType _mapChangeTypeToFsEventType(ChangeType type) {
    switch (type) {
      case ChangeType.ADD:
        return FsEventType.created;
      case ChangeType.MODIFY:
        return FsEventType.modified;
      case ChangeType.REMOVE:
        return FsEventType.deleted;
      default: // Handle any other cases if necessary
        return FsEventType.modified;
    }
  }
}
