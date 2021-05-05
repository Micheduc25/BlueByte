import 'dart:io';

import 'package:new_bluebyte/database/DBConnect.dart';
import 'package:new_bluebyte/models/audioModel.dart';

import 'package:new_bluebyte/models/measurementModel.dart';
import 'package:new_bluebyte/models/moduleModel.dart';
import 'package:new_bluebyte/models/newImageModel.dart';
import 'package:new_bluebyte/models/objectModel.dart';
import 'package:new_bluebyte/models/pointsModel.dart';
import 'package:new_bluebyte/utils/config.dart';

import 'package:sqflite/sqflite.dart';

class DbOperations {
  //This class contains various static methods for inserting
  // and retrieving data from the database

  static String replaceSpecialChars(String string, bool fromDB) {
    if (!fromDB) {
      if (string.contains("\"")) string = string.replaceAll("\"", "");
      if (string.contains("\'")) string = string.replaceAll("\'", "\'\'");
    } else {
      if (string.contains("\"")) string = string.replaceAll("\"", "\'");
    }
    return string;
  }

  static Future<void> addModule(Module module) async {
    final db = await DBConnect().initDB();

    try {
      await db.insert("modules", module.toMap(),
          conflictAlgorithm: ConflictAlgorithm.replace);
      print("module created");
    } catch (e) {
      print("module not created");
      print("error during data insertion" + e.toString());
    }
  }

  static Future<void> editModule(
      int moduleId, Map<String, dynamic> newData) async {
    final db = await DBConnect().initDB();

    try {
      db.update(Config.modules, newData,
          where: "moduleId=$moduleId",
          conflictAlgorithm: ConflictAlgorithm.replace);
    } catch (e) {
      print("could not update data $e");
    }
  }

  static Future<void> deleteModule(int moduleId) async {
    final db = await DBConnect().initDB();

    try {
      db.delete(Config.modules, where: "moduleId=$moduleId");
    } catch (e) {
      print("could not delete data $e");
    }
  }

//this function returns the id of the new object
  static Future<int> addObject(Object object) async {
    final db = await DBConnect().initDB();

    try {
      await db.insert("objects", object.toMap(),
          conflictAlgorithm: ConflictAlgorithm.replace);
    } catch (e) {
      print("error during data insertion" + e.toString());
    }

    final lastRow = await getLastRow("objects", Config.objectId);
    print('the last inserted object has id -- ${lastRow[Config.objectId]}');

    return lastRow[Config.objectId];
  }

  static Future<void> editObject(
      int objectId, Map<String, dynamic> newData) async {
    final db = await DBConnect().initDB();

    try {
      db.update(Config.objects, newData, where: "objectId=$objectId");
    } catch (e) {
      print("could not update data $e");
    }
  }

  static Future<Map<String, dynamic>> getLastRow(
      String table, String idColumn) async {
    final db = await DBConnect().initDB();

    final data = await db
        // .rawQuery("SELECT * FROM $table ORDER BY $idColumn DESC LIMIT 1;");
        .rawQuery(
            "SELECT * FROM    $table WHERE   $idColumn = (SELECT MAX($idColumn)  FROM $table);");
    print("last points loaded");

    return data[0];
  }

  static Future<void> deleteLastRow(String table, String idColumn) async {
    final db = await DBConnect().initDB();
    await db
        // .rawQuery("SELECT * FROM $table ORDER BY $idColumn DESC LIMIT 1;");
        .rawQuery(
            " DELETE  FROM    $table WHERE   $idColumn = (SELECT MAX($idColumn)  FROM $table);");
    print("last points deleted");
  }

  static Future<void> deleteObject(int objectId) async {
    final db = await DBConnect().initDB();

    try {
      db.delete(Config.objects, where: "objectId=$objectId");
    } catch (e) {
      print("could not delete data $e");
    }
  }

  static Future<int> addImage(ObjectImage image) async {
    final db = await DBConnect().initDB();

    try {
      await db
          .insert("images", image.toMap(),
              conflictAlgorithm: ConflictAlgorithm.replace)
          .then((val) {
        print("image inserted $val in db");
      });
    } catch (e) {
      print("error during data insertion" + e.toString());
    }

    final lastRow = await getLastRow(Config.images, Config.imageId);
    print("id of this image is  .. ${lastRow[Config.imageId]}  dpOps line 131");
    return lastRow[Config.imageId];
  }

