import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:koumi/constants.dart';
import 'package:koumi/models/Acteur.dart';
import 'package:koumi/models/Monnaie.dart';
import 'package:koumi/models/Niveau3Pays.dart';
import 'package:koumi/models/TypeVoiture.dart';
import 'package:koumi/providers/ActeurProvider.dart';
import 'package:koumi/service/VehiculeService.dart';
import 'package:koumi/widgets/LoadingOverlay.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:pattern_formatter/pattern_formatter.dart';

class NextAddVehiculeActeur extends StatefulWidget {
  final TypeVoiture typeVoiture;
  final String nomV;
  final String localite;
  final String description;
  final String nbKilo;
  final String capacite;

  const NextAddVehiculeActeur({
    super.key,
    required this.typeVoiture,
    required this.nomV,
    required this.localite,
    required this.description,
    required this.nbKilo,
    required this.capacite,
  });

  @override
  State<NextAddVehiculeActeur> createState() => _NextAddVehiculeActeurState();
}

const d_colorGreen = Color.fromRGBO(43, 103, 6, 1);
const d_colorOr = Color.fromRGBO(255, 138, 0, 1);

class _NextAddVehiculeActeurState extends State<NextAddVehiculeActeur> {
  TextEditingController _etatController = TextEditingController();
  TextEditingController _prixController = TextEditingController();
  TextEditingController newDestinationController = TextEditingController();
  TextEditingController newPrixController = TextEditingController();
  List<Widget> destinationPrixFields = [];
  List<TextEditingController> destinationControllers = [];
  List<TextEditingController> prixControllers = [];
  String? monnaieValue;
  late Future _monnaieList;
  late Monnaie monnaie = Monnaie();
  late Map<String, int> prixParDestinations;
  final formkey = GlobalKey<FormState>();
  String? imageSrc;
  File? photo;
  late Acteur acteur;
  bool _isLoading = false;
  late Future _niveau3List;
  String? n3Value;
  // List<String>? n3Value = [];
  String niveau3 = '';
  List<String> selectedDestinations = [];
  bool isLoadingLibelle = true;
  String? libelleNiveau3Pays;

// Déclarer une liste pour stocker les valeurs sélectionnées pour chaque liste de destinations
  List<String?> selectedDestinationsList = [];

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

