import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:koumi/constants.dart';
import 'package:koumi/models/Acteur.dart';
import 'package:koumi/models/Device.dart';
import 'package:koumi/models/Monnaie.dart';
import 'package:koumi/models/Niveau3Pays.dart';
import 'package:koumi/models/TypeActeur.dart';
import 'package:koumi/models/TypeVoiture.dart';
import 'package:koumi/models/Vehicule.dart';
import 'package:koumi/providers/ActeurProvider.dart';
import 'package:koumi/service/DeviceService.dart';
import 'package:koumi/service/VehiculeService.dart';
import 'package:koumi/widgets/LoadingOverlay.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:readmore/readmore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

class DetailTransport extends StatefulWidget {
  final Vehicule vehicule;
  const DetailTransport({super.key, required this.vehicule});

  @override
  State<DetailTransport> createState() => _DetailTransportState();
}

const d_colorGreen = Color.fromRGBO(43, 103, 6, 1);
const d_colorOr = Color.fromRGBO(255, 138, 0, 1);

class _DetailTransportState extends State<DetailTransport> {
  late Vehicule vehicules;
  late Acteur acteur = Acteur();
  late List<TypeActeur> typeActeurData = [];
  late String type;
  String? imageSrc;
  File? photo;
  late TypeVoiture typeVoiture;
  late Map<String, int> prixParDestinations;
  String? monnaieValue;
  late Future _monnaieList;
  late Monnaie monnaie = Monnaie();
  // List<ParametreGeneraux> paraList = [];
  // late ParametreGeneraux para = ParametreGeneraux();
  late ValueNotifier<bool> isDialOpenNotifier;
  TextEditingController _prixController = TextEditingController();
  TextEditingController _nomController = TextEditingController();
  TextEditingController _destinationController = TextEditingController();
  TextEditingController _descriptionController = TextEditingController();
  TextEditingController _nbKiloController = TextEditingController();
  TextEditingController _capaciteController = TextEditingController();
  TextEditingController _etatController = TextEditingController();
  TextEditingController _localiteController = TextEditingController();
  List<TextEditingController> _destinationControllers = [];
  List<TextEditingController> _prixControllers = [];
  List<TextEditingController> destinationControllers = [];
  List<TextEditingController> prixControllers = [];
  List<Widget> destinationPrixFields = [];
  bool _isEditing = false;
  bool _isLoading = false;
  bool active = false;
  String? typeValue;
  late Future _niveau3List;
  String? n3Value;
  String niveau3 = '';
  List<String> selectedDestinations = [];
  Map<String, int> newPrixParDestinations = {};
  List<String?> selectedDestinationsList = [];
  late Future<Map<String, Map<String, String>>> rates;

  bool isExist = false;
  String? email = "";
  bool isLoadingLibelle = true;
  String? libelleNiveau3Pays;

  Future<List<Device>> getDeviceListe(String id) async {
    try {
      return await DeviceService().fetchDeviceByIdMonnaie(id);
    } catch (e) {
      print('Failed to fetch devices: $e');
      return [];
    }
  }

  Future<Map<String, Map<String, String>>> fetchConvert(
      Vehicule vehicule) async {
    Monnaie monnaie = vehicule.monnaie!;
    Map<String, Map<String, String>> result = {};

    try {
      List<Device> devices = await getDeviceListe(monnaie.idMonnaie!);

      vehicule.prixParDestination.forEach((destination, prix) {
        Map<String, String> convertedPrices = {};
        for (var device in devices) {
          double convertedAmount = prix * device.taux!;
          String amountSubString = convertedAmount.toStringAsFixed(2);
          print(amountSubString);

          switch (device.nomDevice!.toLowerCase()) {
            case 'dollar':
            case 'euro':
            case 'yuan':
              convertedPrices[device.sigle!] = amountSubString;
              break;
            default:
              print('Aucune devise trouvée pour ${device.nomDevice}');
          }
        }
        result[destination] = convertedPrices;
      });
    } catch (e) {
      print('Error: $e');
    }

    print("Conversion : ${result.toString()}");
    return result;
  }

