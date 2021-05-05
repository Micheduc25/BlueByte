import 'package:new_bluebyte/components/searchBar.dart';

import 'package:new_bluebyte/models/moduleModel.dart';
import 'package:new_bluebyte/models/objectModel.dart';
import 'package:new_bluebyte/provider/objectsProvider.dart';
import 'package:new_bluebyte/screens/objectImagesScreen/objectImagesScreen.dart';
import 'package:new_bluebyte/utils/colors&fonts.dart';
import 'package:new_bluebyte/utils/config.dart';
import 'package:new_bluebyte/utils/languages.dart';
import 'package:new_bluebyte/utils/settings.dart';
import 'package:new_bluebyte/utils/styles.dart';
import 'package:flutter/material.dart';

import 'package:provider/provider.dart';

class ObjectsView extends StatefulWidget {
  ObjectsView({this.settings, this.module, this.isFrench});
  final Module module;
  final AppSettings settings;
  @required
  final bool isFrench;

  @override
  _ObjectsViewState createState() => _ObjectsViewState();
}

class _ObjectsViewState extends State<ObjectsView> {
  List<Object> moduleObjects;
  List<Object> moduleObjectsAnex;

  String filterKey = "";

  TextEditingController searchController;

  @override
  void initState() {
    moduleObjects = [];

    searchController = new TextEditingController();

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    bool isFrench = widget.isFrench;
    return Container(
        child: Center(
            child: Container(
                child: Column(
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 5),
          child: SearchBar(
            searchController: searchController,
            isFrench: isFrench,
            searchFor: Languages.objects[isFrench ? Config.fr : Config.en],
            onChange: (text) {
              //we set the filter key to the current value of the textfield
              setState(() {
                filterKey = text;
              });
            },
          ),
        ),
        SizedBox(
          height: 5,
        ),
        Expanded(
          child: FutureBuilder(
              // initialData:
              //     Provider.of<ObjectProvider>(context)
              //         .objects,
              future: Provider.of<ObjectProvider>(context)
                  .getObjects(widget.module.moduleId, filterkey: filterKey),
              builder: (context, AsyncSnapshot<List<Object>> snapshot) {
                if (snapshot.connectionState == ConnectionState.done) {
                  moduleObjects = snapshot.data;
                  moduleObjectsAnex = snapshot.data;

                  if (moduleObjects.isEmpty) {
                    return Center(
                      child: Text(
                        Languages.noObjects[isFrench ? Config.fr : Config.en],
                        style: Styles.purpleTextLarge,
                        textAlign: TextAlign.center,
                      ),
                    );
                  }

                  return ListView.builder(
                      itemCount: moduleObjects.length,
                      itemBuilder: (context, index) {
                        return Column(
                          children: <Widget>[
                            ListTile(
                              leading: Icon(
                                Icons.filter_center_focus,
                                color: AppColors.purpleNormal,
                                size: 25,
                              ),
                              title: Text(
                                moduleObjects[index].name,
                                style: Styles.purpleTextNormal,
                              ),
                              trailing: Text(
                                moduleObjects[index].creationDate,
                                style: TextStyle(
                                    color: AppColors.purpleLight, fontSize: 14),
                              ),
                              onTap: () {
                                if (moduleObjects[index] != null) {
                                  Navigator.of(context).push(
                                      MaterialPageRoute(builder: (context) {
                                    print(
                                        "object id is ${moduleObjects[index].objectId}");
                                    return ObjectImages(
                                      settings: widget.settings,
                                      moduleName: widget.module.name,
                                      moduleId: widget.module.moduleId,
                                      objectName: moduleObjects[index].name,
                                      object: moduleObjects[index],
                                      objectId: moduleObjects[index].objectId,
                                    );
                                  }));
                                }
                              },
                            ),
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: 5),
                              child: Divider(
                                height: 4,
                                color: AppColors.purpleNormal,
                                thickness: 1,
                              ),
                            )
                          ],
                        );
                      });
                } else {
                  return Center(
                    child: CircularProgressIndicator(
                      backgroundColor: AppColors.purpleNormal,
                    ),
                  );
                }
              }),
        )
      ],
    ))));
  }
}
