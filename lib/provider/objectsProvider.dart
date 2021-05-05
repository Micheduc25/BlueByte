import 'package:new_bluebyte/database/dbOps.dart';
// import 'package:new_bluebyte/models/audioModel.dart';
import 'package:new_bluebyte/models/objectModel.dart';
import 'package:new_bluebyte/utils/config.dart';
import 'package:flutter/cupertino.dart';

class ObjectProvider with ChangeNotifier {
  List<Object> objects = [];

  Future<List<Object>> getObjects(int moduleId, {String filterkey = ""}) async {
    objects = await DbOperations.getObjects(moduleId);

    if (filterkey == "" || filterkey == null) {
      return objects;
    } else {
      return objects.where((obj) {
        if (obj.name.toLowerCase().startsWith(filterkey.toLowerCase()))
          return true;
        else
          return false;
      }).toList();
    }
  }

  set setObjects(List<Object> audioss) {
    objects = audioss;
    notifyListeners();
  }

  Future<void> editObject(int objectId, Map<String, dynamic> newData) async {
    await DbOperations.editObject(objectId, newData);
    notifyListeners();
  }

  Future<void> deleteObject(int moduleId, int objectId) async {
    final objectImages = await DbOperations.getObjectImages(objectId);
    //for each of these images we delete its points
    objectImages.forEach((image) async {
      await DbOperations.deleteImagePoints(image.imageId, Config.lengthpoints);
      await DbOperations.deleteImagePoints(image.imageId, Config.anglepoints);

      //then we delete the image itself
      await DbOperations.deleteImage(image.imageId, image.path);
    });

    //we then delete the objects themselves
    await DbOperations.deleteObject(objectId);

    this.objects = await DbOperations.getObjects(moduleId);
    notifyListeners();
  }
}
