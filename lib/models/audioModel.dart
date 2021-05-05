import 'package:new_bluebyte/utils/config.dart';

class Audio {
  Audio(
      {this.audioId,
      this.moduleId,
      this.filename,
      this.description,
      this.path});

  final int audioId;
  final int moduleId;
  final String filename;
  final String description;
  final String path;

  factory Audio.fromMap(Map<String, dynamic> map) {
    return Audio(
        audioId: map[Config.audioId],
        moduleId: map[Config.moduleId],
        filename: map[Config.filename],
        description: map[Config.description],
        path: map[Config.path]);
  }

  Map<String, dynamic> toMap() {
    return {
      Config.moduleId: this.moduleId,
      Config.filename: this.filename,
      Config.description: this.description,
      Config.path: this.path
    };
  }
}
