import 'package:new_bluebyte/database/dbOps.dart';
import 'package:new_bluebyte/models/audioModel.dart';
import 'package:flutter/cupertino.dart';

class AudioProvider with ChangeNotifier {
  List<Audio> audios = [];

  Future<List<Audio>> getAudios(int moduleId, {String filterKey = ""}) async {
    audios = await DbOperations.getModuleAudios(moduleId);

    if (filterKey == "" || filterKey == null) {
      return audios;
    } else {
      return audios.where((audio) {
        if (audio.filename.toLowerCase().startsWith(filterKey.toLowerCase()))
          return true;
        else
          return false;
      }).toList();
    }
  }

  set setAudios(List<Audio> audioss) {
    audios = audioss;
    notifyListeners();
  }

  Future<void> deleteAudio(int moduleId, int audioId, String path) async {
    await DbOperations.deleteAudio(audioId, path);

    this.audios = await DbOperations.getModuleAudios(moduleId);

    notifyListeners();
  }
}
