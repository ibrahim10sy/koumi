import 'dart:async';

import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:koumi/Admin/ActeurScreen.dart';
import 'package:koumi/Admin/AlerteScreen.dart';
import 'package:koumi/Admin/CategoriePage.dart';
import 'package:koumi/Admin/FiliereScreen.dart';
import 'package:koumi/Admin/ProfilA.dart';
import 'package:koumi/models/Acteur.dart';
import 'package:koumi/providers/ActeurProvider.dart';
import 'package:koumi/providers/CountryProvider.dart';
import 'package:koumi/screens/ComplementAlimentaire.dart';
import 'package:koumi/screens/ConseilScreen.dart';
import 'package:koumi/screens/EngraisAndApport.dart';
import 'package:koumi/screens/FruitsAndLegumes.dart';
import 'package:koumi/screens/IntrantScreen.dart';
import 'package:koumi/screens/MatereilAndEquipement.dart';
import 'package:koumi/screens/MesCommande.dart';
import 'package:koumi/screens/MyProduct.dart';
import 'package:koumi/screens/Panier.dart';
import 'package:koumi/screens/Location.dart' as l;
import 'package:koumi/screens/Products.dart';
import 'package:koumi/screens/ProduitElevage.dart';
import 'package:koumi/screens/ProduitPhytosanitaire.dart';
import 'package:koumi/screens/ProduitTransforme.dart';
import 'package:koumi/screens/SemenceAndPlant.dart';
import 'package:koumi/screens/Store.dart';
import 'package:koumi/screens/Transport.dart';
import 'package:koumi/screens/Weather.dart';
import 'package:koumi/widgets/Carrousel.dart';
import 'package:koumi/widgets/CustomAppBar.dart';
import 'package:koumi/widgets/DetectorPays.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AcceuilAdmin extends StatefulWidget {
  const AcceuilAdmin({super.key});

  @override
  State<AcceuilAdmin> createState() => _AcceuilAdminState();
}

const d_colorGreen = Color.fromRGBO(43, 103, 6, 1);
const d_colorOr = Color.fromRGBO(255, 138, 0, 1);

