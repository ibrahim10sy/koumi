import 'dart:async';
import 'dart:convert';
import 'package:koumi/providers/CountryProvider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart' hide carousel_slider;
import 'package:carousel_slider/carousel_slider.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:koumi/Admin/DetailAlerte.dart';
import 'package:koumi/constants.dart';
import 'package:koumi/models/Acteur.dart';
import 'package:koumi/models/Alertes.dart';
import 'package:koumi/widgets/DetectorPays.dart';
import 'package:shimmer/shimmer.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';

List<Map<String, String>> imageList = [
  {"image_path": 'assets/images/koumi1.png'},
  {"image_path": 'assets/images/koumi2.jpg'},
];

const d_colorGreen = Color.fromRGBO(43, 103, 6, 1);
const d_colorOr = Color.fromRGBO(255, 138, 0, 1);

class Carrousels extends StatelessWidget {
  Carrousels({super.key});

  final CarouselSliderController carouselController =
      CarouselSliderController();
  int currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          InkWell(
            onTap: () {
              print(currentIndex);
            },
            child: Padding(
              padding: const EdgeInsets.all(10.0),
              child: Container(
                width: MediaQuery.of(context).size.width * 1,
                // height: 200,
                decoration: const BoxDecoration(
                  color: Color.fromARGB(255, 228, 225, 225),
                  borderRadius: BorderRadius.all(Radius.circular(20)),
                ),
                child: CarouselSlider(
                  items: imageList
                      .map((item) => Image.asset(
                            item['image_path']!,
                            fit: BoxFit.cover,
                            width: double.infinity,
                          ))
                      .toList(),
                  carouselController: carouselController,
                  options: CarouselOptions(
                    scrollPhysics: const BouncingScrollPhysics(),
                    autoPlay: true,
                    aspectRatio: 2,
                    viewportFraction: 1,
                    onPageChanged: (index, reason) {
                      currentIndex = index;
                    },
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 10,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: imageList.asMap().entries.map((entry) {
                return GestureDetector(
                  onTap: () => carouselController.animateToPage(entry.key),
                  child: Container(
                    width: currentIndex == entry.key ? 17 : 7,
                    height: 7.0,
                    margin: const EdgeInsets.symmetric(horizontal: 3.0),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color:
                          currentIndex == entry.key ? d_colorOr : d_colorGreen,
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}

class Carrousel extends StatefulWidget {
 
  Carrousel({super.key});

  @override
  _CarrouselState createState() => _CarrouselState();
}

class _CarrouselState extends State<Carrousel> {
  final CarouselSliderController carouselController =
      CarouselSliderController();
  int currentIndex = 0;
  List<Alertes> alertesList = [];
  late Acteur acteur = Acteur();
  String? email = "";
  final String baseUrl = '$apiOnlineUrl/alertes';

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
    super.initState();
    _checkFirstLaunch();
  }

  @override
  void dispose() {
    streamSubscription?.cancel();
    super.dispose();
  }

  Future<void> _checkFirstLaunch() async {
    final prefs = await SharedPreferences.getInstance();
    bool isFirstLaunchGPS = prefs.getBool('isFirstLaunchGPS') ?? true;

    if (isFirstLaunchGPS) {
      await requestUserConsent();

      // Marquer que l'application a été lancée
      await prefs.setBool('isFirstLaunchGPS', false);
    } else {
      requestLocationPermission();
    }
  }

  Future<void> requestUserConsent() async {
    final consent = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          title: Row(
            children: [
              Icon(
                Icons.location_on_outlined,
                color: d_colorOr,
              ),
              SizedBox(width: 10),
              Text("Autorisation de localisation",
                  maxLines: 2,
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                      overflow: TextOverflow.ellipsis)),
            ],
          ),
          content: const Text(
              'Cette application utilise votre position pour vous offrir des services personnalisés, tels que l\'affichage des produits en fonction de votre localisation et le suivi de vos trajets. Acceptez-vous de partager votre position ?'
              ,textAlign: TextAlign.justify,
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w400),
              ),
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
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setBool(
          'isConsentGiven', true); // Sauvegarder le consentement
      await requestLocationPermission();
    } else {
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
            'Le service de localisation est désactivé. Pour l\'activer Veuillez vous rendre dans les paramètres ',
        onConfirm: () async {
          await Geolocator.openLocationSettings();
        },
      );
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
              'Les permissions de localisation ont été refusées. Vous pouvez les activer dans les paramètres de l\'application.',
          onConfirm: () async {
            await Geolocator.openAppSettings();
          },
        );
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      debugPrint('Location desactivé');
      return;
    }

    // Si tout est en ordre, commencez à écouter les positions
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
              fetchAlertes(detectedCountry!).then((alerts) {
                if (mounted) {
                  setState(() {
                    alertesList = alerts;
                    isLoading = false;
                  });
                }
              });
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
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Paramètres'),
              onPressed: () {
                Navigator.of(context).pop();
                onConfirm();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> resetConsent() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('isConsentGiven');
  }

  bool isLoading = true;

  Future<List<Alertes>> fetchAlertes(String pays) async {
    int page = 0;
    int size = 3;
    try {
      final response = await http.get(Uri.parse(
          '$baseUrl/getAlertesByPays?pays=$pays&page=$page&size=$size'));
      debugPrint(
          '$baseUrl/getAlertesByPays?pays=$pays&page=$page&size=$size && Pays alerte : $pays');

      if (response.statusCode == 200 ||
          response.statusCode == 201 ||
          response.statusCode == 202) {
        String contentType = response.headers['content-type'] ?? '';
        if (contentType.contains('application/json')) {
          String jsonString = utf8.decode(response.bodyBytes);
          Map<String, dynamic> body = jsonDecode(jsonString);
          List<dynamic> alertes = body['content'];
          return alertes.map((e) => Alertes.fromMap(e)).toList();
        } else {
          print('La réponse n\'est pas au format JSON : $contentType');
          print('Contenu de la réponse : ${response.body}');
          return alertesList = [];
        }
      } else {
        print(
            'Échec du chargement des alertes on line avec le code d\'état : ${response.statusCode}');
        print('Contenu de la réponse : ${response.body}');
        return alertesList = [];
      }
    } catch (e) {
      print('Erreur lors de la requête : $e');
    }
    return alertesList = [];
  }

  List<Widget> getImageSliders(
      List<Alertes> alertesList, List<Map<String, String>> imageList) {
    if (alertesList.isEmpty) {
      return imageList
          .asMap()
          .entries
          .map((entry) =>
              buildImageSlider(entry.value['image_path']!, '', entry.key, []))
          .toList();
    } else {
      return alertesList
          .asMap()
          .entries
          .map((entry) => buildImageSlider(
              entry.value.photoAlerte!.isNotEmpty ||
                      entry.value.photoAlerte != null
                  ? "$baseUrl/${entry.value.idAlerte}/image"
                  : "assets/images/alert_default.jpg",
              entry.value.titreAlerte ?? '',
              entry.key,
              alertesList))
          .toList();
    }
  }

  Widget buildImageSlider(
      String imagePath, String text, int index, List<Alertes> alertesList) {
    return GestureDetector(
      onTap: () {
        Get.to(() => DetailAlerte(alertes: alertesList[index]),
            transition: Transition.leftToRightWithFade,
            duration: Duration(milliseconds: 500));
      },
      child: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12.0), // Bordure arrondie
            ),
            child: ClipRRect(
                borderRadius: BorderRadius.circular(
                    20.0), // Bordure arrondie pour les coins des images
                child: alertesList[index].photoAlerte!.isNotEmpty &&
                        alertesList[index].photoAlerte != null
                    ? CachedNetworkImage(
                        imageUrl: imagePath,
                        placeholder: (context, url) =>
                            const Center(child: CircularProgressIndicator()),
                        errorWidget: (context, url, error) => Image.asset(
                          'assets/images/alert_default.jpg',
                          fit: BoxFit.cover,
                        ),
                        fit: BoxFit.cover,
                        width: double.infinity,
                      )
                    : Image.asset(
                        "assets/images/alert_default.jpg",
                        width: double.infinity,
                      )),
          ),
          Positioned(
            bottom: 20,
            left: 20,
            child: Container(
              padding: const EdgeInsets.all(8.0),
              color: Colors.black54,
              child: Text(
                text,
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 17,
                    overflow: TextOverflow.ellipsis,
                    fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ? Center(child: buildShimmerImageSlider())
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: alertesList.isEmpty
          ? Carrousels()
          : isLoading
              ? Center(child: buildShimmerImageSlider())
              : Stack(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Container(
                        width: MediaQuery.of(context).size.width,
                        decoration: const BoxDecoration(
                          color: Color.fromARGB(255, 228, 225, 225),
                          borderRadius: BorderRadius.all(Radius.circular(20)),
                        ),
                        child: CarouselSlider(
                          items: getImageSliders(alertesList, imageList),
                          carouselController: carouselController,
                          options: CarouselOptions(
                            scrollPhysics: const BouncingScrollPhysics(),
                            autoPlay: true,
                            aspectRatio: 2,
                            viewportFraction: 1,
                            onPageChanged: (index, reason) {
                              if (mounted) {
                                setState(() {
                                  currentIndex = index;
                                });
                              }
                            },
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 10,
                      left: 0,
                      right: 0,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children:
                            (alertesList.isEmpty ? imageList : alertesList)
                                .asMap()
                                .entries
                                .map((entry) {
                          return GestureDetector(
                            // onTap: () =>
                            //     carouselController.animateToPage(entry.key),
                            child: Container(
                              width: currentIndex == entry.key ? 17 : 7,
                              height: 7.0,
                              margin:
                                  const EdgeInsets.symmetric(horizontal: 3.0),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                color: currentIndex == entry.key
                                    ? d_colorOr
                                    : d_colorGreen,
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ],
                ),
    );
  }

// Shimmer
  Widget buildShimmerImageSlider() {
    return Stack(
      children: [
        // Placeholder pour l'image
        Shimmer.fromColors(
          highlightColor: kBackgroundColor,
          baseColor:
              Colors.grey[300]!, // Utilisez une couleur grise plus claire
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Container(
              width: MediaQuery.of(context).size.width,
              decoration: const BoxDecoration(
                color: Color.fromARGB(255, 228, 225, 225),
                borderRadius: BorderRadius.all(Radius.circular(20)),
              ),
              height: 200, // Ajustez la hauteur en fonction de vos besoins
            ),
          ),
        ),
        // Placeholder pour le texte
      ],
    );
  }
}