  static Future<void> editImage(
      int imageId, Map<String, dynamic> newData) async {
    final db = await DBConnect().initDB();

    try {
      db.update(Config.images, newData, where: "imageId=$imageId");
    } catch (e) {
      print("could not update data $e");
    }
  }

  static Future<void> deleteimage(int imageId) async {
    final db = await DBConnect().initDB();

    try {
      db.delete(Config.images, where: "imageId=$imageId");
    } catch (e) {
      print("could not delete data $e");
    }
  }

  static Future<void> addMeasurement(Measurement measurement) async {
    final db = await DBConnect().initDB();

    try {
      await db.insert("measurements", measurement.toMap(),
          conflictAlgorithm: ConflictAlgorithm.replace);
    } catch (e) {
      print("error during data insertion" + e.toString());
    }
  }

  static Future<void> addLengthPoints(LengthPoints lengthPoints) async {
    final db = await DBConnect().initDB();

    try {
      await db.insert("lengthpoints", lengthPoints.toMap(),
          conflictAlgorithm: ConflictAlgorithm.replace);
    } catch (e) {
      print("error during data insertion" + e.toString());
    }
  }

  static Future<void> addAnglePoints(AnglePoints anglePoints) async {
    final db = await DBConnect().initDB();

    try {
      await db.insert("anglepoints", anglePoints.toMap(),
          conflictAlgorithm: ConflictAlgorithm.replace);
    } catch (e) {
      print("error during data insertion" + e.toString());
    }
  }

  static Future<void> editPoints(
      String pointType, int pointsId, Map<String, dynamic> newData) async {
    final db = await DBConnect().initDB();

    try {
      db.update(
          pointType == Config.lengthpoints
              ? Config.lengthpoints
              : Config.anglepoints,
          newData,
          where: "pointsId=$pointsId");
    } catch (e) {
      print("could not update data $e");
    }
  }

  static Future<void> deletepoints(String pointType, int pointsId) async {
    final db = await DBConnect().initDB();

    try {
      db.delete(
          pointType == Config.lengthpoints
              ? Config.lengthpoints
              : Config.anglepoints,
          where: "pointsId=$pointsId");
    } catch (e) {
      print("could not delete data $e");
    }
  }

  static Future<void> addAudio(Audio audio) async {
    final db = await DBConnect().initDB();

    try {
      await db.insert("audios", audio.toMap(),
          conflictAlgorithm: ConflictAlgorithm.replace);
    } catch (e) {
      print("error during data insertion" + e.toString());
    }
  }

  static Future<void> editAudio(
      int audioId, Map<String, dynamic> newData) async {
    final db = await DBConnect().initDB();

    try {
      db.update(Config.audios, newData, where: "audioId=$audioId");
    } catch (e) {
      print("could not update data $e");
    }
  }

  static Future<void> deleteAudio(int audioId, String path) async {
    final db = await DBConnect().initDB();

    try {
      db.delete(Config.audios, where: "audioId=$audioId");
    } catch (e) {
      print("could not delete data $e");
    }

    Directory audioDir = new Directory(path);
    try {
      await audioDir.delete(recursive: true);
    } catch (e) {
      print("Could not delete file from local storage: $e");
    }
  }

  static Future<void> deleteModuleAudios(int moduleId) async {
    final db = await DBConnect().initDB();
    final audios = await getModuleAudios(moduleId);

    try {
      db.delete(Config.audios, where: "moduleId=$moduleId");
    } catch (e) {
      print("could not delete audios from database $e");
    }

    audios.forEach((audio) async {
      Directory audioDir = new Directory(audio.path);
      try {
        await audioDir.delete(recursive: true);
      } catch (e) {
        print("Could not delete file from local storage: $e");
      }
    });
  }

  static Future<void> deleteModuleObjects(int moduleId) async {
    final db = await DBConnect().initDB();

    try {
      db.delete(Config.objects, where: "moduleId=$moduleId");
    } catch (e) {
      print("could not delete objects for this module from database $e");
    }
  }

  static Future<void> deleteObjectImages(int objectId) async {
    final db = await DBConnect().initDB();

    try {
      db.delete(Config.images, where: "objectId=$objectId");
    } catch (e) {
      print("could not delete images from database $e");
    }
  }

  static Future<void> deleteImagePoints(int imageId, String pointType) async {
    final db = await DBConnect().initDB();

    try {
      db.delete(
          pointType == Config.lengthpoints
              ? Config.lengthpoints
              : Config.anglepoints,
          where: "imageId=$imageId");
    } catch (e) {
      print("could not delete audios from database $e");
    }
  }

