import 'dart:io';

import 'package:file_picker/file_picker.dart';

import 'package:flutter_archive/flutter_archive.dart';
import 'package:new_bluebyte/utils/config.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:sqflite/sqflite.dart';

class SpecialFunctions {
  static Future<bool> saveWork() async {
    String databasePath = join(await getDatabasesPath(), Config.dbName);
    Directory appDir = await getExternalStorageDirectory();

    Directory savesDir = Directory('storage/emulated/0/BlueByte/Saves');

    Directory currentSaveDir = Directory(join(savesDir.path, 'currentSave'));

    if (!(await Permission.storage.status == PermissionStatus.granted)) {
      await Permission.storage.request();
    }

    if (!(await currentSaveDir.exists()))
      await currentSaveDir.create(recursive: true);

    File dbFile = File(databasePath);

    File saveFileZip = File(join(savesDir.path,
        "bluebyte_${DateTime.now().toString().split('.')[0]}.zip"));

    //we copy our app directory to the save directory
    await copyDirectory(appDir, currentSaveDir);

    //we copy the database file to our save directory
    await dbFile.copy(join(currentSaveDir.path, Config.dbName));

    //we then zip the file

    await ZipFile.createFromDirectory(
        sourceDir: currentSaveDir, zipFile: saveFileZip);
    await currentSaveDir.delete(recursive: true);
    return true;
  }

  static Future<bool> loadWork(
      onWorkLoading, onLoadingCompleted, onError(String message)) async {
    onWorkLoading();
    FilePickerResult result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['zip'],
    );

    if (result == null) {
      onError("No file Selected");
      return false;
    }

    PlatformFile pickedFile = result.files.first;

    //we check if the file has the wanted pattern in its name

    if (pickedFile.name.contains(RegExp(
        r'bluebyte_\d{4}-[01]\d-[0-3]\d [0-2]\d:[0-5]\d:[0-5]\d(?:\.\d+)?Z?.zip'))) {
      File zipFile = File(pickedFile.path);
      Directory appDir = await getExternalStorageDirectory();

      //we create an temporary directory to which we will extract the zipfile's
      //content before we merge it with the main app directory

      Directory tempDir = Directory(join(appDir.path, 'tempData'));
      if (!await tempDir.exists()) tempDir.create();

      //extract to temp dir
      await ZipFile.extractToDirectory(
          zipFile: zipFile, destinationDir: tempDir);

      //get database file and copy it to db directory then delete it
      File dbFile = File(join(tempDir.path, '${Config.dbName}'));
      if (await dbFile.exists()) {
        await dbFile.copy(join(await getDatabasesPath(), '${Config.dbName}'));
        await dbFile.delete();

        //we send our temp directory to the main directory
        await copyDirectory(tempDir, appDir);
        await tempDir.delete(recursive: true);
        onLoadingCompleted();
        return true;
      } else {
        onError("Database file not found");

        return false;
      }
    } else {
      onError("Invalid File selected");

      return false;
    }
  }

  static Future<void> copyDirectory(
      Directory source, Directory destination) async {
    await for (var entity in source.list(recursive: false)) {
      if (entity is Directory) {
        var newDirectory =
            Directory(join(destination.absolute.path, basename(entity.path)));
        await newDirectory.create();
        await copyDirectory(entity.absolute, newDirectory);
      } else if (entity is File) {
        await entity.copy(join(destination.path, basename(entity.path)));
      }
    }
  }
}
