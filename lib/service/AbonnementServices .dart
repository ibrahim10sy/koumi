import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:koumi/constants.dart';
import 'package:koumi/models/Abonnement.dart';
import 'package:koumi/models/Acteur.dart';

class AbonnementServices extends ChangeNotifier {
  static const String baseUrl = '$apiOnlineUrl/abonnement';

  List<Abonnement> abonnementList = [];
  Abonnement? abonnement;

   Future<void> addAbonnements({
    required String modePaiement,
    required String typeAbonnement,
    required List<String> options,
    required int montant,
    required Acteur acteur
  }) async {
    var addAbonnements = jsonEncode({
      'idAbonnement': null,
      'typeAbonnement': typeAbonnement,
      'modePaiement': modePaiement,
      'montant': montant,
      'options': options,
      'acteur': acteur.toMap(),
    });

    final response = await http.post(Uri.parse("$baseUrl/AddAbonnement"),
        headers: {'Content-Type': 'application/json'}, body: addAbonnements);
    // debugPrint(addFormes.toString());
    if (response.statusCode == 200 || response.statusCode == 201) {
      debugPrint(response.body);
    } else {
      throw Exception("Une erreur s'est produite' : ${response.statusCode}");
    }
  }

   Future<List<Abonnement>> fetchAbonnement(String idActeur)  async {
    final response = await http.get(Uri.parse('$baseUrl/getAllByActeur/${idActeur}'));

    if (response.statusCode == 200 || response.statusCode == 201) {
      List<dynamic> body = jsonDecode(utf8.decode(response.bodyBytes));
      abonnementList = body.map((item) => Abonnement.fromMap(item)).toList();
      debugPrint(response.body);
      return abonnementList;
    } else {
      abonnementList = [];
      print('Échec de la requête forme avec le code d\'état: ${response.statusCode}');
      return abonnementList = [];
    }
  }

  Future<Abonnement?> fetchLatestAbonnement(String idActeur) async {
  final response = await http.get(Uri.parse('$baseUrl/dernier/${idActeur}'));

  if (response.statusCode == 200 || response.statusCode == 201) {
    // Décodez la réponse JSON
    final Map<String, dynamic> json = jsonDecode(utf8.decode(response.bodyBytes));
    
   
    final abonnement = Abonnement.fromJson(json);
    
    debugPrint(response.body);
    return abonnement;
  } else {
    print('Échec de la requête abonnement : $baseUrl/dernier/${idActeur} avec le code d\'état: ${response.statusCode}');
    return null; 
  }
}

  
  Future<void> deleteAbonnement(String idAbonnement) async {
    final response = await http.delete(Uri.parse("$baseUrl/delete/$idAbonnement"));
    if (response.statusCode == 200 || response.statusCode == 201) {
      applyChange();
      debugPrint(response.body.toString());
    } else {
      throw Exception(
          "Erreur lors de la suppression avec le code: ${response.statusCode}");
    }
  }

  Future<void> activerForme(String idAbonnement) async {
    final response = await http.put(Uri.parse("$baseUrl/activer/$idAbonnement"));
    if (response.statusCode == 200 || response.statusCode == 201) {
      applyChange();
      debugPrint(response.body.toString());
    } else {
      throw Exception(
          "Erreur lors de l'activation avec le code: ${response.statusCode}");
    }
  }

  Future<void> desactiverAbonnement(String idAbonnement) async {
    final response =
        await http.put(Uri.parse("$baseUrl/desactiver/$idAbonnement"));
    if (response.statusCode == 200 || response.statusCode == 201) {
      applyChange();

      debugPrint(response.body.toString());
    } else {
      throw Exception(
          "Erreur lors de la desactivation avec le code: ${response.statusCode}");
    }
  }

  void applyChange() {
    notifyListeners();
  }
}
