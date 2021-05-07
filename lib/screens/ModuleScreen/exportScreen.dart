import 'dart:io';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_archive/flutter_archive.dart';
import 'package:new_bluebyte/components/InfoDialog.dart';
import 'package:new_bluebyte/components/objectsPainter.dart';
import 'package:new_bluebyte/components/pointMode.dart';
import 'package:new_bluebyte/models/audioModel.dart';
import 'package:new_bluebyte/models/moduleModel.dart';
import 'package:new_bluebyte/models/newImageModel.dart';
import 'package:new_bluebyte/models/objectModel.dart';
import 'package:new_bluebyte/provider/audiosProvider.dart';
import 'package:new_bluebyte/provider/modulesProvider.dart';
import 'package:new_bluebyte/provider/newImagesProvider.dart';
import 'package:new_bluebyte/provider/objectsProvider.dart';
import 'package:new_bluebyte/utils/colors&fonts.dart';
import 'package:new_bluebyte/utils/config.dart';
import 'package:new_bluebyte/utils/settings.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:path/path.dart' as path;

class ExportScreen extends StatefulWidget {
  final Module module;
  final AppSettings settings;

  ExportScreen({@required Module module, @required AppSettings settings})
      : module = module,
        settings = settings;
  @override
  _ExportScreenState createState() => _ExportScreenState();
}

class _ExportScreenState extends State<ExportScreen> {
  GlobalKey paintKey = GlobalKey();
  List<Object> moduleObjects;
  List<Audio> moduleAudios;
  PointCollector pointController;

  // bool _isLoading = true;
  ObjectImage _currentImage;
  Object _currentObject;
  double progress = 0;
  int totalImages = 0;
  int totalAudios = 0;
  int imageCount = 0;
  int audioCount = 0;
  bool _canSnap = false;
  Map<int, File> imageFiles = {};
  @override
  void initState() {
    super.initState();

    Future.delayed(Duration(milliseconds: 1000), () async {
      // bool isFrench = widget.settings.globalLanguage.getValue() == Config.fr;
      await SystemChrome.setPreferredOrientations(
          [DeviceOrientation.landscapeLeft, DeviceOrientation.landscapeRight]);
      //Exportation done here
      // final moduleProvider = Provider.of<ModulesProvider>(context);
      final imagesProvider =
          Provider.of<ImagesProvider>(context, listen: false);
      moduleObjects = await Provider.of<ObjectProvider>(context, listen: false)
          .getObjects(widget.module.moduleId);
      moduleAudios = await Provider.of<AudioProvider>(context, listen: false)
          .getAudios(widget.module.moduleId);

      Map<int, List<ObjectImage>> objectImages = {};

      for (int i = 0; i < moduleObjects.length; i++) {
        objectImages[moduleObjects[i].objectId] =
            await imagesProvider.getImages(moduleObjects[i].objectId);

        totalImages += objectImages[moduleObjects[i].objectId].length;
      }

      totalAudios = moduleAudios.length;

      /////////////////////////////////////////////////////////////////////////////
      ////                                                                    ////
      ///                     Directory creation and snapshot   here          ///
      //////////////////////////////////////////////////////////////////////////

      //we create the directory in which the project will be exported
      final appDir = Directory("storage/emulated/0/BlueByte");
      final moduleDirectory =
          Directory('storage/emulated/0/BlueByte/${widget.module.name}');
      Directory objectsDirectory =
          Directory(path.join(moduleDirectory.path, 'Objects'));
      Directory audiosDirectory =
          Directory(path.join(moduleDirectory.path, 'Audios'));

      final status = await Permission.storage.status;

      if (!status.isGranted) {
        await Permission.storage.request();
      }

      //if directories do not exist we create them
      if (!(await moduleDirectory.exists())) {
        await moduleDirectory.create(recursive: true);
        print('directory created at ${moduleDirectory.path}');
      }

      if (!await objectsDirectory.exists()) {
        await objectsDirectory.create(recursive: false);
      }
      if (await audiosDirectory.exists()) {
        await audiosDirectory.delete(recursive: true);
      }
      await audiosDirectory.create(recursive: false);

      ////////////////////////////////////////////////////////////////////////

      //we iterate over each object and perform screen shots of its images
      for (int i = 0; i < moduleObjects.length; i++) {
        _currentObject = moduleObjects[i];
        Directory imDir = Directory(
            path.join(objectsDirectory.path, '${_currentObject.name}'));

        //if a previous export to the images directory existed we delete the content and create back the directory
        if (await imDir.exists()) imDir.delete(recursive: true);

        await imDir.create(recursive: true);

        for (int j = 0; j < objectImages[_currentObject.objectId].length; j++) {
          _currentImage = objectImages[_currentObject.objectId][j];
          imageFiles.addAll({_currentImage.imageId: File(_currentImage.path)});

          pointController = PointCollector(
              PointMode.Length, _currentImage.imageId, true, widget.settings,
              objectId: _currentObject.objectId,
              objectName: _currentObject.name,
              image: _currentImage,
              imagePath: _currentImage.path,
              moduleName: widget.module.name,
              editService: null,
              widgetState: null);

          //after initializing the points controller we load all the points for the current image
          await pointController.loadPoints(context);

          setState(() {});

          await Future.delayed(Duration(milliseconds: 1500), () async {
            //we then take a screenshot and move to the next image
            /////////////////////////////////////////////////////////////////////////////

            final finalPath =
                path.join(imDir.path, "${_currentImage.name}.png");

            RenderRepaintBoundary boundary =
                paintKey.currentContext.findRenderObject();
            var image = await boundary.toImage();
            var byteData = await image.toByteData(format: ImageByteFormat.png);
            var pngBytes = byteData.buffer.asUint8List();

            try {
              print("before file creation");
              File imgFile = new File("$finalPath");
              // if (await imgFile.exists()) imgFile.delete();
              // imgFile.create(recursive: true);

              imageCount++;

              imgFile.writeAsBytes(pngBytes);

              setState(() {
                progress =
                    (((imageCount + audioCount) / (totalImages + totalAudios)) *
                        100);
              });
            } catch (err) {
              if (err is FileSystemException) {
                print('fileSystemException:$err');
              }

              print("error:$err");
            }
            ////////////////////////////////////////////////////////////////////////////
          });
        }
      }

      //after writing all images to export directory we now write all audios to export directory
      Audio currentAudio;
      for (int i = 0; i < moduleAudios.length; i++) {
        currentAudio = moduleAudios[i];
        File audioFile = File(currentAudio.path);
        if (await audioFile.exists()) {
          try {
            await audioFile.copy(path.join(
                audiosDirectory.path, '${currentAudio.filename}.m4a'));
            audioCount++;
            setState(() {
              progress =
                  (((imageCount + audioCount) / (totalImages + totalAudios)) *
                      100);
            });
          } catch (err) {
            print('could not copy ${currentAudio.filename}.m4a');
            await showDialog(
                context: context,
                builder: (context) {
                  return AlertDialog(
                    title: Text(
                      'Erreur!',
                      style: TextStyle(color: Colors.red),
                    ),
                    content: Text(
                      "Une érreure s'est produite lors de l'exportation. $err",
                      style: TextStyle(color: Colors.red),
                    ),
                  );
                });
            Future.delayed(Duration(seconds: 5), () {
              Navigator.of(context).pop();
            });
          }
        }
      }

      //after exportation we zip the file
      final zipFile = File(path.join(appDir.path, '${widget.module.name}.zip'));
      if (await zipFile.exists()) await zipFile.delete(recursive: true);
      await ZipFile.createFromDirectory(
        sourceDir: moduleDirectory,
        zipFile: zipFile,
      );
      if (mounted) {
        await showDialog(
            context: context,
            builder: (context) => AlertDialog(
                  title: Text('Succès'),
                  content: Text('Le module a été exporté avec succès!😁👌'),
                ));
      }
      Navigator.of(context).pop();
    });
  }

