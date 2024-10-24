import 'dart:async';

import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:koumi/models/Acteur.dart';
import 'package:koumi/providers/ActeurProvider.dart';
import 'package:koumi/providers/CountryProvider.dart';
import 'package:koumi/widgets/Carrousel.dart';
import 'package:koumi/widgets/CustomAppBar.dart';
import 'package:koumi/widgets/Default_Acceuil.dart';
import 'package:koumi/widgets/DetectorPays.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

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

  void getLocationNew() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        await Geolocator.openLocationSettings();
        return Future.error('Location services are disabled.');
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          return Future.error('Location permissions are denied');
        }
      }

      if (permission == LocationPermission.deniedForever) {
        return Future.error('Location permissions are permanently denied.');
      }

      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      Placemark placemark = placemarks.first;
      setState(() {
        detectedCountryCode = placemark.isoCountryCode!;
      });
    } catch (e) {
      print('Error: $e');
    }
  }

  var latitude = 'Getting Latitude..'.obs;
  var longitude = 'Getting Longitude..'.obs;
  var address = 'Getting Address..'.obs;
  late StreamSubscription<Position> streamSubscription;

  getLocation() async {
    bool serviceEnabled;

    LocationPermission permission;
    // Test if location services are enabled.
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Location services are not enabled don't continue
      // accessing the position and request users of the
      // App to enable the location services.
      await Geolocator.openLocationSettings();
      return Future.error('Location services are disabled.');
    }
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        // Permissions are denied, next time you could try
        // requesting permissions again (this is also where
        // Android's shouldShowRequestPermissionRationale
        // returned true. According to Android guidelines
        // your App should show an explanatory UI now.
        return Future.error('Location permissions are denied');
      }
    }
    if (permission == LocationPermission.deniedForever) {
      // Permissions are denied forever, handle appropriately.
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }
    // When we reach here, permissions are granted and we can
    // continue accessing the position of the device.
    streamSubscription =
        Geolocator.getPositionStream().listen((Position position) {
      latitude.value = 'Latitude : ${position.latitude}';
      longitude.value = 'Longitude : ${position.longitude}';
      getAddressFromLatLang(position);
    });
  }

  Future<void> getAddressFromLatLang(Position position) async {
    final detectorPays = Provider.of<DetectorPays>(context, listen: false);
    // if (!detectorPays.hasLocation){
       try {
        List<Placemark> placemark = await placemarkFromCoordinates(
            position.latitude, position.longitude);
        if (placemark.isNotEmpty) {
          Placemark place = placemark[0];
          debugPrint("Address ISO dans acceuil: $detectedC");
          address.value =
              'Address dans acceuil : ${place.locality}, ${place.country}, ${place.isoCountryCode}';

          if (mounted) {
            setState(() {
              detectedC = place.isoCountryCode;
              detectedCountryCode = place.isoCountryCode ?? "ML";
              detectedCountry = place.country ?? "Mali";
              print("pays dans acceuil: ${detectedCountry} code: ${detectedCountryCode}");
              if (detectedCountry != null || detectedCountry!.isNotEmpty) {
                detectorPays.setDetectedCountryAndCode(
                    detectedCountry!, detectedCountryCode!);
                print("pays dans acceuil: $detectedCountry code: $detectedCountryCode");
              } else {
                detectorPays.setDetectedCountryAndCode("Mali", "ML");
                print("Le pays n'a pas pu être détecté dans acceuil.");
              }
            });
          }

          debugPrint(
              "Address dans acceuil: ${place.locality}, ${place.country}, ${place.isoCountryCode}");
        } else {
          detectorPays.setDetectedCountryAndCode("Mali", "ML");
          debugPrint(
              "Aucun emplacement trouvé dans  accueil pour les coordonnées fournies.");
        }
      } catch (e) {
        detectorPays.setDetectedCountryAndCode("Mali", "ML");
        debugPrint(
            "Une erreur est survenue lors de la récupération de l'adresse : $e");
      }
    // }
  }

  void verify() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    email = prefs.getString('whatsAppActeur');
    if (email != null) {
      // Si l'email de l'acteur est présent, exécute checkLoggedIn
      acteur = Provider.of<ActeurProvider>(context, listen: false).acteur!;
      setState(() {
        isExist = true;
      });
    } else {
      setState(() {
        isExist = false;
      });
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    verify();
    getLocation();

    // final acteurProvider = Provider.of<ActeurProvider>(context, listen: false).isLogged;
    // Get.put(ConnectionVerify(), permanent: true);
  }

  @override
  void dispose() {
    streamSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromRGBO(255, 255, 255, 1),
      appBar: const CustomAppBar(),
      body: ListView(
        children: [
          //  SizedBox(height: 180, child: Carrousels()),

          SizedBox(height: 180, child: Carrousel()),
          // const SizedBox(
          //   height: 10,
          // ),
          // SizedBox(height: 180, child: isExist ? Carrousel(): CarrouselOffLine()),
          const SizedBox(
            height: 10,
          ),
          // isExist ?
          // SizedBox(height: 100, child: AlertAcceuil()): Container(),
          // const SizedBox(
          //   height: 10,
          // ),
          DefautAcceuil(),
          // isExist ?
          // SizedBox(
          //   child: GridView.count(
          //     shrinkWrap: true,
          //           physics: const NeverScrollableScrollPhysics(),
          //           crossAxisCount: 2,
          //           mainAxisSpacing: 2,
          //           crossAxisSpacing: 5,
          //           childAspectRatio: 2,
          //     children: _buildCards(),
          //   ),
          // ) : DefautAcceuil(),
          SizedBox(
            height: 20,
          )
        ],
      ),
    );
  }

  // List<Widget> _buildCards() {
  //   List<Widget> cards = [
  //     _buildAccueilCard("Intrants", "int.png", 1),
  //     _buildAccueilCard("Commandes", "cm.png", 3),
  //     _buildAccueilCard("Magasins", "shop.png", 4),
  //     // _buildAccueilCard("Météo", "meteo.png", 5),
  //     _buildAccueilCard("Moyens de Transports", "transp.png", 6),
  //     _buildAccueilCard("Materiels de Locations", "loc.png", 7),
  //     _buildAccueilCard("Produits agricoles", "pro.png", 9),
  //   ];

  //   if (isExist) {
  //     cards.insert(1, _buildAccueilCard("Conseils", "cons.png", 2));
  //     // cards.insert(4, _buildAccueilCard("Transport", "transport.png", 6));
  //     cards.insert(4, _buildAccueilCard("Météo", "met.png", 5));
  //     cards.insert(7, _buildAccueilCard("Alertes", "alt.png", 8));
  //   }

  //   return cards;
  // }

  // Widget _buildAccueilCard(String titre, String imgLocation, int index) {
  //   return Padding(
  //     padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 5),
  //     child: InkWell(
  //         onTap: () {
  //           if (index == 9) {
  //               Navigator.push(context,
  //                 MaterialPageRoute(builder: (context) => ProductsScreen(detectedCountry: detectedCountry)));

  //           } else if (index == 8) {
  //             Navigator.push(
  //                 context,
  //                 MaterialPageRoute(
  //                     builder: (context) => const AlerteScreen()));
  //           } else if (index == 7) {
  //             Navigator.push(context,
  //                 MaterialPageRoute(builder: (context) =>  l.Location(detectedCountry: detectedCountry)));
  //           } else if (index == 6) {
  //             Navigator.push(context,
  //                 MaterialPageRoute(builder: (context) =>  Transport(detectedCountry: detectedCountry)));
  //           } else if (index == 5) {
  //             Navigator.push(
  //                 context,
  //                 MaterialPageRoute(
  //                     builder: (context) => const WeatherScreen()));
  //           } else if (index == 4) {
  //             Navigator.push(context,
  //                 MaterialPageRoute(builder: (context) => const StoreScreen()));
  //           } else if (index == 3) {
  //             Navigator.push(
  //                 context,
  //                 MaterialPageRoute(
  //                     builder: (context) => const MesCommande()));
  //           } else if (index == 2) {
  //             Navigator.push(
  //                 context,
  //                 MaterialPageRoute(
  //                     builder: (context) => const ConseilScreen()));
  //           } else if (index == 1) {
  //             Navigator.push(
  //                 context,
  //                 MaterialPageRoute(
  //                     builder: (context) =>  IntrantScreen(detectedCountry: detectedCountry,)));
  //           }
  //         },
  //          borderRadius: BorderRadius.circular(10),
  //         child: Container(
  //           // width: 200, // Largeur fixe
  //           // height: 50, // Hauteur fixe
  //           decoration: BoxDecoration(
  //             borderRadius: BorderRadius.circular(10),
  //             color: Colors.white,
  //             boxShadow: const [
  //               BoxShadow(
  //                 blurRadius: 5.0,
  //                 color: Color.fromRGBO(0, 0, 0, 0.25), // Opacité de 10%
  //               ),
  //             ],
  //           ),
  //           child: Row(
  //             children: [
  //               Padding(
  //                 padding: const EdgeInsets.all(10.0),
  //                 child: Image.asset(
  //                   "assets/images/$imgLocation",
  //                   width: 50,
  //                   height: 50,
  //                   fit: BoxFit.cover,
  //                 ),
  //               ),
  //               Expanded(
  //                 child: Padding(
  //                   padding: const EdgeInsets.all(10.0),
  //                   child: Text(
  //                     titre,
  //                     maxLines: 2,
  //                     textAlign: TextAlign.center,
  //                     style: const TextStyle(
  //                       fontSize: 16,
  //                       fontWeight: FontWeight.bold,
  //                     ),
  //                   ),
  //                 ),
  //               ),
  //             ],
  //           ),
  //         )
  //         ),
  //   );
  // }
}
