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
    // _checkFirstLaunch();
    // requestUserConsent();
  }

  @override
  void dispose() {
    streamSubscription?.cancel();
    super.dispose();
  }

  // Vérifier si c'est le premier lancement
  // Future<void> _checkFirstLaunch() async {
  //   final prefs = await SharedPreferences.getInstance();
  //   bool isFirstLaunch = prefs.getBool('isFirstLaunchAccueil') ?? true;

  //   if (isFirstLaunch) {
  //     // Demander la permission de localisation
  //     await requestUserConsent();

  //     // Marquer que l'application a été lancée
  //     await prefs.setBool('isFirstLaunchAccueil', false);
  //   }
  // }

  Future<void> requestUserConsent() async {
    // Affiche une boîte de dialogue pour demander le consentement
    final consent = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          title: const Text('Autorisation de localisation'),
          content: const Text(
              'Cette application utilise votre position pour fournir des services personnalisés. Acceptez-vous de partager votre position ?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(false); // Refusé
              },
              child: const Text('Refuser'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(true); // Accepté
              },
              child: const Text('Accepter'),
            ),
          ],
        );
      },
    );

    if (consent == true) {
      await requestLocationPermission();
    } else {
      // L'utilisateur a refusé de partager sa position
      debugPrint('L\'utilisateur a refusé de partager sa position.');
    }
  }

  Future<void> requestLocationPermission() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Vérifie si le service de localisation est activé
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      await showAlertDialog(
        context,
        title: 'Service de localisation désactivé',
        content:
            'Le service de localisation est désactivé. Veuillez l\'activer pour utiliser cette fonctionnalité.',
        onConfirm: () async {
          await Geolocator.openLocationSettings();
        },
      );
      debugPrint('Location services are disabled.');
      return;
    }

    // Vérifie et demande les permissions nécessaires
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        await showAlertDialog(
          context,
          title: 'Permissions refusées',
          content:
              'Les permissions de localisation sont nécessaires pour utiliser cette fonctionnalité. Veuillez les activer dans les paramètres.',
          onConfirm: () async {
            await Geolocator.openAppSettings();
          },
        );
        debugPrint('Location permissions are denied');
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      await showAlertDialog(
        context,
        title: 'Permissions refusées en permanence',
        content:
            'Les permissions de localisation ont été refusées en permanence. Veuillez les activer dans les paramètres de l\'application.',
        onConfirm: () async {
          await Geolocator.openAppSettings();
        },
      );
      debugPrint(
          'Location permissions are permanently denied. Cannot request permission.');
      return;
    }

    // Si tout est en ordre, commence à écouter les positions
    getLocationUpdates();
  }

  void getLocationUpdates() {
    streamSubscription = Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 10000,
      ),
    ).listen((Position position) {
      debugPrint(
          'Position actuelle : Latitude: ${position.latitude}, Longitude: ${position.longitude}');
      getAddressFromLatLang(position);
      streamSubscription?.cancel(); // Annule après la première mise à jour
    });
  }

  Future<void> getAddressFromLatLang(Position position) async {
    final detectorPays = Provider.of<DetectorPays>(context, listen: false);
    try {
      List<Placemark> placemarks =
          await placemarkFromCoordinates(position.latitude, position.longitude);
      if (placemarks.isNotEmpty) {
        Placemark place = placemarks[0];

        debugPrint("Address ISO dans acceuil: $detectedC");
        address.value =
            'Address dans acceuil : ${place.locality}, ${place.country}, ${place.isoCountryCode}';

        // Comparez avec les valeurs existantes avant de mettre à jour
        String newDetectedCountryCode = place.isoCountryCode ?? "ML";
        String newDetectedCountry = place.country ?? "Mali";

        if (detectedCountryCode != newDetectedCountryCode ||
            detectedCountry != newDetectedCountry) {
          if (mounted) {
            setState(() {
              detectedC = place.isoCountryCode;
              detectedCountryCode = place.isoCountryCode ?? "ML";
              detectedCountry = place.country ?? "Mali";
              print(
                  "pays dans acceuil: ${detectedCountry} code: ${detectedCountryCode}");
              if (detectedCountry != null || detectedCountry!.isNotEmpty) {
                detectorPays.setDetectedCountryAndCode(
                    detectedCountry!, detectedCountryCode!);
                print(
                    "pays dans acceuil: $detectedCountry code: $detectedCountryCode");
              } else {
                detectorPays.setDetectedCountryAndCode("Mali", "ML");
                print("Le pays n'a pas pu être détecté dans acceuil.");
              }
            });
          }
        }

        String newAddress =
            'Address dans accueil : ${place.locality}, ${place.country}, ${place.isoCountryCode}';
        if (address.value != newAddress) {
          address.value = newAddress;
          debugPrint(newAddress);
        }
      } else {
        debugPrint(
            "Aucun emplacement trouvé dans accueil pour les coordonnées fournies.");
      }
    } catch (e) {
      debugPrint(
          'Une erreur est survenue lors de la récupération de l\'adresse : $e');
    }
  }

  Future<void> showAlertDialog(
    BuildContext context, {
    required String title,
    required String content,
    required VoidCallback onConfirm,
  }) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(content),
          actions: <Widget>[
            TextButton(
              child: const Text('Annuler'),
              onPressed: () {
                Navigator.of(context).pop(); // Ferme la boîte de dialogue
              },
            ),
            TextButton(
              child: const Text('Paramètres'),
              onPressed: () {
                Navigator.of(context).pop(); // Ferme la boîte de dialogue
                onConfirm(); // Appelle l'action confirmée
              },
            ),
          ],
        );
      },
    );
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