  void verify() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    email = prefs.getString('whatsAppActeur');
    if (email != null) {
      // Si l'email de l'acteur est présent, exécute checkLoggedIn
      acteur = Provider.of<ActeurProvider>(context, listen: false).acteur!;
      typeActeurData = acteur.typeActeur!;
      type = typeActeurData.map((data) => data.libelle).join(', ');
      setState(() {
        isExist = true;
      });
    } else {
      setState(() {
        isExist = false;
      });
    }
  }

  // Méthode pour ajouter une nouvelle destination et prix
  void addDestinationAndPrix() {
    // Créer un nouveau contrôleur pour chaque champ
    TextEditingController newDestinationController = TextEditingController();
    TextEditingController newPrixController = TextEditingController();

    setState(() {
      // Ajouter les nouveaux contrôleurs aux listes
      destinationControllers.add(newDestinationController);
      prixControllers.add(newPrixController);

      // Ajouter une valeur nulle à la liste des destinations sélectionnées
      selectedDestinationsList.add(null);
    });
  }

  void ajouterPrixDestination() {
    for (int i = 0; i < selectedDestinationsList.length; i++) {
      String destination = selectedDestinations[i];
      int prix = int.tryParse(prixControllers[i].text) ?? 0;

      // Ajouter la destination et le prix à la nouvelle map
      if (destination.isNotEmpty && prix > 0) {
        newPrixParDestinations.addAll({destination: prix});
      }
    }
  }

  Future<String> getLibelleNiveau3PaysByActor(String id) async {
    final response = await http
        .get(Uri.parse('$apiOnlineUrl/acteur/libelleNiveau3Pays/$id'));

    if (response.statusCode == 200) {
      print("libelle : ${response.body}");
      return response
          .body; // Return the body directly since it's a plain string
    } else {
      throw Exception('Failed to load libelle niveau3Pays');
    }
  }

  Future<void> fetchLibelleNiveau3Pays() async {
    try {
      String libelle = await getLibelleNiveau3PaysByActor(acteur.idActeur!);
      setState(() {
        libelleNiveau3Pays = libelle;
        isLoadingLibelle = false;
      });
    } catch (e) {
      setState(() {
        isLoadingLibelle = false;
      });
      print('Error: $e');
    }
  }

  @override
  void initState() {
    verify();

    _niveau3List = http.get(Uri.parse('$apiOnlineUrl/nivveau3Pays/read'));

    vehicules = widget.vehicule;
    rates = fetchConvert(vehicules);
    print("rates ${rates.toString()}");
    typeVoiture = vehicules.typeVoiture;
    prixParDestinations = vehicules.prixParDestination;
    _nomController.text = vehicules.nomVehicule;
    _capaciteController.text = vehicules.capaciteVehicule;
    _etatController.text = vehicules.etatVehicule.toString();
    _localiteController.text = vehicules.localisation;
    _descriptionController.text = vehicules.description!;
    _nbKiloController.text = vehicules.nbKilometrage.toString();
    vehicules.prixParDestination.forEach((destination, prix) {
      TextEditingController destinationController =
          TextEditingController(text: destination);
      TextEditingController prixController =
          TextEditingController(text: prix.toString());

      _destinationControllers.add(destinationController);
      _prixControllers.add(prixController);
    });
    monnaie = vehicules.monnaie!;
    monnaieValue = vehicules.monnaie!.idMonnaie;
    _monnaieList = http.get(Uri.parse('$apiOnlineUrl/Monnaie/getAllMonnaie'));
    isDialOpenNotifier = ValueNotifier<bool>(false);
    fetchLibelleNiveau3Pays();
    super.initState();
  }

  Future<File> saveImagePermanently(String imagePath) async {
    final directory = await getApplicationDocumentsDirectory();
    final name = path.basename(imagePath);
    final image = File('${directory.path}/$name');
    return image;
  }

  Future<void> _pickImage(ImageSource source) async {
    final image = await getImage(source);
    if (image != null) {
      setState(() {
        photo = image;
        imageSrc = image.path;
      });
    }
  }

  Future<File?> getImage(ImageSource source) async {
    final image = await ImagePicker().pickImage(source: source);
    if (image == null) return null;

    return File(image.path);
  }

  Future<void> _showImageSourceDialog() async {
    final BuildContext context = this.context;
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return SizedBox(
          height: 150,
          child: AlertDialog(
            title: const Text('Choisir une source'),
            content: Wrap(
              alignment: WrapAlignment.center,
              children: [
                GestureDetector(
                  onTap: () {
                    Navigator.pop(context); // Fermer le dialogue
                    _pickImage(ImageSource.camera);
                  },
                  child: const Column(
                    children: [
                      Icon(Icons.camera_alt, size: 40),
                      Text('Camera'),
                    ],
                  ),
                ),
                const SizedBox(width: 40),
                GestureDetector(
                  onTap: () {
                    Navigator.pop(context); // Fermer le dialogue
                    _pickImage(ImageSource.gallery);
                  },
                  child: const Column(
                    children: [
                      Icon(Icons.image, size: 40),
                      Text('Galerie photo'),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> updateMethode() async {
    setState(() {
      // Afficher l'indicateur de chargement pendant l'opération
      _isLoading = true;
    });

    try {
      // Récupération des nouvelles valeurs des champs
      final String nom = _nomController.text;
      final String capacite = _capaciteController.text;
      final String etat = _etatController.text;
      final String localite = _localiteController.text;
      final String description = _descriptionController.text;
      final String nbKil = _nbKiloController.text;
      final int? nb = int.tryParse(nbKil);

      setState(() {
        // Parcourir les destinations et les prix modifiés simultanément
        for (int i = 0; i < _destinationControllers.length; i++) {
          String destination = _destinationControllers[i].text;
          int prix = int.tryParse(_prixControllers[i].text) ?? 0;

          // Ajouter la destination et le prix à la nouvelle map
          if (destination.isNotEmpty && prix > 0) {
            newPrixParDestinations[destination] = prix;
          }
        }

        // Parcourir pour ajouter les nouvelles destinations
        for (int i = 0; i < selectedDestinationsList.length; i++) {
          String destination = selectedDestinations[i];
          int prix = int.tryParse(prixControllers[i].text) ?? 0;

          // Ajouter la destination et le prix à la nouvelle map
          if (destination.isNotEmpty && prix > 0) {
            // Si la destination n'existe pas déjà dans la nouvelle map, l'ajouter
            if (!newPrixParDestinations.containsKey(destination)) {
              newPrixParDestinations[destination] = prix;
            } else {
              // Si la destination existe déjà, mettre à jour le prix
              newPrixParDestinations[destination] = prix;
              // Réinitialiser les contrôleurs de destination et de prix
            }
          }
        }
        // Réinitialiser les listes de destinations sélectionnées
        selectedDestinationsList.clear();
        selectedDestinations.clear();
      });

      if (photo != null) {
        await VehiculeService()
            .updateVehicule(
                idVehicule: vehicules.idVehicule,
                nomVehicule: nom,
                capaciteVehicule: capacite,
                prixParDestination: newPrixParDestinations,
                etatVehicule: etat,
                photoVehicule: photo,
                localisation: localite,
                description: description,
                nbKilometrage: nb.toString(),
                typeVoiture: typeVoiture,
                acteur: acteur,
                monnaie: monnaie)
            .then((value) => {
                  setState(() {
                    vehicules = Vehicule(
                      idVehicule: vehicules.idVehicule,
                      nomVehicule: nom,
                      photoVehicule: vehicules.photoVehicule,
                      capaciteVehicule: capacite,
                      prixParDestination: newPrixParDestinations,
                      etatVehicule: etat,
                      codeVehicule: vehicules.codeVehicule,
                      description: vehicules.description,
                      nbKilometrage: nb,
                      localisation: localite,
                      typeVoiture: typeVoiture,
                      acteur: acteur,
                      statutVehicule: vehicules.statutVehicule,
                      monnaie: monnaie,
                    );

                    _isLoading = false;
                  }),
                  Provider.of<VehiculeService>(context, listen: false)
                      .applyChange()
                })
            .catchError((onError) => {print(onError.toString())});
      } else {
        await VehiculeService()
            .updateVehicule(
                idVehicule: vehicules.idVehicule,
                nomVehicule: nom,
                capaciteVehicule: capacite,
                prixParDestination: newPrixParDestinations,
                etatVehicule: etat,
                localisation: localite,
                description: description,
                nbKilometrage: nb.toString(),
                typeVoiture: typeVoiture,
                acteur: acteur,
                monnaie: monnaie)
            .then((value) => {
                  setState(() {
                    vehicules = Vehicule(
                      idVehicule: vehicules.idVehicule,
                      nomVehicule: nom,
                      capaciteVehicule: capacite,
                      prixParDestination: newPrixParDestinations,
                      etatVehicule: etat,
                      photoVehicule: vehicules.photoVehicule,
                      codeVehicule: vehicules.codeVehicule,
                      description: description,
                      nbKilometrage: nb,
                      localisation: localite,
                      typeVoiture: typeVoiture,
                      acteur: acteur,
                      statutVehicule: vehicules.statutVehicule,
                      monnaie: monnaie,
                    );
                    _isLoading = false;
                  }),
                  Provider.of<VehiculeService>(context, listen: false)
                      .applyChange()
                })
            .catchError((onError) => {print(onError.toString())});
      }
    } catch (e) {
      print(e.toString());
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _handleButtonPress() async {
    // Afficher l'indicateur de chargement
    setState(() {
      _isLoading = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return LoadingOverlay(
      isLoading: _isLoading,
      child: Scaffold(
          backgroundColor: const Color.fromARGB(255, 250, 250, 250),
          appBar: AppBar(
              centerTitle: true,
              toolbarHeight: 100,
              leading: _isEditing
                  ? IconButton(
                      onPressed: _showImageSourceDialog,
                      icon: const Icon(
                        Icons.camera_alt,
                        // size: 60,
                      ),
                    )
                  : IconButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      icon:
                          const Icon(Icons.arrow_back_ios, color: d_colorGreen),
                    ),
              title: _isEditing
                  ? Text(
                      'Modification',
                      style: const TextStyle(
                          color: d_colorGreen,
                          fontWeight: FontWeight.bold,
                          fontSize: 20),
                    )
                  : Text(
                      'Transport',
                      style: const TextStyle(
                          color: d_colorGreen,
                          fontWeight: FontWeight.bold,
                          fontSize: 20),
                    ),
              actions: acteur.idActeur == vehicules.acteur.idActeur
                  ? [
                      _isEditing
                          ? IconButton(
                              onPressed: () async {
                                setState(() {
                                  _isEditing = false;
                                  vehicules = widget.vehicule;
                                });
                                updateMethode();
                              },
                              icon: Icon(Icons.check),
                            )
                          : IconButton(
                              onPressed: () async {
                                setState(() {
                                  _isEditing = true;
                                  vehicules = widget.vehicule;
                                });
                              },
                              icon: Icon(Icons.edit),
                            ),
                    ]
                  : null),
          body: SingleChildScrollView(
            padding: EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                photo != null
                    ? Image.file(
                        photo!,
                        width: double.infinity,
                        height: 200,
                        fit: BoxFit.cover,
                      )
                    : vehicules.photoVehicule != null &&
                            !vehicules.photoVehicule!.isEmpty
                        ? Image.network(
                            "https://koumi.ml/api-koumi/vehicule/${vehicules.idVehicule}/image",
                            width: double.infinity,
                            height: 200,
                            fit: BoxFit.cover,
                            errorBuilder: (BuildContext context,
                                Object exception, StackTrace? stackTrace) {
                              return Image.asset(
                                'assets/images/default_image.png',
                                fit: BoxFit.cover,
                              );
                            },
                          )
                        : Image.asset(
                            "assets/images/default_image.png",
                            fit: BoxFit.cover,
                            width: double.infinity,
                            height: 200,
                          ),
                SizedBox(height: 30),
                _isEditing ? _buildEditing() : _buildData(),
              ],
            ),
          ),
          floatingActionButton: acteur.idActeur != vehicules.acteur.idActeur
              ? SpeedDial(
                  // animatedIcon: AnimatedIcons.close_menu,
                  backgroundColor: d_colorGreen,
                  foregroundColor: Colors.white,
                  overlayColor: Colors.black,
                  overlayOpacity: 0.4,
                  spacing: 12,
                  icon: Icons.phone,

                  children: [
                    SpeedDialChild(
                      child: FaIcon(FontAwesomeIcons.whatsapp),
                      label: 'Par wathsApp',
                      labelStyle: TextStyle(
                        color: Colors.black,
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                      ),
                      onTap: () {
                        final String whatsappNumber =
                            vehicules.acteur.whatsAppActeur!;
                        _makePhoneWa(whatsappNumber);
                      },
                    ),
                    SpeedDialChild(
                      child: Icon(Icons.phone),
                      label: 'Par téléphone ',
                      labelStyle: TextStyle(
                        color: Colors.black,
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                      ),
                      onTap: () {
                        final String numberPhone =
                            vehicules.acteur.telephoneActeur!;
                        _makePhoneCall(numberPhone);
                      },
                    )
                  ],
                  // État du Speed Dial (ouvert ou fermé)
                  openCloseDial: isDialOpenNotifier,
                  // Fonction appelée lorsque le bouton principal est pressé
                  onPress: () {
                    isDialOpenNotifier.value = !isDialOpenNotifier
                        .value; // Inverser la valeur du ValueNotifier
                  },
                )
              : Container()),
    );
  }

  Future<void> _makePhoneWa(String whatsappNumber) async {
    final Uri launchUri = Uri(
      scheme: 'https',
      host: 'wa.me',
      path: whatsappNumber,
    );
    print(Uri);
    await launchUrl(launchUri);
  }

  Future<void> _makePhoneCall(String phoneNumber) async {
    final Uri launchUri = Uri(
      scheme: 'tel',
      path: phoneNumber,
    );
    await launchUrl(launchUri);
  }

  Widget _buildEditing() {
    return Column(
      children: [
        _buildEditableDetailItem('Nom du véhicule : ', _nomController),
        _buildEditableDetailItem('Capacité : ', _capaciteController),
        _buildEditableDetailItem('Localisation : ', _localiteController),
        _buildEditableDetailItem('Etat du véhicule : ', _etatController),
        _buildEditableDetailItem('Description : ', _descriptionController),
        _buildEditableDetailItem('Nombre kilometrage : ', _nbKiloController),
        _buildDestinationPriceFields(),
        // SizedBox(
        //   height: 15,
        // ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                "Monnaie",
                style: const TextStyle(
                    color: Colors.black87,
                    fontWeight: FontWeight.w500,
                    fontStyle: FontStyle.italic,
                    overflow: TextOverflow.ellipsis,
                    fontSize: 18),
              ),
            ),
            Expanded(
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                child: FutureBuilder(
                  future: _monnaieList,
                  builder: (_, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return DropdownButtonFormField(
                        items: [],
                        onChanged: null,
                        decoration: InputDecoration(
                          labelText: 'Chargement...',
                        ),
                      );
                    }

                    if (snapshot.hasData) {
                      dynamic jsonString = utf8.decode(snapshot.data.bodyBytes);
                      dynamic responseData = json.decode(jsonString);

                      if (responseData is List) {
                        List<Monnaie> speList = responseData
                            .map((e) => Monnaie.fromMap(e))
                            .toList();

                        if (speList.isEmpty) {
                          return DropdownButtonFormField(
                            items: [],
                            onChanged: null,
                            decoration: InputDecoration(
                              labelText: 'Aucun monnaie trouvé',
                              contentPadding: const EdgeInsets.symmetric(
                                  vertical: 10, horizontal: 20),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          );
                        }

                        return DropdownButtonFormField<String>(
                          isExpanded: true,
                          items: speList
                              .map(
                                (e) => DropdownMenuItem(
                                  value: e.idMonnaie,
                                  child: Text(e.sigle!),
                                ),
                              )
                              .toList(),
                          value: monnaieValue,
                          onChanged: (newValue) {
                            setState(() {
                              monnaieValue = newValue;
                              if (newValue != null) {
                                monnaie = speList.firstWhere(
                                  (element) => element.idMonnaie == newValue,
                                );
                              }
                            });
                          },
                          decoration: InputDecoration(
                              // labelText: 'Sélectionner la monnaie',
                              // contentPadding: const EdgeInsets.symmetric(
                              //     vertical: 10, horizontal: 20),
                              // border: OutlineInputBorder(
                              //   borderRadius: BorderRadius.circular(8),
                              // ),
                              ),
                        );
                      } else {
                        return DropdownButtonFormField(
                          items: [],
                          onChanged: null,
                          decoration: InputDecoration(
                            labelText: 'Aucun monnaie trouvé',
                          ),
                        );
                      }
                    } else {
                      return DropdownButtonFormField(
                        items: [],
                        onChanged: null,
                        decoration: InputDecoration(
                          labelText: 'Aucun monnaie trouvé',
                        ),
                      );
                    }
                  },
                ),
              ),
            ),
          ],
        ),
        SizedBox(
          height: 15,
        ),
        Padding(
          padding: EdgeInsets.symmetric(
            horizontal: 22,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Ajouter prix",
                    style: TextStyle(color: Colors.black, fontSize: 18),
                  ),
                  IconButton(
                    onPressed: () {
                      // Appeler la méthode pour ajouter une destination et un prix
                      addDestinationAndPrix();
                    },
                    icon: Icon(Icons.add),
                  ),
                ],
              ),
              SizedBox(height: 10),
              Column(
                children: destinationPrixFields,
              ),
              Column(
                children: List.generate(
                  destinationControllers.length,
                  (index) => Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      children: [
                        Expanded(
                          child: FutureBuilder(
                            future: _niveau3List,
                            builder: (_, snapshot) {
                              if (snapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return DropdownButtonFormField(
                                  items: [],
                                  onChanged: null,
                                  decoration: InputDecoration(
                                    labelText: 'Chargement...',
                                    contentPadding: const EdgeInsets.symmetric(
                                      vertical: 10,
                                      horizontal: 20,
                                    ),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                );
                              }
                              if (snapshot.hasError) {
                                return DropdownButtonFormField(
                                  items: [],
                                  onChanged: null,
                                  decoration: InputDecoration(
                                    labelText: 'Chargement...',
                                    labelStyle: TextStyle(
                                        overflow: TextOverflow.ellipsis,
                                        fontSize: 15),
                                    contentPadding: const EdgeInsets.symmetric(
                                      vertical: 10,
                                      horizontal: 20,
                                    ),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                );
                              }
                              if (snapshot.hasData) {
                                // dynamic responseData = json
                                //     .decode(snapshot.data.body);
                                dynamic jsonString =
                                    utf8.decode(snapshot.data.bodyBytes);
                                dynamic responseData = json.decode(jsonString);

                                if (responseData is List) {
                                  final reponse = responseData;
                                  final niveau3List = reponse
                                      .map((e) => Niveau3Pays.fromMap(e))
                                      .where((con) => con.statutN3 == true)
                                      .toList();

                                  if (niveau3List.isEmpty) {
                                    return DropdownButtonFormField(
                                      items: [],
                                      onChanged: null,
                                      decoration: InputDecoration(
                                        labelText: 'Destination',
                                        labelStyle: TextStyle(
                                            overflow: TextOverflow.ellipsis,
                                            fontSize: 15),
                                        contentPadding:
                                            const EdgeInsets.symmetric(
                                          vertical: 10,
                                          horizontal: 20,
                                        ),
                                        border: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(8),
                                        ),
                                      ),
                                    );
                                  }

                                  return DropdownButtonFormField<String>(
                                    isExpanded: true,
                                    items: niveau3List
                                        .map((e) => DropdownMenuItem(
                                              value: e.idNiveau3Pays,
                                              child: Text(e.nomN3,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  style: TextStyle(
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                      fontSize:
                                                          14)), // réduire la taille du texte
                                            ))
                                        .toList(),
                                    value: selectedDestinationsList[index],
                                    onChanged: (newValue) {
                                      setState(() {
                                        selectedDestinationsList[index] =
                                            newValue;
                                        String selectedDestinationName =
                                            niveau3List
                                                .firstWhere((element) =>
                                                    element.idNiveau3Pays ==
                                                    newValue)
                                                .nomN3;
                                        selectedDestinations.add(
                                            selectedDestinationName); // Ajouter le nom de la destination à la liste
                                        print(
                                            "niveau 3 : $selectedDestinationsList");
                                        print(
                                            "niveau 3 nom  : $selectedDestinations");
                                      });
                                    },
                                    decoration: InputDecoration(
                                      labelText: 'Destination',
                                      labelStyle: TextStyle(
                                          overflow: TextOverflow.ellipsis,
                                          fontSize: 15),
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                              horizontal:
                                                  6), // réduire le padding
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                    ),
                                  );
                                } else {
                                  return DropdownButtonFormField(
                                    items: [],
                                    onChanged: null,
                                    decoration: InputDecoration(
                                      labelText: 'Destination',
                                      labelStyle: TextStyle(
                                          overflow: TextOverflow.ellipsis,
                                          fontSize: 15),
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                        horizontal: 20,
                                      ),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                    ),
                                  );
                                }
                              }
                              return DropdownButtonFormField(
                                items: [],
                                onChanged: null,
                                decoration: InputDecoration(
                                  labelText: 'Destination',
                                  labelStyle: TextStyle(
                                      overflow: TextOverflow.ellipsis,
                                      fontSize: 15),
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 20,
                                  ),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                        SizedBox(width: 10),
                        Expanded(
                          child: TextFormField(
                            controller: prixControllers[index],
                            keyboardType: TextInputType.number,
                            inputFormatters: <TextInputFormatter>[
                              FilteringTextInputFormatter.digitsOnly,
                            ],
                            decoration: InputDecoration(
                              hintText: "Prix",
                              contentPadding: const EdgeInsets.symmetric(
                                vertical: 10,
                                horizontal: 20,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                ),
              )
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildData() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Container(
            height: 40,
            width: MediaQuery.of(context).size.width,
            decoration: const BoxDecoration(
              color: Colors.orangeAccent,
            ),
            child: Center(
              child: Text(
                vehicules.nomVehicule.toUpperCase(),
                style: const TextStyle(
                    overflow: TextOverflow.ellipsis,
                    fontSize: 20,
                    fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ),
        _buildItem('Nom du véhicule: ', vehicules.nomVehicule),
        _buildItem('Type de véhicule : ', vehicules.typeVoiture.nom!),
        vehicules.typeVoiture.nombreSieges != 0
            ? _buildItem('Nombre de siège : ',
                vehicules.typeVoiture.nombreSieges.toString())
            : Container(),
        _buildItem('Capacité : ', vehicules.capaciteVehicule),
        _buildItem('Localisation : ', vehicules.localisation),
        _buildItem('Nombre de kilometrage : ',
            "${vehicules.nbKilometrage.toString()} Km"),
        _buildItem('Statut: : ',
            '${vehicules.statutVehicule ? 'Disponible' : 'Non disponible'}'),

        _buildPanel(),
        SizedBox(height: 10),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
          child: Container(
            height: 40,
            width: MediaQuery.of(context).size.width,
            decoration: const BoxDecoration(
              color: Colors.orangeAccent,
            ),
            child: Center(
              child: Text(
                "Description",
                style: const TextStyle(
                    overflow: TextOverflow.ellipsis,
                    fontSize: 20,
                    fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ),
        _buildDescription('Description : ', vehicules.description!),

        acteur.idActeur != vehicules.acteur.idActeur
            ? Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: Container(
                      height: 40,
                      width: MediaQuery.of(context).size.width,
                      decoration: const BoxDecoration(
                        color: Colors.orangeAccent,
                      ),
                      child: Center(
                        child: Text(
                          "Autre information",
                          style: const TextStyle(
                              overflow: TextOverflow.ellipsis,
                              fontSize: 20,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ),
                  _buildItem('Propriètaire : ', vehicules.acteur.nomActeur!),
                  _buildItem('Adresse : ', vehicules.acteur.adresseActeur!),
                  _buildItem('Pays : ', vehicules.acteur.niveau3PaysActeur!),
                ],
              )
            : Container(),
        // _buildItem('Description : ', vehicules.description!),
      ],
    );
  }

  Widget _buildDestinationPriceFields() {
    List<Widget> fields = [];

    for (int i = 0; i < _destinationControllers.length; i++) {
      fields.add(
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: _destinationControllers[i],
                decoration: InputDecoration(
                  hintText: 'Destination',
                ),
              ),
            ),
            SizedBox(width: 10),
            Expanded(
              child: TextFormField(
                controller: _prixControllers[i],
                keyboardType: TextInputType.number,
                inputFormatters: <TextInputFormatter>[
                  FilteringTextInputFormatter.digitsOnly,
                ],
                decoration: InputDecoration(
                  hintText: 'Prix',
                ),
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      children: fields,
    );
  }

  Widget _buildEditableDetailItem(
      String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  label,
                  style: const TextStyle(
                      color: Colors.black87,
                      fontWeight: FontWeight.w500,
                      fontStyle: FontStyle.italic,
                      overflow: TextOverflow.ellipsis,
                      fontSize: 18),
                ),
              ),
              Expanded(
                child: TextFormField(
                  controller: controller,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 17,
                    color: Colors.black54,
                  ),
                  enabled: _isEditing,
                ),
              ),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildDescription(String title, String value) {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: const TextStyle(
                  color: Colors.black87,
                  fontWeight: FontWeight.w500,
                  fontStyle: FontStyle.italic,
                  overflow: TextOverflow.ellipsis,
                  fontSize: 18),
            ),
            Padding(
              padding: EdgeInsets.all(8),
              child: ReadMoreText(
                  colorClickableText: Colors.orange,
                  trimLines: 2,
                  trimMode: TrimMode.Line,
                  trimCollapsedText: "Lire plus",
                  trimExpandedText: "Lire moins",
                  style: TextStyle(fontSize: 16, fontStyle: FontStyle.italic),
                  value),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildItem(String title, String value) {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                  color: Colors.black87,
                  fontWeight: FontWeight.w500,
                  fontStyle: FontStyle.italic,
                  overflow: TextOverflow.ellipsis,
                  fontSize: 16),
            ),
          ),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.right,
              maxLines: 2,
              // softWrap: true,
              style: const TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.w800,
                overflow: TextOverflow.ellipsis,
                fontSize: 16,
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildPanel() {
    return ExpansionPanelList(
      expansionCallback: (int index, bool isExpanded) {
        setState(() {
          active = !active;
        });
      },
      children: <ExpansionPanel>[
        ExpansionPanel(
          headerBuilder: (context, isExpanded) {
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
              child: Text(
                "Voir les prix par destination",
                textAlign: TextAlign.justify,
                style: const TextStyle(
                  color: Colors.black,
                  fontStyle: FontStyle.italic,
                  fontWeight: FontWeight.w800,
                  overflow: TextOverflow.ellipsis,
                  fontSize: 17,
                ),
              ),
            );
          },
          body: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(5.0),
                child: Column(
                  children: List.generate(vehicules.prixParDestination.length,
                      (index) {
                    String destination =
                        vehicules.prixParDestination.keys.elementAt(index);
                    int prix =
                        vehicules.prixParDestination.values.elementAt(index);
                    return Column(
                      children: [
                        _buildItem(destination,
                            "${prix.toString()} ${vehicules.monnaie!.libelle!}"),
                        FutureBuilder<Map<String, Map<String, String>>>(
                          future: rates,
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return CircularProgressIndicator();
                            } else {
                              Map<String, String>? convertedPrices =
                                  snapshot.data?[destination];
                              if (convertedPrices != null) {
                                return Column(
                                  children:
                                      convertedPrices.entries.map((entry) {
                                    return _buildItem("Prix en ${entry.key}",
                                        "${entry.value}");
                                  }).toList(),
                                );
                              } else {
                                return Text('');
                              }
                            }
                          },
                        )
                      ],
                    );
                  }),
                ),
              ),
            ],
          ),
          isExpanded: active,
          canTapOnHeader: true,
        )
      ],
    );
  }
}
