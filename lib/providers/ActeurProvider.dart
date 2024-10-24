import 'package:flutter/material.dart';
import 'package:koumi/models/Acteur.dart';

import 'package:shared_preferences/shared_preferences.dart';

class ActeurProvider with ChangeNotifier {
  Acteur? _acteur;
  Acteur? _acteurUpdate;
  Acteur? get acteur => _acteur;
  Acteur? get acteurs => _acteurUpdate;
  bool isLogged = false;

  // Méthode pour initialiser les données de l'utilisateur à partir de SharedPreferences
  Future<void> initializeActeurFromSharedPreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? idActeur = prefs.getString('idActeur');
    String? emailActeur = prefs.getString('emailActeur');
    String? codeActeur = prefs.getString('codeActeur');
    String? password = prefs.getString('password');
    List<String>? userTypeList = prefs.getStringList('userType');
    List<String>? speculationList = prefs.getStringList('specType');
    String? nomActeur = prefs.getString('nomActeur');
    String? adresseActeur = prefs.getString('adresseActeur');
    String? telephoneActeur = prefs.getString('telephoneActeur');
    String? whatsAppActeur = prefs.getString('whatsAppActeur');
    String? niveau3PaysActeur = prefs.getString('niveau3PaysActeur');
    String? localiteActeur = prefs.getString('localiteActeur');

    if (emailActeur != null) {
      // L'utilisateur est connecté
      isLogged = true;
    } else {
      // L'utilisateur n'est pas connecté
      isLogged = false;
    }

    if (emailActeur != null &&
        password != null &&
        userTypeList != null &&
        speculationList != null &&
        codeActeur != null &&
        idActeur != null &&
        nomActeur != null &&
        adresseActeur != null &&
        telephoneActeur != null &&
        whatsAppActeur != null &&
        niveau3PaysActeur != null &&
        localiteActeur != null) {
      // Créer l'objet Acteur à partir des données de SharedPreferences
      _acteur = Acteur.fromSharedPreferencesData(
          emailActeur,
          password,
          userTypeList,
          speculationList,
          codeActeur,
          idActeur,
          nomActeur,
          telephoneActeur,
          adresseActeur,
          whatsAppActeur,
          niveau3PaysActeur,
          localiteActeur);
      notifyListeners();
    }
  }

  void setActeur(Acteur newActeur) {
    _acteur = newActeur;
    print("new acteur ${newActeur.toString()}");
    notifyListeners();
  }

  void setActeurUpdate(Acteur newActeurs) {
    _acteurUpdate = newActeurs;
    print("new acteur ${newActeurs.toString()}");
    notifyListeners();
  }

  // Future<void> logout() async {
  //   // Supprimer les données utilisateur
  //   SharedPreferences prefs = await SharedPreferences.getInstance();
  //   String? emailActeur = prefs.getString('emailActeur');
  //   String? codeActeur = prefs.getString('codeActeur');

  //   _acteur = null;

  //   await prefs.clear();
  //   if (emailActeur == null || emailActeur.isEmpty) {

  //     debugPrint("Email shared : $emailActeur");
  //   } else {
  //     debugPrint("Email shared isExist : $emailActeur");
  //   }

  //   // Réenregistrer le codeActeur dans SharedPreferences
  //   if (codeActeur != null) {
  //     String savedCodeActeur = codeActeur;
  //     prefs.setString('codeActeur', savedCodeActeur);
  //   }
  //   // Mettre à jour l'état de la connexion
  //   isLogged = false;
  //   notifyListeners();
  // }
  Future<void> logout() async {
    // Récupérer les données utilisateur avant de les effacer
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? whatsAppActeur = prefs.getString('whatsAppActeur');
    String? codeActeur = prefs.getString('codeActeur');

    // Effacer toutes les préférences
     // Réinitialiser l'acteur local
    _acteur = null;

    await prefs.clear();
    if (whatsAppActeur == null || whatsAppActeur.isEmpty) {
      debugPrint("whatsAppActeur shared : $whatsAppActeur");
    } else {
      debugPrint("whatsAppActeur shared isExist : $whatsAppActeur");
    }
    // Réenregistrer les valeurs nécessaires
    // if (emailActeur != null && emailActeur.isNotEmpty) {
    //   prefs.setString('emailActeur', emailActeur);
    //   print("email acteur apres logout : $emailActeur");
    // }

    if (codeActeur != null) {
      prefs.setString('codeActeur', codeActeur);
      print("code acteur apres logout : $codeActeur");
    }

    // Mettre à jour l'état de la connexion
    isLogged = false;
    notifyListeners();
  }
}
