import 'package:new_bluebyte/components/searchBar.dart';

import 'package:new_bluebyte/models/audioModel.dart';
import 'package:new_bluebyte/models/moduleModel.dart';
import 'package:new_bluebyte/provider/audiosProvider.dart';
import 'package:new_bluebyte/screens/AudioRecordScreen/audioPlayScreen.dart';

import 'package:new_bluebyte/utils/colors&fonts.dart';
import 'package:new_bluebyte/utils/config.dart';
import 'package:new_bluebyte/utils/languages.dart';
import 'package:new_bluebyte/utils/settings.dart';
import 'package:new_bluebyte/utils/styles.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AudiosView extends StatefulWidget {
  AudiosView({this.settings, this.module, @required this.isFrench});
  final Module module;
  final AppSettings settings;
  final bool isFrench;
  @override
  _AudiosViewState createState() => _AudiosViewState();
}

class _AudiosViewState extends State<AudiosView> {
  // List<Map<String, dynamic>>moduleAudios;

  List<Audio> moduleAudios;
  // List<Audio> moduleAudiosAnnex;
  TextEditingController searchController;
  String filterKey = "";
  bool inEditMode;

  @override
  void initState() {
    inEditMode = false;
    searchController = new TextEditingController();

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var isFrench = widget.isFrench;

    return Container(
      child: Center(
          child: Container(
              child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 5),
            child: SearchBar(
                searchController: searchController,
                isFrench: isFrench,
                searchFor: "audios",
                onChange: (text) {
                  setState(() {
                    filterKey = text;
                  });
                }),
          ),
          SizedBox(
            height: 5,
          ),
          Expanded(
            child: FutureBuilder(
                initialData: Provider.of<AudioProvider>(context).audios,
                future: Provider.of<AudioProvider>(context)
                    .getAudios(widget.module.moduleId, filterKey: filterKey),
                builder: (context, AsyncSnapshot<List<Audio>> snapshot) {
                  if (snapshot.connectionState == ConnectionState.done) {
                    moduleAudios = snapshot.data;
                    // moduleAudiosAnnex = snapshot.data;

                    if (moduleAudios.isEmpty) {
                      return Center(
                        child: Text(
                          Languages.noAudios[isFrench ? Config.fr : Config.en],
                          style: Styles.purpleTextLarge,
                          textAlign: TextAlign.center,
                        ),
                      );
                    }
                    return ListView.builder(
                        itemCount: moduleAudios.length,
                        itemBuilder: (context, index) {
                          return Column(
                            children: <Widget>[
                              InkWell(
                                splashColor:
                                    AppColors.purpleLight.withOpacity(.4),
                                child: ListTile(
                                  leading: Icon(
                                    Icons.audiotrack,
                                    color: AppColors.purpleNormal,
                                    size: 25,
                                  ),
                                  title: Text(
                                    moduleAudios[index].filename,
                                    style: Styles.purpleTextNormal,
                                  ),
                                  trailing: Text(
                                    moduleAudios[index].audioId.toString(),
                                    style: TextStyle(
                                        color: AppColors.purpleLight,
                                        fontSize: 14),
                                  ),
                                  onTap: () {
                                    Navigator.of(context).push(
                                        MaterialPageRoute(builder: (context) {
                                      //what is next
                                      return AudioPlayScreen(
                                        fileName: moduleAudios[index].filename,
                                        filePath: moduleAudios[index].path,
                                        settings: widget.settings,
                                      );
                                    }));
                                  },
                                ),
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
      ))),
    );
  }
}
