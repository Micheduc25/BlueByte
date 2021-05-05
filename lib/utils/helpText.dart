class HelpText {
  static String introMessage(bool isFrench) {
    if (!isFrench)
      return """
Welcome to the help section of the bluebyte data collector application. Like the name clearly entails, bluebyte is a mobile application which permits users to collect data from the field. This can be done by taking pictures with the mobile device(phone or tablet) or importing pictures already found in the device.The application permits users to indicate measures for lengths, angles and also permits users to record audios. All this data can be exported to other platforms and applicationsfor further processing.
This tutorial will enlighten you on all of the major features of this application 😘 
""";
    else
      return """
Bienvenue dans la section d'aide de l'application de collecte de données bluebyte. Comme son nom l'indique clairement, bluebyte est uneapplication mobile qui permet aux utilisateurs de collecter des données sur le terrain. Cela peut être fait en prenant des photos avec l'appareil photo du mobile(téléphone ou tablette) ou l'importation d'images déjà trouvées dans l'appareil. L'application permet aux utilisateurs d'indiquer les mesures(longueurs et angles) et permet également aux utilisateurs d'enregistrer des fichiers audio. Toutes ces données peuvent être exportées vers d'autres plateformes et applications pour un traitement ultérieur.
Ce tutoriel vous éclairera sur toutes les principales fonctionnalités de cette application 😘
""";
  }

  static String projectStructureTitle(bool isFrench) {
    if (isFrench)
      return "Structure d'un projet bluebyte";
    else
      return "Structure of a bluebyte project";
  }

  static String takingMeasurementsTitle(bool isFrench) {
    if (isFrench)
      return "Prendre des mesures";
    else
      return "Taking measurements";
  }

  static String recordingAudiosTitle(bool isFrench) {
    if (isFrench)
      return "Enregistrement d'audios";
    else
      return "Recording of audios";
  }

  static String configureApplicationTitle(bool isFrench) {
    if (isFrench)
      return "Configurer l'application";
    else
      return "Configure the application";
  }

  static String manageProjectTitle(bool isFrench) {
    if (isFrench)
      return "Comment gérer son projet";
    else
      return "How to manage your projects";
  }

  static String projectStructureBody1(bool isFrench) {
    if (isFrench)
      return '''Les projets bluebyte sont organisés en modules. Un module représente un endroit particulier,
par exemple un établissement, un bâtiment ou tout autre chose modélisable\n les modules à leurs tour peuvent 
avoir des objets qui représentes des parties du module. Dans le cas d'un établissement, un objet pourrait 
être une salle de classe ou juste un banc. 
Chaque objet peut avoir une ou plusieurs photos qui le montre sous plusieurs angles. Les modules peuvent aussi
avoir de enregistrements audios pour capter les sons de l'environement dans lequel le bâtiment est situé.''';
    else
      return '''Bluebyte projects are organized into modules. A module represents a particular place,
for example a school, a building or anything else that can be modeled \ n the modules in turn can
have objects that represent parts of the module. In the case of a school, an object could
be a classroom or just a bench.
Each object can have one or more photos that shows it from multiple angles. Modules can also
have audio recordings to capture the sounds of the environment in which the building is located.''';
  }

  static String takingMeasurementsBody1(bool isFrench) {
    if (isFrench)
      return '''Après avoir créé un module avec des objets et des images, nous pouvons maintenant indiquer les mesures
sur les photos prises. Ces mesures peuvent être des angles ou des longueurs. Pour placer des mesures,
appuyez sur une image sur l'écran des images d'un objet et un autre écran apparaîtra comme indiqué ci-dessous''';
    else
      return '''After having created a module with objects and images, we can now indicate measurements on the taken pictures.
These measurements could either be angles or lengths. To place measurements, tap on an image on the images
screen of an object and another screen will appear as shown below''';
  }
}
