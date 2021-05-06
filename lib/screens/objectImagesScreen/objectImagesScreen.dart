import 'dart:async';

import 'package:new_bluebyte/components/InfoDialog.dart';
import 'package:new_bluebyte/components/editObject.dart';
import 'package:new_bluebyte/components/infoGetter.dart';

import 'package:new_bluebyte/components/purpleButton.dart';

import 'package:new_bluebyte/models/newImageModel.dart';
import 'package:new_bluebyte/models/objectModel.dart';
import 'package:new_bluebyte/provider/newImagesProvider.dart';
import 'package:new_bluebyte/provider/objectsProvider.dart';
import 'package:new_bluebyte/screens/ImageScreen/imageScreen.dart';
import 'package:new_bluebyte/screens/SettingsScreen/settings_image.dart';

import 'package:new_bluebyte/utils/colors&fonts.dart';
import 'package:new_bluebyte/utils/config.dart';
import 'package:new_bluebyte/utils/languages.dart';
import 'package:new_bluebyte/utils/settings.dart';
import 'package:new_bluebyte/utils/styles.dart';
import 'package:flutter/material.dart';

import 'package:provider/provider.dart';

class ObjectImages extends StatefulWidget {
  ObjectImages(
      {this.settings,
      this.objectId,
      this.moduleName,
      this.objectName,
      this.object,
      @required this.moduleId});
  final Object object;
  final String objectName;

  final AppSettings settings;
  final int objectId;
  final int moduleId;
  final String moduleName;

  @override
  _ObjectImagesState createState() => _ObjectImagesState();
}

