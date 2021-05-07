import 'package:new_bluebyte/utils/config.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DBConnect {
  Future<Database> initDB() async {
// Open the database and store the reference.
    final Database database = await openDatabase(
        // Set the path to the database. Note: Using the `join` function from the
        // `path` package is best practice to ensure the path is correctly
        // constructed for each platform.
        join(await getDatabasesPath(), Config.dbName),
        onCreate: (db, version) async {
      await db.execute(
          ''' CREATE TABLE modules (moduleId INTEGER NOT NULL  PRIMARY KEY AUTOINCREMENT,
     name TEXT, location VARCHAR(30), moduleType VARCHAR(20),creationDate TEXT );''');

      await db.execute(
          ''' CREATE TABLE objects (objectId INTEGER NOT NULL  PRIMARY KEY AUTOINCREMENT,
     moduleId INTEGER, name VARCHAR(30), objectType VARCHAR(20), creationDate TEXT );''');

      await db.execute(
          ''' CREATE  TABLE images (imageId INTEGER NOT NULL  PRIMARY KEY AUTOINCREMENT,
     objectId INTEGER, name VARCHAR(30), path VARCHAR(40) );''');

      //   await db.execute(
      //       ''' CREATE TABLE measurements (measurementId INTEGER NOT NULL  PRIMARY KEY AUTOINCREMENT,
      //  imageId INTEGER, type VARCHAR(15), color VARCHAR(20));''');

      await db.execute(
          ''' CREATE TABLE lengthpoints (pointsId INTEGER NOT NULL  PRIMARY KEY AUTOINCREMENT,
     imageId INTEGER, firstpoint_x DOUBLE NOT NULL,firstpoint_y DOUBLE NOT NULL,
     secondpoint_x DOUBLE NOT NULL,secondpoint_y DOUBLE NOT NULL, length DOUBLE, width DOUBLE, color VARCHAR(20), backgroundColor VARCHAR(20),unit VARCHAR(5)
     );''');

      await db.execute(
          ''' CREATE TABLE anglepoints (pointsId INTEGER NOT NULL  PRIMARY KEY AUTOINCREMENT,
     imageId INTEGER, firstpoint_x DOUBLE NOT NULL,firstpoint_y DOUBLE NOT NULL,
     secondpoint_x DOUBLE NOT NULL,secondpoint_y DOUBLE NOT NULL,
     thirdpoint_x DOUBLE NOT NULL,thirdpoint_y DOUBLE NOT NULL, angle DOUBLE, width DOUBLE, color VARCHAR(20), backgroundColor VARCHAR(20),unit VARCHAR(5)
     );''');

      await db.execute(
          ''' CREATE TABLE audios(audioId INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT, moduleId INTEGER,
     filename VARCHAR(30), description TEXT, path TEXT);''');

      print("database successfuly created");
    }, onOpen: (db) async {
      print("database opened");
    }, version: 1);

    return database;
  }
}