  @override
  dispose() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight
    ]);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: _currentObject != null && _currentImage != null
            ? Stack(
                alignment: Alignment.center,
                children: [
                  RepaintBoundary(
                    key: paintKey,
                    child: Container(
                        color: Colors.black,
                        constraints: BoxConstraints.expand(
                          height: MediaQuery.of(context).size.height,
                          width: MediaQuery.of(context).size.width,
                        ),
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            Stack(
                              fit: StackFit.expand,
                              children: [
                                Image(
                                  image: FileImage(
                                    imageFiles[_currentImage.imageId],
                                  ),
                                  fit: BoxFit.contain,
                                  // filterQuality: FilterQuality.high,
                                  loadingBuilder:
                                      (context, child, loadingProgress) {
                                    if (loadingProgress == null)
                                      return child;
                                    else {
                                      print(loadingProgress
                                          .cumulativeBytesLoaded);
                                      if ((loadingProgress
                                                  .cumulativeBytesLoaded /
                                              loadingProgress
                                                  .expectedTotalBytes) >=
                                          1) {
                                        setState(() {
                                          _canSnap = true;
                                          print('can snap changed ohhh!');
                                        });
                                        return child;
                                      } else {
                                        setState(() {
                                          if (_canSnap) _canSnap = false;
                                        });
                                        return CircularProgressIndicator(
                                          backgroundColor: AppColors.purpleDark,
                                          value: loadingProgress
                                                  .cumulativeBytesLoaded /
                                              loadingProgress
                                                  .expectedTotalBytes,
                                        );
                                      }
                                    }
                                  },
                                ),
                                ObjectsPainter(
                                    context: context,
                                    image: _currentImage,
                                    imagePath: _currentImage.path,
                                    isFrench: widget.settings.globalLanguage
                                            .getValue() ==
                                        Config.fr,
                                    moduleName: widget.module.name,
                                    objectId: _currentObject.objectId,
                                    objectName: _currentObject.name,
                                    pointControllerState: pointController,
                                    settings: widget.settings,
                                    state: this,
                                    strokeWidth:
                                        widget.settings.lineWidth.getValue(),
                                    objectsToPaint:
                                        pointController.objectStackFinal)
                              ],
                            ),
                          ],
                        )),
                  ),
                  Container(
                    constraints: BoxConstraints.expand(),
                    color: Colors.black.withOpacity(.6),
                    child: Center(
                      child: Text(
                        '${progress.toStringAsFixed(2)}%',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 40,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              )
            : Center(
                child: CircularProgressIndicator(
                  backgroundColor: AppColors.purpleDark,
                ),
              ));
  }
}