class _AcceuilAdminState extends State<AcceuilAdmin> {
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
  StreamSubscription<Position>? streamSubscription;

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
    // if (!detectorPays.hasLocation) {
    try {
      List<Placemark> placemark =
          await placemarkFromCoordinates(position.latitude, position.longitude);
      if (placemark.isNotEmpty) {
        Placemark place = placemark[0];
        debugPrint("Address ISO: $detectedC");
        address.value =
            'Address : ${place.locality}, ${place.country}, ${place.isoCountryCode}';

        if (mounted) {
          setState(() {
            detectedC = place.isoCountryCode;
            detectedCountryCode = place.isoCountryCode ?? "ML";
            detectedCountry = place.country ?? "Mali";
            print("pays : ${detectedCountry} code: ${detectedCountryCode}");
            if (detectedCountry != null || detectedCountry!.isNotEmpty) {
              detectorPays.setDetectedCountryAndCode(
                  detectedCountry!, detectedCountryCode!);
              print("pays : $detectedCountry code: $detectedCountryCode");
            } else {
              detectorPays.setDetectedCountryAndCode("Mali", "ML");
              print("Le pays n'a pas pu être détecté.");
            }
          });
        }

        debugPrint(
            "Address: ${place.locality}, ${place.country}, ${place.isoCountryCode}");
      } else {
        detectorPays.setDetectedCountryAndCode("Mali", "ML");
        debugPrint(
            "Aucun emplacement trouvé dans admin accueil pour les coordonnées fournies.");
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
    //   WidgetsBinding.instance.addPostFrameCallback((_) {
    verify();
    getLocation();
    //  Snack.info(message:'Connecté en tant que : ${acteur.nomActeur!.toUpperCase()}') ;
    //   });
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
          // SizedBox(height: 200, child: Carrousels()),
          //  SizedBox(
          // height: 180, child: isExist ? Carrousel() : CarrouselOffLine()),
          SizedBox(height: 180, child: Carrousel()),
          // SizedBox(height: 100, child: isExist ? Carrousel(): CarrouselOffLine()),
          // const SizedBox(
          //   height: 10,
          // ),
          //  SizedBox(
          // height: 180, child: isExist ? Carrousel() : CarrouselOffLine()),
          // SizedBox(height: 100, child: AlertAcceuil()),
          const SizedBox(
            height: 10,
          ),
          SizedBox(
            child: GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              crossAxisSpacing: 4,
              childAspectRatio: 2,
              children: _buildCards(),
            ),
          ),
          const SizedBox(
            height: 20,
          )
        ],
      ),
    );
  }

  List<Widget> _buildCards() {
    List<Widget> cards = [
      _buildAccueilCard("Conseils", "cons1.png", 2),
      _buildAccueilCard("Alertes", "alt21.png", 8),
      // _buildAccueilCard("Semences et plants", "semence.png", 14),
      // _buildAccueilCard("Produits phytosanitaires", "physo.png", 15),
      // _buildAccueilCard("Engrais et apports", "engrais.png", 17),
      // _buildAccueilCard("Fruits et légumes", "fruit&legume.png", 16),
      // _buildAccueilCard("Compléments alimentaires", "compl.png", 18),
      // _buildAccueilCard("Produits d'élevages", "elevage.png", 19),
      // _buildAccueilCard("Matériels et équipements", "equi.png", 13),
      // _buildAccueilCard("Produits transformés", "transforme.png", 20),
      _buildAccueilCard("Commandes", "cm.png", 3),
      _buildAccueilCard("Magasins", "shop1.png", 4),
      _buildAccueilCard("Intrants agricoles", "int1.png", 1),
      _buildAccueilCard("Produits agricoles", "pro1.png", 9),
      _buildAccueilCard("Materiels de Locations", "loc.png", 7),
      _buildAccueilCard("Moyens de Transports", "transp.png", 6),
      _buildAccueilCard("Filières", "fi.jpg", 10),
      _buildAccueilCard("Météo", "met1.png", 5),
      _buildAccueilCard("Catégories", "c.jpg", 11),
      _buildAccueilCard("Acteurs", "ac1.png", 12),
    ];

    return cards;
  }

  Widget _buildAccueilCard(String titre, String imgLocation, int index) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 7),
      child: InkWell(
          onTap: () {
            if (index == 20) {
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => ProduitTransforme()));
            } else if (index == 19) {
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => ProduitElevage()));
            } else if (index == 18) {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => ComplementAlimentaire()));
            } else if (index == 17) {
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => EngraisAndApport()));
            } else if (index == 16) {
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => FruitAndLegumes()));
            } else if (index == 15) {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => ProduitPhytosanitaire()));
            } else if (index == 14) {
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => SemenceAndPlant()));
            } else if (index == 13) {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => MaterielAndEquipement()));
            } else if (index == 12) {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const ActeurScreen()));
            } else if (index == 11) {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const CategoriPage()));
            } else if (index == 10) {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const FiliereScreen()));
            } else if (index == 9) {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ProductsScreen(),
                  ));
            } else if (index == 8) {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      // builder: (context) => const AlertesOffLineScreen()));
                      builder: (context) => const AlerteScreen()));
            } else if (index == 7) {
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => l.Location()));
            } else if (index == 6) {
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => Transport()));
            } else if (index == 5) {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const WeatherScreen()));
            } else if (index == 4) {
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => StoreScreen()));
            } else if (index == 3) {
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => const MesCommande()));
            } else if (index == 2) {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const ConseilScreen()));
            } else if (index == 1) {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) =>
                          IntrantScreen(detectedCountry: detectedCountry)));
            }
          },
          borderRadius: BorderRadius.circular(10),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: Colors.white,
              boxShadow: const [
                BoxShadow(
                  blurRadius: 5.0,
                  color: Color.fromRGBO(0, 0, 0, 0.20),
                ),
              ],
            ),
            child: Row(
              children: [
                Padding(
                  padding: const EdgeInsets.all(5),
                  child: Image.asset(
                    "assets/images/$imgLocation",
                    width: 38,
                    height: 38,
                    fit: BoxFit.contain,
                  ),
                ),
                SizedBox(width: 10),
                Expanded(
                  child: Text(
                    titre,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.left,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          )),
    );
  }

  Widget buildPageView() {
    return SizedBox(
      // height:MediaQuery.of(context).size.height,
      height: MediaQuery.of(context).size.height * 0.90,
      child: PageView(
        children: [
          const AcceuilAdmin(),
          MyProductScreen(),
          Panier(),
          const ProfilA()
        ],
      ),
    );
  }
}