class _ObjectImagesState extends State<ObjectImages> {
  List<ObjectImage> objectImages;
  bool loading;
  TextEditingController nameController;
  Map info;
  String language;
  StreamSubscription<String> langSubs;
  String objectName;
  bool canDelete;
  List<int> imagesToDeleteIds;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    language = widget.settings.globalLanguage.getValue();
    nameController = new TextEditingController();
    objectImages = [];
    Future.delayed(Duration.zero, () {
      Provider.of<ImagesProvider>(context, listen: false)
          .getImages(widget.objectId)
          .then((value) => {
                setState(() {
                  isLoading = false;
                })
              });
    });
    imagesToDeleteIds = [];
    canDelete = false;
    objectName = widget.objectName;
    loading = false;
    langSubs = widget.settings.globalLanguage.listen((lang) {
      if (mounted)
        setState(() {
          language = lang;
          print("language is $language");
        });
    });
  }

  @override
  void dispose() {
    nameController?.dispose();
    langSubs.cancel();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    objectImages = Provider.of<ImagesProvider>(context).images;

    final width = MediaQuery.of(context).size.width;
    bool isFrench = language == Config.fr;
    return Scaffold(
      appBar: AppBar(
          centerTitle: true,
          backgroundColor: AppColors.purpleNormal,
          title: canDelete
              ? SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Text(Languages.deleteImage(imagesToDeleteIds.length)[
                      isFrench ? Config.fr : Config.en]))
              : SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child:
                      Text(widget.moduleName + "-" + objectName + "-images")),
          leading: InkWell(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 5.0),
              child: Icon(Icons.navigate_before, size: 30, color: Colors.white),
            ),
            onTap: () {
              if (!canDelete)
                Navigator.of(context).pop();
              else
                setState(() {
                  imagesToDeleteIds = [];
                  canDelete = false;
                });
            },
          ),
          actions: !canDelete
              ? [
                  InkWell(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: Icon(Icons.settings, color: Colors.white),
                      ),
                      onTap: () {
                        Navigator.of(context).push(MaterialPageRoute(
                            builder: (context) => ImageSettingsScreen(
                                settings: widget.settings)));
                      }),
                  PopupMenuButton(
                    icon: Icon(Icons.more_vert, size: 30),
                    itemBuilder: (context) {
                      return [
                        PopupMenuItem(
                          child: ListTile(
                            leading: Icon(Icons.edit,
                                color: AppColors.purpleNormal, size: 30),
                            title: Text(
                              Languages.edit[isFrench ? Config.fr : Config.en],
                              style: Styles.purpleTextNormal,
                            ),
                          ),
                          value: "edit",
                        ),
                        PopupMenuItem(
                            value: "info",
                            child: ListTile(
                              leading: Icon(
                                Icons.info_outline,
                                color: AppColors.purpleNormal,
                                size: 30,
                              ),
                              title: Text(
                                Languages
                                    .info[isFrench ? Config.fr : Config.en],
                                style: Styles.purpleTextNormal,
                              ),
                            )),
                        PopupMenuItem(
                          child: ListTile(
                            leading:
                                Icon(Icons.delete, color: Colors.red, size: 30),
                            title: Text(
                              Languages
                                  .delete[isFrench ? Config.fr : Config.en],
                              style: Styles.purpleTextNormal,
                            ),
                          ),
                          value: "delete",
                        )
                      ];
                    },
                    onSelected: (value) async {
                      if (value == "edit") {
                        //object edition code here
                        String editedName = await showDialog<String>(
                            context: context,
                            builder: (context) {
                              return Dialog(
                                child: editObjectinfoGetter(context,
                                    objectId: widget.objectId,
                                    lang: language,
                                    initialName: widget.objectName,
                                    initialType: widget.object.objectType),
                              );
                            });

                        if (editedName != null) {
                          objectName = editedName;
                        }

                        setState(() {});
                      } else if (value == "delete") {
                        //we handle object deletion here

                        Provider.of<ObjectProvider>(context, listen: false)
                            .deleteObject(widget.moduleId, widget.objectId)
                            .then((_) {
                          Navigator.of(context).pop();
                        });
                      } else {
                        await showDialog(
                            context: context,
                            builder: (context) {
                              return InfoDialog(
                                  title: Languages.objectInfoTitle[
                                      isFrench ? Config.fr : Config.en],
                                  fieldsAndInfo: {
                                    Languages.name[isFrench
                                        ? Config.fr
                                        : Config.en]: widget.object.name,
                                    Languages.objectType[isFrench
                                        ? Config.fr
                                        : Config.en]: widget.object.objectType,
                                    Languages.createdOn[
                                            isFrench ? Config.fr : Config.en]:
                                        widget.object.creationDate,
                                  });
                            });
                      }
                    },
                  )
                ]
              : [
                  InkWell(
                    child: Icon(
                      Icons.delete,
                      color: Colors.red,
                      size: 30,
                    ),
                    onTap: () async {
                      final response = await showDialog<bool>(
                          context: context,
                          builder: (context) {
                            return AlertDialog(
                              title: Text(
                                Languages.deleteImageTitle[
                                    isFrench ? Config.fr : Config.en],
                                style: Styles.purpleTextLarge,
                              ),
                              content: Text(
                                Languages.deleteImageMessage[
                                    isFrench ? Config.fr : Config.en],
                                style: Styles.purpleTextNormal,
                              ),
                              actions: <Widget>[
                                PurpleButton(
                                  label: Languages
                                      .no[isFrench ? Config.fr : Config.en],
                                  onPressed: () {
                                    Navigator.of(context).pop(false);
                                  },
                                ),
                                PurpleButton(
                                  label: Languages
                                      .yes[isFrench ? Config.fr : Config.en],
                                  onPressed: () {
                                    Navigator.of(context).pop(true);
                                  },
                                )
                              ],
                            );
                          });

                      //if the user selects yes we now delete every image who's id is in our delete list
                      //else we just pass
                      if (response) {
                        for (int i = 0; i < imagesToDeleteIds.length; i++) {
                          final image = objectImages.where((item) {
                            if (item.imageId == imagesToDeleteIds[i])
                              return true;
                            return false;
                          }).first;

                          await Provider.of<ImagesProvider>(context,
                                  listen: false)
                              .deleteImage(
                                  widget.objectId, image.imageId, image.path);
                        }

                        setState(() {
                          canDelete = false;
                          imagesToDeleteIds = [];
                        });

                        print("Images deleted successfully");
                      }
                    },
                  )
                ]),
      floatingActionButton: FloatingActionButton(
          child: Icon(
            Icons.camera_enhance,
            size: 30,
            color: Colors.white,
          ),
          backgroundColor: AppColors.purpleNormal,
          onPressed: () {
            showDialog(
                context: context,
                builder: (context) => Dialog(
                        child: InfoGetter(
                      context: context,
                      isFrench: isFrench,
                      lang: widget.settings.globalLanguage.getValue(),
                      nameController: nameController,
                      widgetSettings: widget.settings,
                      moduleName: widget.moduleName,
                      objectId: widget.objectId,
                      objectName: widget.objectName,
                    )));
          }),
      body: Center(
          child: Container(
        padding: EdgeInsets.all(5),
        alignment: Alignment.center,
        child: isLoading
            ? CircularProgressIndicator(
                backgroundColor: AppColors.purpleDark,
              )
            : objectImages.isEmpty
                ? Center(
                    child: Text(
                      Languages.noImages[isFrench ? Config.fr : Config.en],
                      style: Styles.purpleTextLarge,
                      textAlign: TextAlign.center,
                    ),
                  )
                : GridView.builder(
                    gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                        crossAxisSpacing: 5,
                        mainAxisSpacing: 5,
                        maxCrossAxisExtent: width <= 300
                            ? width
                            : width < 600
                                ? width * 0.5
                                : width < 900
                                    ? width * 0.3333
                                    : width * 0.25),
                    itemCount: objectImages.length,
                    itemBuilder: (context, index) => ImageItem(
                          id: objectImages[index].imageId,
                          foregroundColor: imagesToDeleteIds
                                  .contains(objectImages[index].imageId)
                              ? AppColors.purpleNormal.withOpacity(.4)
                              : Colors.transparent,
                          onLongPress: () {
                            //if the list of ids contains the id of this element we remove it , else we add it rather;
                            setState(() {
                              if (imagesToDeleteIds
                                  .contains(objectImages[index].imageId))
                                imagesToDeleteIds
                                    .remove(objectImages[index].imageId);
                              else
                                imagesToDeleteIds
                                    .add(objectImages[index].imageId);

                              canDelete = imagesToDeleteIds.isNotEmpty;
                            });
                          },
                          name: objectImages[index].name,
                          file: objectImages[index].path,
                          caption: objectImages[index].name,
                          onTap: () async {
                            if (canDelete) {
                              //if the list of ids contains the id of this element we remove it , else we add it rather;
                              setState(() {
                                if (imagesToDeleteIds
                                    .contains(objectImages[index].imageId))
                                  imagesToDeleteIds
                                      .remove(objectImages[index].imageId);
                                else
                                  imagesToDeleteIds
                                      .add(objectImages[index].imageId);

                                canDelete = imagesToDeleteIds.isNotEmpty;
                              });
                            } else
                              Navigator.of(context).push(MaterialPageRoute(
                                  builder: (context) => ImageScreen(
                                        objectName: widget.objectName,
                                        imagePath: objectImages[index].path,
                                        objectId: widget.objectId,
                                        settings: widget.settings,
                                        moduleName: widget.moduleName,
                                        image: objectImages[index],
                                      )));
                          },
                        )),
      )),
    );
  }
}