  static Future<List<Object>> getObjects(int moduleId) async {
    final db = await DBConnect().initDB();

    List<Map<String, dynamic>> objects = [];
    List<Object> finalObjects = [];

    // objects = await db.query(Config.objects,
    //     where: "moduleId=$moduleId", distinct: true);

    try {
      objects = await db
          .rawQuery("SELECT DISTINCT * FROM objects WHERE moduleId=$moduleId");

      objects.forEach((map) {
        finalObjects.add(Object.fromMap(map));
      });
    } catch (e) {
      print("error retrieving data ${e.toString()}");
    }
    return finalObjects;
  }

  static Future<List<Map<String, dynamic>>> getAllModules() async {
    final db = await DBConnect().initDB();
    List<Map<String, dynamic>> modules;

    modules = await db.query(Config.modules, distinct: true);
    return modules;
  }

  static Future<int> getModuleId(String moduleName) async {
    final db = await DBConnect().initDB();
    int moduleId;
    // final query = await db.query(Config.modules,
    //     columns: [Config.moduleId], where: '${Config.name}=$moduleName');

    // final query = await db.rawQuery(
    //     "SELECT moduleId FROM modules WHERE modules.name=$moduleName");

    final query = await db.query("modules",
        columns: ["moduleId"],
        where: "modules.name=?",
        whereArgs: [moduleName]);

    moduleId = query[0][Config.moduleId];
    return moduleId;
  }

  static Future<Module> getModule(int moduleId) async {
    Module module;
    final db = await DBConnect().initDB();

    final query =
        await db.query(Config.modules, where: "modules.moduleId=$moduleId");

    module = Module.fromMap(query[0]);
    return module;
  }

  static Future<List<Audio>> getAllAudios() async {
    final db = await DBConnect().initDB();
    List<Audio> audios = [];

    final query = await db.query(Config.audios);

    query.forEach((map) {
      audios.add(Audio.fromMap(map));
    });

    return audios;
  }

  static Future<List<Audio>> getModuleAudios(int moduleId) async {
    final db = await DBConnect().initDB();
    List<Audio> audios = [];
    final query = await db.query(Config.audios, where: "moduleId=$moduleId");
    query.forEach((map) {
      audios.add(Audio.fromMap(map));
    });

    return audios;
  }

  static Future<List<ObjectImage>> getObjectImages(int objectId) async {
    if (objectId != null) {
      final db = await DBConnect().initDB();
      List<ObjectImage> images = [];

      try {
        print("objectId: $objectId");
        final query =
            await db.rawQuery("SELECT * FROM images WHERE objectId=$objectId");

        query.forEach((map) {
          images.add(new ObjectImage.fromMap(map));
          return images;
        });
      } catch (e) {
        print("could not get images from database $e");
      }
      return images;
    } else {
      print("objectId is null");
      return [];
    }
  }

  static Future<List<Measurement>> getMeasurements(int imageId) async {
    final db = await DBConnect().initDB();
    List<Measurement> measurements = [];

    try {
      final query =
          await db.query(Config.measurements, where: "imageId=$imageId");

      query.forEach((map) {
        measurements.add(new Measurement.fromMap(map));
      });
    } catch (e) {
      print("could not get measurement $e");
    }

    return measurements;
  }

  static Future<List<LengthPoints>> getLengthPoints(int imageId) async {
    final db = await DBConnect().initDB();
    List<LengthPoints> points = [];

    try {
      final query =
          await db.query(Config.lengthpoints, where: "imageId=$imageId");

      query.forEach((map) {
        points.add(new LengthPoints.fromMap(map));
      });
    } catch (e) {
      print("could not get measurement $e");
    }

    return points;
  }

  static Future<List<AnglePoints>> getAnglePoints(int imageId) async {
    final db = await DBConnect().initDB();
    List<AnglePoints> points = [];

    try {
      final query =
          await db.query(Config.anglepoints, where: "imageId=$imageId");

      query.forEach((map) {
        points.add(new AnglePoints.fromMap(map));
      });
    } catch (e) {
      print("could not get measurement $e");
    }

    return points;
  }

  static Future<void> deleteImage(int id, String path) async {
    final db = await DBConnect().initDB();

    try {
      db.delete(Config.images, where: "imageId=$id");
    } catch (e) {
      print("error trying to delete image: $e");
      return;
    }

    Directory imageDir = new Directory(path);
    try {
      await imageDir.delete(recursive: true);
    } catch (e) {
      print("Could not delete file from local storage: $e");
    }
  }
}
