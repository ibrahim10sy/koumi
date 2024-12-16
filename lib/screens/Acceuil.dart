import 'dart:async';

import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:koumi/models/Acteur.dart';
import 'package:koumi/providers/ActeurProvider.dart';
import 'package:koumi/providers/CountryProvider.dart';
import 'package:koumi/widgets/CustomAppBar.dart';
import 'package:koumi/widgets/Default_Acceuil.dart';
import 'package:koumi/widgets/DetectorPays.dart';
import 'package:koumi/widgets/ProductSearchPage.dart';
import 'package:koumi/widgets/SearchProductButton.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:koumi/widgets/Carrousel.dart';

class Accueil extends StatefulWidget {
  const Accueil({super.key});

  @override
  State<Accueil> createState() => _AccueilState();
}

const d_colorGreen = Color.fromRGBO(43, 103, 6, 1);
const d_colorOr = Color.fromRGBO(255, 138, 0, 1);

class _AccueilState extends State<Accueil> {
  late Acteur acteur = Acteur();

  String? email = "";
  bool isExist = false;

  String? detectedC;
  String? isoCountryCode;
  String? country;
  String? detectedCountryCode;
  String? detectedCountry;
  CountryProvider? countryProvider;
  late BuildContext _currentContext;

  var latitude = 'Getting Latitude..'.obs;
  var longitude = 'Getting Longitude..'.obs;
  var address = 'Getting Address..'.obs;
  StreamSubscription<Position>? streamSubscription;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromRGBO(255, 255, 255, 1),
      appBar: const CustomAppBar(),
      body: ListView(
        children: [
          SizedBox(height: 180, child: Carrousel()),
          const SizedBox(
            height: 10,
          ),
          Center(
            child: SearchProductButton(
              onTap: () {
                // Naviguer vers l'écran de recherche
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ProductSearchPage()),
                );
              },
            ),
          ),
          const SizedBox(
            height: 10,
          ),
          DefautAcceuil(),
          SizedBox(
            height: 20,
          )
        ],
      ),
    );
  }
}