  void _handleButtonPress() async {
    // Afficher l'indicateur de chargement
    setState(() {
      _isLoading = true;
    });
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
    super.initState();
    acteur = Provider.of<ActeurProvider>(context, listen: false).acteur!;
    prixParDestinations = {};
    _monnaieList = http.get(Uri.parse('$apiOnlineUrl/Monnaie/getAllMonnaie'));
    _niveau3List = http.get(Uri.parse(
        '$apiOnlineUrl/nivveau3Pays/listeNiveau3PaysByNomPays/${acteur.niveau3PaysActeur}'));
    fetchLibelleNiveau3Pays();
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

  @override
  Widget build(BuildContext context) {
    return LoadingOverlay(
      isLoading: _isLoading,
      child: Scaffold(
        backgroundColor: const Color.fromARGB(255, 250, 250, 250),
        appBar: AppBar(
          centerTitle: true,
          toolbarHeight: 100,
          leading: IconButton(
              onPressed: () {
                Navigator.pop(context, true);
              },
              icon: const Icon(Icons.arrow_back_ios, color: d_colorGreen)),
          title: Text(
            'Etape 2',
            style: const TextStyle(
                color: d_colorGreen, fontWeight: FontWeight.bold, fontSize: 20),
          ),
        ),
        body: SingleChildScrollView(
          child: Column(
            children: [
              Form(
                  key: formkey,
                  child: Column(
                    children: [
                      SizedBox(
                        height: 10,
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: 22,
                        ),
                        child: Align(
                          alignment: Alignment.topLeft,
                          child: Text(
                            "Etat du véhicule",
                            style:
                                TextStyle(color: (Colors.black), fontSize: 18),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            vertical: 10, horizontal: 20),
                        child: TextFormField(
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return "Veuillez remplir les champs";
                            }
                            return null;
                          },
                          controller: _etatController,
                          decoration: InputDecoration(
                            hintText: "Etat du véhicule",
                            contentPadding: const EdgeInsets.symmetric(
                                vertical: 10, horizontal: 20),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: 22,
                        ),
                        child: Align(
                          alignment: Alignment.topLeft,
                          child: Text(
                            "Chosir la monnaie",
                            style:
                                TextStyle(color: (Colors.black), fontSize: 18),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            vertical: 10, horizontal: 20),
                        child: FutureBuilder(
                          future: _monnaieList,
                          builder: (_, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return DropdownButtonFormField(
                                items: [],
                                onChanged: null,
                                decoration: InputDecoration(
                                  labelText: 'Chargement...',
                                  contentPadding: const EdgeInsets.symmetric(
                                      vertical: 10, horizontal: 20),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                              );
                            }

                            if (snapshot.hasData) {
                              dynamic jsonString =
                                  utf8.decode(snapshot.data.bodyBytes);
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
                                      contentPadding:
                                          const EdgeInsets.symmetric(
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
                                          child: Text(e.libelle!),
                                        ),
                                      )
                                      .toList(),
                                  value: monnaieValue,
                                  onChanged: (newValue) {
                                    setState(() {
                                      monnaieValue = newValue;
                                      if (newValue != null) {
                                        monnaie = speList.firstWhere(
                                          (element) =>
                                              element.idMonnaie == newValue,
                                        );
                                      }
                                    });
                                  },
                                  decoration: InputDecoration(
                                    labelText: 'Sélectionner la monnaie',
                                    contentPadding: const EdgeInsets.symmetric(
                                        vertical: 10, horizontal: 20),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                );
                              } else {
                                // Handle case when response data is not a list
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
                            } else {
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
                          },
                        ),
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
                                  "Destination et prix",
                                  style: TextStyle(
                                      color: Colors.black, fontSize: 18),
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
                                                  contentPadding:
                                                      const EdgeInsets
                                                          .symmetric(
                                                    vertical: 10,
                                                    horizontal: 20,
                                                  ),
                                                  border: OutlineInputBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            8),
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
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                      fontSize: 15),
                                                  contentPadding:
                                                      const EdgeInsets
                                                          .symmetric(
                                                    vertical: 10,
                                                    horizontal: 20,
                                                  ),
                                                  border: OutlineInputBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            8),
                                                  ),
                                                ),
                                              );
                                            }
                                            if (snapshot.hasData) {
                                              // dynamic responseData = json
                                              //     .decode(snapshot.data.body);
                                              dynamic jsonString = utf8.decode(
                                                  snapshot.data.bodyBytes);
                                              dynamic responseData =
                                                  json.decode(jsonString);

                                              if (responseData is List) {
                                                final reponse = responseData;
                                                final niveau3List = reponse
                                                    .map((e) =>
                                                        Niveau3Pays.fromMap(e))
                                                    .where((con) =>
                                                        con.statutN3 == true)
                                                    .toList();

                                                if (niveau3List.isEmpty) {
                                                  return DropdownButtonFormField(
                                                    items: [],
                                                    onChanged: null,
                                                    decoration: InputDecoration(
                                                      labelText: 'Destination',
                                                      labelStyle: TextStyle(
                                                          overflow: TextOverflow
                                                              .ellipsis,
                                                          fontSize: 15),
                                                      contentPadding:
                                                          const EdgeInsets
                                                              .symmetric(
                                                        vertical: 10,
                                                        horizontal: 20,
                                                      ),
                                                      border:
                                                          OutlineInputBorder(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(8),
                                                      ),
                                                    ),
                                                  );
                                                }

                                                return DropdownButtonFormField<
                                                    String>(
                                                  isExpanded: true,
                                                  items: niveau3List
                                                      .map((e) =>
                                                          DropdownMenuItem(
                                                            value:
                                                                e.idNiveau3Pays,
                                                            child: Text(e.nomN3,
                                                                overflow:
                                                                    TextOverflow
                                                                        .ellipsis,
                                                                style: TextStyle(
                                                                    overflow:
                                                                        TextOverflow
                                                                            .ellipsis,
                                                                    fontSize:
                                                                        14)), // réduire la taille du texte
                                                          ))
                                                      .toList(),
                                                  value:
                                                      selectedDestinationsList[
                                                          index],
                                                  onChanged: (newValue) {
                                                    setState(() {
                                                      selectedDestinationsList[
                                                          index] = newValue;
                                                      String
                                                          selectedDestinationName =
                                                          niveau3List
                                                              .firstWhere(
                                                                  (element) =>
                                                                      element
                                                                          .idNiveau3Pays ==
                                                                      newValue)
                                                              .nomN3;
                                                      selectedDestinations.add(
                                                          selectedDestinationName);
                                                      print(
                                                          "niveau 3 : $selectedDestinationsList");
                                                      print(
                                                          "niveau 3 nom  : $selectedDestinations");
                                                    });
                                                  },
                                                  decoration: InputDecoration(
                                                    labelText: 'Destination',
                                                    labelStyle: TextStyle(
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                        fontSize: 15),
                                                    contentPadding: const EdgeInsets
                                                        .symmetric(
                                                        horizontal:
                                                            6), // réduire le padding
                                                    border: OutlineInputBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              8),
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
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                        fontSize: 15),
                                                    contentPadding:
                                                        const EdgeInsets
                                                            .symmetric(
                                                      horizontal: 20,
                                                    ),
                                                    border: OutlineInputBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              8),
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
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                    fontSize: 15),
                                                contentPadding:
                                                    const EdgeInsets.symmetric(
                                                  horizontal: 20,
                                                ),
                                                border: OutlineInputBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(8),
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
                                          inputFormatters: [
                                            ThousandsFormatter(),
                                          ],
                                          decoration: InputDecoration(
                                            hintText: "Prix",
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
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Column(
                        children: destinationPrixFields,
                      ),
                      SizedBox(
                        child: Padding(
                          padding: const EdgeInsets.only(left: 10.0),
                          child: photo != null
                              ? GestureDetector(
                                  onTap: _showImageSourceDialog,
                                  child: Image.file(
                                    photo!,
                                    fit: BoxFit.fitWidth,
                                    height: 150,
                                    width: 300,
                                  ),
                                )
                              : SizedBox(
                                  child: IconButton(
                                    onPressed: _showImageSourceDialog,
                                    icon: const Icon(
                                      Icons.add_a_photo_rounded,
                                      size: 60,
                                    ),
                                  ),
                                ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton(
                          onPressed: () async {
                            final String nom = widget.nomV;
                            final String description = widget.description;
                            // final String prix = _prixController.text;
                            final String capacite = widget.capacite;
                            final String etat = _etatController.text;
                            final String localite = widget.localite;
                            final String nbKilometrage = widget.nbKilo;
                            final TypeVoiture type = widget.typeVoiture;

                            setState(() {
                              for (int i = 0;
                                  i < selectedDestinationsList.length;
                                  i++) {
                                String destination = selectedDestinations[i];
                                String formattedMontant =
                                    prixControllers[i].text.replaceAll(',', '');
                                int prix = int.tryParse(formattedMontant) ?? 0;
                                print("prix : $prix");
                                // Ajouter la destination et le prix à la nouvelle map
                                if (destination.isNotEmpty && prix > 0) {
                                  prixParDestinations
                                      .addAll({destination: prix});
                                }
                              }
                            });

                            if (formkey.currentState!.validate()) {
                              try {
                                setState(() {
                                  _isLoading = true;
                                });
                                if (photo != null) {
                                  await VehiculeService()
                                      .addVehicule(
                                          nomVehicule: nom,
                                          capaciteVehicule: capacite,
                                          localisation: localite,
                                          description: description,
                                          nbKilometrage: nbKilometrage,
                                          prixParDestination:
                                              prixParDestinations,
                                          photoVehicule: photo,
                                          etatVehicule: etat,
                                          typeVoiture: type,
                                          acteur: acteur,
                                          monnaie: monnaie)
                                      .then((value) => {
                                            Provider.of<VehiculeService>(
                                                    context,
                                                    listen: false)
                                                .applyChange(),
                                            _etatController.clear(),
                                            setState(() {
                                              _isLoading = false;
                                            }),
                                            Navigator.pop(context, true),
                                           
                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(
                                              const SnackBar(
                                                content: Row(
                                                  children: [
                                                    Text(
                                                      "vehicule ajouté avec succèss",
                                                      style: TextStyle(
                                                          overflow: TextOverflow
                                                              .ellipsis),
                                                    ),
                                                  ],
                                                ),
                                                duration: Duration(seconds: 5),
                                              ),
                                            )
                                          })
                                      .catchError((onError) => {
                                            print(onError.toString()),
                                            setState(() {
                                              _isLoading = false;
                                            }),
                                          });
                                } else {
                                  await VehiculeService()
                                      .addVehicule(
                                          nomVehicule: nom,
                                          capaciteVehicule: capacite,
                                          prixParDestination:
                                              prixParDestinations,
                                          description: description,
                                          nbKilometrage: nbKilometrage,
                                          localisation: localite,
                                          etatVehicule: etat,
                                          typeVoiture: type,
                                          acteur: acteur,
                                          monnaie: monnaie)
                                      .then((value) => {
                                            Provider.of<VehiculeService>(
                                                    context,
                                                    listen: false)
                                                .applyChange(),
                                            // Get.to(VehiculeActeur()),
                                            _etatController.clear(),
                                            setState(() {
                                              _isLoading = false;
                                              // typeVoiture == null;
                                            }),
                                            Navigator.pop(context, true),
                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(
                                              const SnackBar(
                                                content: Row(
                                                  children: [
                                                    Text(
                                                      "vehicule ajouté avec succèss",
                                                      style: TextStyle(
                                                          overflow: TextOverflow
                                                              .ellipsis),
                                                    ),
                                                  ],
                                                ),
                                                duration: Duration(seconds: 5),
                                              ),
                                            )
                                          })
                                      .catchError((onError) => {
                                            print(onError.toString()),
                                            setState(() {
                                              _isLoading = false;
                                            }),
                                          });
                                }
                              } catch (e) {
                                setState(() {
                                  _isLoading = false;
                                });
                                final String errorMessage = e.toString();
                                print(errorMessage);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Row(
                                      children: [
                                        Text(
                                          "Une erreur s'est produit",
                                          style: TextStyle(
                                              overflow: TextOverflow.ellipsis),
                                        ),
                                      ],
                                    ),
                                    duration: Duration(seconds: 5),
                                  ),
                                );
                              }
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.orange, // Orange color code
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                            minimumSize: const Size(290, 45),
                          ),
                          child: Text(
                            "Ajouter",
                            style: TextStyle(
                              fontSize: 20,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ))
                    ],
                  ))
            ],
          ),
        ),
      ),
    );
  }
}
