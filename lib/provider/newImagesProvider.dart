import 'package:new_bluebyte/database/DBConnect.dart';
import 'package:new_bluebyte/database/dbOps.dart';
import 'package:new_bluebyte/models/newImageModel.dart';
import 'package:new_bluebyte/utils/config.dart';
import 'package:flutter/material.dart';

class ImagesProvider with ChangeNotifier {
  List<ObjectImage> images = [];

  Future<List<ObjectImage>> getImages(int objectId) async {
    if (images.isNotEmpty) images = [];
    print("getting images for object $objectId ...");
    final db = await DBConnect().initDB();

    final queryResult =
        await db.rawQuery("SELECT * FROM images WHERE objectId=$objectId");

    for (int i = 0; i < queryResult.length; i++) {
      images.add(new ObjectImage.fromMap(queryResult[i]));
    }
    notifyListeners();
    return images;
  }

  Future<void> deleteImage(int objectId, int imageId, String imagePath) async {
    //we delete the image points
    await DbOperations.deleteImagePoints(imageId, Config.lengthpoints);
    await DbOperations.deleteImagePoints(imageId, Config.anglepoints);

    //then we delete the image itself
    await DbOperations.deleteImage(imageId, imagePath);

    await this.getImages(objectId);
    // notifyListeners();
  }
}
