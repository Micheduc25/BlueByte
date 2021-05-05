import 'dart:async';

import 'package:new_bluebyte/database/dbOps.dart';
import 'package:new_bluebyte/models/moduleModel.dart';
import 'package:new_bluebyte/utils/config.dart';

import 'package:flutter/material.dart';

class ModulesProvider with ChangeNotifier {
  List<Module> modules = [];
  bool getStreams;
  // StreamController<List<Module>> modulesController = new StreamController();

  Future<List<Module>> getModules({String filterKey = ""}) async {
    final tempModules = await DbOperations.getAllModules();
    modules = tempModules.map<Module>((map) {
      return new Module.fromMap(map);
    }).toList();
    // this.setModules = modules;

    if (filterKey == "" || filterKey == null)
      return modules;
    else {
      return modules.where((module) {
        if (module.name.toLowerCase().startsWith(filterKey.toLowerCase()))
          return true;
        else
          return false;
      }).toList();
    }
  }

  set setModules(List<Module> moduless) {
    modules = moduless;
    // modulesController.add(moduless);
    notifyListeners();
    print("modules set");
  }

  Future<void> deleteModule(int moduleId) async {
    //we get all the objects of that module
    final moduleObjects = await DbOperations.getObjects(moduleId);
    //we get the images of each of these objects
    moduleObjects.forEach((object) async {
      final objectImages = await DbOperations.getObjectImages(object.objectId);
      //for each of these images we delete its points
      objectImages.forEach((image) async {
        await DbOperations.deleteImagePoints(
            image.imageId, Config.lengthpoints);
        await DbOperations.deleteImagePoints(image.imageId, Config.anglepoints);

        //then we delete the image itself
        await DbOperations.deleteImage(image.imageId, image.path);
      });

      //we then delete the objects themselves
      await DbOperations.deleteObject(object.objectId);
    });

    await DbOperations.deleteModuleAudios(moduleId);
    await DbOperations.deleteModule(moduleId);

    final tempModules = await DbOperations.getAllModules();
    modules = tempModules.map<Module>((map) {
      return new Module.fromMap(map);
    }).toList();
    notifyListeners();
  }
}
