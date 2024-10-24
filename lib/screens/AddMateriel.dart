import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:koumi/constants.dart';
import 'package:koumi/models/Acteur.dart';
import 'package:koumi/models/CategorieProduit.dart';
import 'package:koumi/models/Filiere.dart';
import 'package:koumi/models/Monnaie.dart';
import 'package:koumi/models/Niveau3Pays.dart';
import 'package:koumi/models/Speculation.dart';
import 'package:koumi/models/TypeMateriel.dart';
import 'package:koumi/providers/ActeurProvider.dart';
import 'package:koumi/service/MaterielService.dart';
import 'package:koumi/widgets/LoadingOverlay.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:pattern_formatter/pattern_formatter.dart';
import 'package:provider/provider.dart';

class AddMateriel extends StatefulWidget {
  bool? isEquipement = false;
  AddMateriel({super.key, this.isEquipement});

  @override
  State<AddMateriel> createState() => _AddMaterielState();
}

const d_colorGreen = Color.fromRGBO(43, 103, 6, 1);
const d_colorOr = Color.fromRGBO(255, 138, 0, 1);

class _AddMaterielState extends State<AddMateriel> {
  TextEditingController _nomController = TextEditingController();
  TextEditingController _descriptionController = TextEditingController();
  TextEditingController _etatController = TextEditingController();
  TextEditingController _prixController = TextEditingController();
  final formkey = GlobalKey<FormState>();
  String? monnaieValue;
  late Future _monnaieList;
  late Monnaie monnaie = Monnaie();
  String? imageSrc;
  File? photo;
  late Acteur acteur;
  bool _isLoading = false;
  late Future _niveau3List;
  String? n3Value;
  String niveau3 = '';
  late Future _typeList;
  String? typeValue;
  late TypeMateriel typeMateriel;
  bool isExist = false;
  String? speValue;
  String? catValue;
  String? filiereValue;
  late Future _speculationList;
  late Future _categorieList;
  late Future _filiereList;
  late Filiere filiere = Filiere();
  late Speculation speculation = Speculation();
  late CategorieProduit categorieProduit = CategorieProduit();
  bool isLoadingLibelle = true;
  String? libelleNiveau3Pays;

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
    // verifyParam();
    acteur = Provider.of<ActeurProvider>(context, listen: false).acteur!;
    fetchLibelleNiveau3Pays();
    _typeList = http.get(Uri.parse('$apiOnlineUrl/TypeMateriel/read'));

    _filiereList = http.get(Uri.parse('$apiOnlineUrl/Filiere/getAllFiliere/'));

    _categorieList = http.get(Uri.parse(
        '$apiOnlineUrl/Categorie/allCategorieByFiliere/${filiere.idFiliere}'));

    _speculationList = http.get(Uri.parse(
        '$apiOnlineUrl/Speculation/getAllSpeculationByCategorie/${categorieProduit.idCategorieProduit}'));

    _niveau3List = http.get(Uri.parse(
        '$apiOnlineUrl/nivveau3Pays/listeNiveau3PaysByNomPays/${acteur.niveau3PaysActeur}'));

    _monnaieList = http.get(Uri.parse('$apiOnlineUrl/Monnaie/getAllMonnaie'));
    //  fetchPaysDataByActor();
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

  final FocusNode _fieldFocusNode = FocusNode();
  // Liste des suggestions
  final List<String> _productNames = [
    'Apple',
    'Banana',
    'Carrot',
    'Dates',
    'Eggplant',
    'Fig',
    'Grapes',
    'Honeydew',
    'Iceberg Lettuce',
    'Jackfruit',
    'Kale',
    'Lemon',
    // Ajoutez d'autres produits ici
  ];
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
            // leading: IconButton(
            //     onPressed: () {
            //       Navigator.of(context).pop();
            //     },
            //     icon: const Icon(Icons.arrow_back_ios, color: d_colorGreen)),
            title: Text(
              "Ajout matériel",
              style: const TextStyle(
                  color: d_colorGreen,
                  fontWeight: FontWeight.bold,
                  fontSize: 20),
            ),
          ),
          body: SingleChildScrollView(
            child: Column(
              children: [
                Form(
                    key: formkey,
                    child: Column(
                      children: [
                        if (widget.isEquipement!)
                          Padding(
                            padding: EdgeInsets.symmetric(
                              horizontal: 22,
                            ),
                            child: Align(
                              alignment: Alignment.topLeft,
                              child: Text(
                                "Chosir une filière",
                                style: TextStyle(
                                    color: (Colors.black), fontSize: 18),
                              ),
                            ),
                          ),
                        if (widget.isEquipement!)
                          Padding(
                            padding: const EdgeInsets.symmetric(
                                vertical: 10, horizontal: 20),
                            child: FutureBuilder(
                              future: _filiereList,
                              builder: (_, snapshot) {
                                if (snapshot.connectionState ==
                                    ConnectionState.waiting) {
                                  return DropdownButtonFormField(
                                    items: [],
                                    onChanged: null,
                                    decoration: InputDecoration(
                                      labelText: 'Chargement...',
                                      contentPadding:
                                          const EdgeInsets.symmetric(
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
                                  dynamic responseData =
                                      json.decode(jsonString);

                                  // Vérifier si responseData est une liste
                                  if (responseData is List) {
                                    final reponse = responseData;
                                    final filiereList = reponse
                                        .map((e) => Filiere.fromMap(e))
                                        .where(
                                            (con) => con.statutFiliere == true)
                                        .toList();

                                    if (filiereList.isEmpty) {
                                      return DropdownButtonFormField(
                                        items: [],
                                        onChanged: null,
                                        decoration: InputDecoration(
                                          labelText: 'Aucun filière trouvé',
                                          contentPadding:
                                              const EdgeInsets.symmetric(
                                                  vertical: 10, horizontal: 20),
                                          border: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(8),
                                          ),
                                        ),
                                      );
                                    }

                                    return DropdownButtonFormField<String>(
                                      isExpanded: true,
                                      items: filiereList
                                          .map(
                                            (e) => DropdownMenuItem(
                                              value: e.idFiliere,
                                              child: Text(e.libelleFiliere!),
                                            ),
                                          )
                                          .toList(),
                                      value: filiereValue,
                                      onChanged: (newValue) {
                                        setState(() {
                                          catValue = null;
                                          filiereValue = newValue;
                                          if (newValue != null) {
                                            filiere = filiereList.firstWhere(
                                              (element) =>
                                                  element.idFiliere == newValue,
                                            );
                                            debugPrint("valeur : $newValue");
                                            _categorieList = http.get(Uri.parse(
                                                '$apiOnlineUrl/Categorie/allCategorieByFiliere/${newValue}'));
                                          }
                                        });
                                      },
                                      decoration: InputDecoration(
                                        labelText: 'Sélectionner un filiere',
                                        contentPadding:
                                            const EdgeInsets.symmetric(
                                                vertical: 10, horizontal: 20),
                                        border: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(8),
                                        ),
                                      ),
                                    );
                                  } else {
                                    return DropdownButtonFormField(
                                      items: [],
                                      onChanged: null,
                                      decoration: InputDecoration(
                                        labelText: 'Aucun filière trouvé',
                                        contentPadding:
                                            const EdgeInsets.symmetric(
                                                vertical: 10, horizontal: 20),
                                        border: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(8),
                                        ),
                                      ),
                                    );
                                  }
                                }
                                return DropdownButtonFormField(
                                  items: [],
                                  onChanged: null,
                                  decoration: InputDecoration(
                                    labelText: 'Aucun filière trouvé',
                                    contentPadding: const EdgeInsets.symmetric(
                                        vertical: 10, horizontal: 20),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        if (widget.isEquipement!)
                          Padding(
                            padding: EdgeInsets.symmetric(
                              horizontal: 22,
                            ),
                            child: Align(
                              alignment: Alignment.topLeft,
                              child: Text(
                                "Chosir une categorie",
                                style: TextStyle(
                                    color: (Colors.black), fontSize: 18),
                              ),
                            ),
                          ),
                        if (widget.isEquipement!)
                          Padding(
                            padding: const EdgeInsets.symmetric(
                                vertical: 10, horizontal: 20),
                            child: FutureBuilder(
                              future: _categorieList,
                              builder: (_, snapshot) {
                                if (snapshot.connectionState ==
                                    ConnectionState.waiting) {
                                  return DropdownButtonFormField(
                                    items: [],
                                    onChanged: null,
                                    decoration: InputDecoration(
                                      labelText: 'Chargement...',
                                      contentPadding:
                                          const EdgeInsets.symmetric(
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
                                  dynamic responseData =
                                      json.decode(jsonString);

                                  // Vérifier si responseData est une liste
                                  if (responseData is List) {
                                    final reponse = responseData;
                                    final catList = reponse
                                        .map((e) => CategorieProduit.fromMap(e))
                                        .where((con) =>
                                            con.statutCategorie == true)
                                        .toList();

                                    if (catList.isEmpty) {
                                      return DropdownButtonFormField(
                                        items: [],
                                        onChanged: null,
                                        decoration: InputDecoration(
                                          labelText: 'Aucune categorie trouvé',
                                          contentPadding:
                                              const EdgeInsets.symmetric(
                                                  vertical: 10, horizontal: 20),
                                          border: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(8),
                                          ),
                                        ),
                                      );
                                    }

                                    return DropdownButtonFormField<String>(
                                      isExpanded: true,
                                      items: catList
                                          .map(
                                            (e) => DropdownMenuItem(
                                              value: e.idCategorieProduit,
                                              child: Text(e.libelleCategorie!),
                                            ),
                                          )
                                          .toList(),
                                      value: catValue,
                                      onChanged: (newValue) {
                                        setState(() {
                                          speValue = null;
                                          catValue = newValue;
                                          if (newValue != null) {
                                            categorieProduit =
                                                catList.firstWhere(
                                              (element) =>
                                                  element.idCategorieProduit ==
                                                  newValue,
                                            );
                                            debugPrint("valeur : $newValue");
                                            _speculationList = http.get(Uri.parse(
                                                '$apiOnlineUrl/Speculation/getAllSpeculationByCategorie/${newValue}'));
                                          }
                                        });
                                      },
                                      decoration: InputDecoration(
                                        labelText: 'Sélectionner une catégorie',
                                        contentPadding:
                                            const EdgeInsets.symmetric(
                                                vertical: 10, horizontal: 20),
                                        border: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(8),
                                        ),
                                      ),
                                    );
                                  } else {
                                    return DropdownButtonFormField(
                                      items: [],
                                      onChanged: null,
                                      decoration: InputDecoration(
                                        labelText: 'Aucune catégorie trouvé',
                                        contentPadding:
                                            const EdgeInsets.symmetric(
                                                vertical: 10, horizontal: 20),
                                        border: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(8),
                                        ),
                                      ),
                                    );
                                  }
                                }
                                return DropdownButtonFormField(
                                  items: [],
                                  onChanged: null,
                                  decoration: InputDecoration(
                                    labelText: 'Aucune catégorie trouvé',
                                    contentPadding: const EdgeInsets.symmetric(
                                        vertical: 10, horizontal: 20),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        if (widget.isEquipement!)
                          Padding(
                            padding: EdgeInsets.symmetric(
                              horizontal: 22,
                            ),
                            child: Align(
                              alignment: Alignment.topLeft,
                              child: Text(
                                "Chosir une speculation",
                                style: TextStyle(
                                    color: (Colors.black), fontSize: 18),
                              ),
                            ),
                          ),
                        if (widget.isEquipement!)
                          Padding(
                            padding: const EdgeInsets.symmetric(
                                vertical: 10, horizontal: 20),
                            child: FutureBuilder(
                                future: _speculationList,
                                builder: (_, snapshot) {
                                  if (snapshot.connectionState ==
                                      ConnectionState.waiting) {
                                    return DropdownButtonFormField(
                                      items: [],
                                      onChanged: null,
                                      decoration: InputDecoration(
                                        labelText: 'Chargement...',
                                        contentPadding:
                                            const EdgeInsets.symmetric(
                                                vertical: 10, horizontal: 20),
                                        border: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(8),
                                        ),
                                      ),
                                    );
                                  }

                                  if (snapshot.hasData) {
                                    dynamic jsonString =
                                        utf8.decode(snapshot.data.bodyBytes);
                                    dynamic responseData =
                                        json.decode(jsonString);

                                    if (responseData is List) {
                                      final reponse = responseData;
                                      final speList = reponse
                                          .map((e) => Speculation.fromMap(e))
                                          .where((cat) =>
                                              cat.statutSpeculation == true)
                                          .toList();

                                      if (speList.isEmpty) {
                                        return DropdownButtonFormField(
                                          items: [],
                                          onChanged: null,
                                          decoration: InputDecoration(
                                            labelText:
                                                'Aucune speculation trouvé',
                                            contentPadding:
                                                const EdgeInsets.symmetric(
                                                    vertical: 10,
                                                    horizontal: 20),
                                            border: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                            ),
                                          ),
                                        );
                                      }

                                      return DropdownButtonFormField<String>(
                                        isExpanded: true,
                                        items: speList
                                            .map(
                                              (e) => DropdownMenuItem(
                                                value: e.idSpeculation,
                                                child: Text(e.nomSpeculation!),
                                              ),
                                            )
                                            .toList(),
                                        value: speValue,
                                        onChanged: (newValue) {
                                          setState(() {
                                            speValue = newValue;
                                            if (newValue != null) {
                                              speculation = speList.firstWhere(
                                                (element) =>
                                                    element.idSpeculation ==
                                                    newValue,
                                              );
                                            }
                                          });
                                        },
                                        decoration: InputDecoration(
                                          labelText:
                                              'Sélectionner une speculation',
                                          contentPadding:
                                              const EdgeInsets.symmetric(
                                                  vertical: 10, horizontal: 20),
                                          border: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(8),
                                          ),
                                        ),
                                      );
                                    } else {
                                      return DropdownButtonFormField(
                                        items: [],
                                        onChanged: null,
                                        decoration: InputDecoration(
                                          labelText:
                                              'Aucune speculation trouvé',
                                          contentPadding:
                                              const EdgeInsets.symmetric(
                                                  vertical: 10, horizontal: 20),
                                          border: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(8),
                                          ),
                                        ),
                                      );
                                    }
                                  }
                                  return DropdownButtonFormField(
                                    items: [],
                                    onChanged: null,
                                    decoration: InputDecoration(
                                      labelText: 'Aucune speculation trouvé',
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                              vertical: 10, horizontal: 20),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                    ),
                                  );
                                }),
                          ),
                        Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: 22,
                          ),
                          child: Align(
                            alignment: Alignment.topLeft,
                            child: Text(
                              "Nom du matériel",
                              style: TextStyle(
                                  color: (Colors.black), fontSize: 18),
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
                            controller: _nomController,
                            maxLines: null,
                            decoration: InputDecoration(
                              hintText: "Nom materiel",
                              contentPadding: const EdgeInsets.symmetric(
                                  vertical: 10, horizontal: 20),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          ),
                        ),
                      //  Padding(
                      //     padding: const EdgeInsets.symmetric(
                      //         vertical: 10, horizontal: 20),
                      //     child: Autocomplete<String>(
                      //       optionsBuilder:
                      //           (TextEditingValue textEditingValue) {
                      //         if (textEditingValue.text.isEmpty) {
                      //           return const Iterable<String>.empty();
                      //         } else {
                      //           return AutoComplet.getTransport()
                      //               .where((String option) {
                      //             return option.toLowerCase().contains(
                      //                 textEditingValue.text.toLowerCase());
                      //           });
                      //         }
                      //       },
                      //       fieldViewBuilder: (BuildContext context,
                      //           TextEditingController textEditingController,
                      //           FocusNode focusNode,
                      //           VoidCallback onFieldSubmitted) {
                      //         return TextField(
                      //           controller: textEditingController,
                      //           focusNode: focusNode,
                      //           maxLines: null,
                      //           decoration: InputDecoration(
                      //             hintText: "Nom",
                      //             contentPadding: const EdgeInsets.symmetric(
                      //                 vertical: 10, horizontal: 20),
                      //             border: OutlineInputBorder(
                      //               borderRadius: BorderRadius.circular(8),
                      //             ),
                      //           ),
                      //         );
                      //       },
                      //       optionsViewBuilder: (BuildContext context,
                      //           AutocompleteOnSelected<String> onSelected,
                      //           Iterable<String> options) {
                      //         return Align(
                      //           alignment: Alignment.topLeft,
                      //           child: Material(
                      //             elevation: 4.0,
                      //             child: Container(
                      //               width:
                      //                   MediaQuery.of(context).size.width * 0.8,
                      //               color: Colors.white,
                      //               child: ListView.separated(
                      //                 padding: EdgeInsets.all(10.0),
                      //                 itemCount: options.length,
                      //                 itemBuilder:
                      //                     (BuildContext context, int index) {
                      //                   final String option =
                      //                       options.elementAt(index);
                      //                   return GestureDetector(
                      //                     onTap: () {
                      //                       onSelected(option);
                      //                     },
                      //                     child: ListTile(
                      //                       title: Text(option),
                      //                     ),
                      //                   );
                      //                 },
                      //                 separatorBuilder:
                      //                     (BuildContext context, int index) {
                      //                   return const Divider();
                      //                 },
                      //               ),
                      //             ),
                      //           ),
                      //         );
                      //       },
                      //       onSelected: (String value) {
                      //         _nomController.text = value;
                      //         print("valeur : ${_nomController.text}");
                      //       },
                      //     ),
                      //   ),

                        // Padding(
                        //   padding: const EdgeInsets.symmetric(
                        //       vertical: 10, horizontal: 20),
                        //   child: Autocomplete<String>(
                        //     optionsBuilder:
                        //         (TextEditingValue textEditingValue) {
                        //       if (textEditingValue.text.isEmpty) {
                        //         return const Iterable<String>.empty();
                        //       }

                        //     },
                        //     onSelected: (String selection) {
                        //       _nomController.text = selection;
                        //       print("nom : ${_nomController.text}");
                        //     },
                        //     fieldViewBuilder: (BuildContext context,
                        //         TextEditingController
                        //             fieldTextEditingController,
                        //         FocusNode fieldFocusNode,
                        //         VoidCallback onFieldSubmitted) {
                        //       return TextFormField(
                        //         controller: _nomController,
                        //         focusNode: fieldFocusNode,
                        //         autofocus: true,
                        //         validator: (value) {
                        //           if (value == null || value.isEmpty) {
                        //             return "Veuillez remplir le champs";
                        //           }
                        //           return null;
                        //         },
                        //         decoration: InputDecoration(
                        //           hintText: "Nom produit",
                        //           contentPadding: const EdgeInsets.symmetric(
                        //               vertical: 10, horizontal: 20),
                        //           border: OutlineInputBorder(
                        //             borderRadius: BorderRadius.circular(8),
                        //           ),
                        //         ),
                        //       );
                        //     },
                        //   ),
                        // ),
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
                              "Description",
                              style: TextStyle(
                                  color: (Colors.black), fontSize: 18),
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
                            controller: _descriptionController,
                            maxLines: null,
                            decoration: InputDecoration(
                              hintText: "Description",
                              contentPadding: const EdgeInsets.symmetric(
                                  vertical: 10, horizontal: 20),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          ),
                        ),
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
                              "Localité",
                              style: TextStyle(
                                  color: (Colors.black), fontSize: 18),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              vertical: 10, horizontal: 20),
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
                                        vertical: 10, horizontal: 20),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                );
                              }

                              if (snapshot.hasData) {
                                // dynamic responseData =
                                //     json.decode(snapshot.data.body);
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
                                        labelText: 'Aucun localité trouvé',
                                        contentPadding:
                                            const EdgeInsets.symmetric(
                                                vertical: 10, horizontal: 20),
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
                                        .map(
                                          (e) => DropdownMenuItem(
                                            value: e.idNiveau3Pays,
                                            child: Text(e.nomN3),
                                          ),
                                        )
                                        .toList(),
                                    value: n3Value,
                                    onChanged: (newValue) {
                                      setState(() {
                                        n3Value = newValue;
                                        if (newValue != null) {
                                          Niveau3Pays selectedNiveau3 =
                                              niveau3List.firstWhere(
                                            (element) =>
                                                element.idNiveau3Pays ==
                                                newValue,
                                          );
                                          niveau3 = selectedNiveau3.nomN3;
                                          print("niveau 3 : $niveau3");
                                        }
                                      });
                                    },
                                    decoration: InputDecoration(
                                      labelText: 'Selectionner une localité',
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                              vertical: 10, horizontal: 20),
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
                                      labelText: 'Aucun localité trouvé',
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                              vertical: 10, horizontal: 20),
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
                                  labelText: 'Aucun localité trouvé',
                                  contentPadding: const EdgeInsets.symmetric(
                                      vertical: 10, horizontal: 20),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
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
                              "Type de matériel",
                              style: TextStyle(
                                  color: (Colors.black), fontSize: 18),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              vertical: 10, horizontal: 20),
                          child: FutureBuilder(
                            future: _typeList,
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
                                // dynamic responseData =
                                //     json.decode(snapshot.data.body);
                                dynamic jsonString =
                                    utf8.decode(snapshot.data.bodyBytes);
                                dynamic responseData = json.decode(jsonString);

                                if (responseData is List) {
                                  final reponse = responseData;
                                  final materielList = reponse
                                      .map((e) => TypeMateriel.fromMap(e))
                                      .where((con) => con.statutType == true)
                                      .toList();

                                  if (materielList.isEmpty) {
                                    return DropdownButtonFormField(
                                      items: [],
                                      onChanged: null,
                                      decoration: InputDecoration(
                                        labelText:
                                            'Aucun type de matériel trouvé',
                                        contentPadding:
                                            const EdgeInsets.symmetric(
                                                vertical: 10, horizontal: 20),
                                        border: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(8),
                                        ),
                                      ),
                                    );
                                  }

                                  return DropdownButtonFormField<String>(
                                    isExpanded: true,
                                    items: materielList
                                        .map(
                                          (e) => DropdownMenuItem(
                                            value: e.idTypeMateriel,
                                            child: Text(e.nom!),
                                          ),
                                        )
                                        .toList(),
                                    value: typeValue,
                                    onChanged: (newValue) {
                                      setState(() {
                                        typeValue = newValue;
                                        if (newValue != null) {
                                          typeMateriel =
                                              materielList.firstWhere(
                                            (element) =>
                                                element.idTypeMateriel ==
                                                newValue,
                                          );
                                        }
                                      });
                                    },
                                    decoration: InputDecoration(
                                      labelText:
                                          'Sélectionner un type de matériel',
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                              vertical: 10, horizontal: 20),
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
                                      labelText:
                                          'Aucun type de matériel trouvé',
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                              vertical: 10, horizontal: 20),
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
                                  labelText: 'Aucun type de matériel trouvé',
                                  contentPadding: const EdgeInsets.symmetric(
                                      vertical: 10, horizontal: 20),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
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
                              "Etat matériel",
                              style: TextStyle(
                                  color: (Colors.black), fontSize: 18),
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
                              hintText: "Etat du matériel",
                              contentPadding: const EdgeInsets.symmetric(
                                  vertical: 10, horizontal: 20),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          ),
                        ),
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
                              "Chosir la monnaie",
                              style: TextStyle(
                                  color: (Colors.black), fontSize: 18),
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
                                          borderRadius:
                                              BorderRadius.circular(8),
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
                                      contentPadding:
                                          const EdgeInsets.symmetric(
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
                                      contentPadding:
                                          const EdgeInsets.symmetric(
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
                              "Prix par heure",
                              style: TextStyle(
                                  color: (Colors.black), fontSize: 18),
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
                            controller: _prixController,
                            keyboardType: TextInputType.number,
                            inputFormatters: [
                              ThousandsFormatter(),
                            ],
                            decoration: InputDecoration(
                              hintText: "Prix par heure",
                              contentPadding: const EdgeInsets.symmetric(
                                  vertical: 10, horizontal: 20),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          ),
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
                                      height: 140,
                                      width: 280,
                                    ),
                                  )
                                : SizedBox(
                                    child: IconButton(
                                      onPressed: _showImageSourceDialog,
                                      icon: const Icon(
                                        Icons.add_a_photo_rounded,
                                        size: 50,
                                      ),
                                    ),
                                  ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        if (widget.isEquipement!)
                          ElevatedButton(
                              onPressed: () async {
                                final String nom = _nomController.text;
                                final String description =
                                    _descriptionController.text;
                                final String etat = _etatController.text;
                                String formattedMontant =
                                    _prixController.text.replaceAll(',', '');
                                final int prixParHeures =
                                    int.tryParse(formattedMontant) ?? 0;
                                print("prix formated $prixParHeures");
                                Speculation? sp = speculation;
                                if (formkey.currentState!.validate()) {
                                  try {
                                    setState(() {
                                      _isLoading = true;
                                    });
                                    if (photo != null) {
                                      await MaterielService()
                                          .addMateriel(
                                              prixParHeure: prixParHeures,
                                              nom: nom,
                                              description: description,
                                              localisation: niveau3,
                                              etatMateriel: etat,
                                              typeMateriel: typeMateriel,
                                              photoMateriel: photo,
                                              acteur: acteur,
                                              monnaie: monnaie,
                                              speculation: sp)
                                          .then((value) => {
                                                Provider.of<MaterielService>(
                                                        context,
                                                        listen: false)
                                                    .applyChange(),
                                                Navigator.pop(context, true),
                                                setState(() {
                                                  _isLoading = false;
                                                  n3Value = null;
                                                  monnaieValue = null;
                                                }),
                                                ScaffoldMessenger.of(context)
                                                    .showSnackBar(
                                                  const SnackBar(
                                                    content: Row(
                                                      children: [
                                                        Text(
                                                          "Matériel ajouté avec succèss",
                                                          style: TextStyle(
                                                              overflow:
                                                                  TextOverflow
                                                                      .ellipsis),
                                                        ),
                                                      ],
                                                    ),
                                                    duration:
                                                        Duration(seconds: 5),
                                                  ),
                                                )
                                              })
                                          .catchError((onError) => {
                                                setState(() {
                                                  _isLoading = false;
                                                }),
                                                ScaffoldMessenger.of(context)
                                                    .showSnackBar(
                                                  const SnackBar(
                                                    content: Row(
                                                      children: [
                                                        Text(
                                                          "Une erreur s'est produite",
                                                          style: TextStyle(
                                                              overflow:
                                                                  TextOverflow
                                                                      .ellipsis),
                                                        ),
                                                      ],
                                                    ),
                                                    duration:
                                                        Duration(seconds: 5),
                                                  ),
                                                ),
                                                _etatController.clear(),
                                                _nomController.clear(),
                                                _descriptionController.clear(),
                                                setState(() {
                                                  _isLoading = false;
                                                  n3Value = null;
                                                }),
                                                Navigator.pop(context, true)
                                              });
                                    } else {
                                      await MaterielService()
                                          .addMateriel(
                                              prixParHeure: prixParHeures,
                                              nom: nom,
                                              description: description,
                                              localisation: niveau3,
                                              etatMateriel: etat,
                                              typeMateriel: typeMateriel,
                                              acteur: acteur,
                                              monnaie: monnaie,
                                              speculation: sp)
                                          .then((value) => {
                                                Provider.of<MaterielService>(
                                                        context,
                                                        listen: false)
                                                    .applyChange(),
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
                                                          "Matériel ajouté avec succèss",
                                                          style: TextStyle(
                                                              overflow:
                                                                  TextOverflow
                                                                      .ellipsis),
                                                        ),
                                                      ],
                                                    ),
                                                    duration:
                                                        Duration(seconds: 5),
                                                  ),
                                                )
                                              })
                                          .catchError((onError) => {
                                                setState(() {
                                                  _isLoading = false;
                                                }),
                                                ScaffoldMessenger.of(context)
                                                    .showSnackBar(
                                                  const SnackBar(
                                                    content: Row(
                                                      children: [
                                                        Text(
                                                          "Une erreur s'est produite",
                                                          style: TextStyle(
                                                              overflow:
                                                                  TextOverflow
                                                                      .ellipsis),
                                                        ),
                                                      ],
                                                    ),
                                                    duration:
                                                        Duration(seconds: 5),
                                                  ),
                                                ),
                                                _etatController.clear(),
                                                _nomController.clear(),
                                                _descriptionController.clear(),
                                                setState(() {
                                                  _isLoading = false;
                                                  n3Value = null;
                                                }),
                                                Navigator.pop(context, true)
                                              });
                                    }
                                  } catch (e) {
                                    print("Error: " + e.toString());
                                    setState(() {
                                      _isLoading = false;
                                    });
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Row(
                                          children: [
                                            Text(
                                              "Une erreur est survenu lors de l'ajout",
                                              style: TextStyle(
                                                  overflow:
                                                      TextOverflow.ellipsis),
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
                                backgroundColor:
                                    Colors.orange, // Orange color code
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
                              )),
                        if (!widget.isEquipement!)
                          ElevatedButton(
                              onPressed: () async {
                                final String nom = _nomController.text;
                                final String description =
                                    _descriptionController.text;
                                final String etat = _etatController.text;
                                String formattedMontant =
                                    _prixController.text.replaceAll(',', '');
                                final int prixParHeures =
                                    int.tryParse(formattedMontant) ?? 0;
                                print("prix formated $prixParHeures");
                                Speculation? sp = speculation;
                                if (formkey.currentState!.validate()) {
                                  try {
                                    setState(() {
                                      _isLoading = true;
                                    });
                                    if (photo != null) {
                                      await MaterielService()
                                          .addMateriel(
                                            prixParHeure: prixParHeures,
                                            nom: nom,
                                            description: description,
                                            localisation: niveau3,
                                            etatMateriel: etat,
                                            typeMateriel: typeMateriel,
                                            photoMateriel: photo,
                                            acteur: acteur,
                                            monnaie: monnaie,
                                          )
                                          .then((value) => {
                                                Provider.of<MaterielService>(
                                                        context,
                                                        listen: false)
                                                    .applyChange(),
                                                setState(() {
                                                  _isLoading = false;
                                                  n3Value = null;
                                                  monnaieValue = null;
                                                }),
                                                Navigator.pop(context, true),
                                                ScaffoldMessenger.of(context)
                                                    .showSnackBar(
                                                  const SnackBar(
                                                    content: Row(
                                                      children: [
                                                        Text(
                                                          "Matériel ajouté avec succèss",
                                                          style: TextStyle(
                                                              overflow:
                                                                  TextOverflow
                                                                      .ellipsis),
                                                        ),
                                                      ],
                                                    ),
                                                    duration:
                                                        Duration(seconds: 5),
                                                  ),
                                                )
                                              })
                                          .catchError((onError) => {
                                                setState(() {
                                                  _isLoading = false;
                                                }),
                                                ScaffoldMessenger.of(context)
                                                    .showSnackBar(
                                                  const SnackBar(
                                                    content: Row(
                                                      children: [
                                                        Text(
                                                          "Une erreur s'est produite",
                                                          style: TextStyle(
                                                              overflow:
                                                                  TextOverflow
                                                                      .ellipsis),
                                                        ),
                                                      ],
                                                    ),
                                                    duration:
                                                        Duration(seconds: 5),
                                                  ),
                                                ),
                                                _etatController.clear(),
                                                _nomController.clear(),
                                                _descriptionController.clear(),
                                                setState(() {
                                                  _isLoading = false;
                                                  n3Value = null;
                                                }),
                                                Navigator.pop(context, true)
                                              });
                                    } else {
                                      await MaterielService()
                                          .addMateriel(
                                            prixParHeure: prixParHeures,
                                            nom: nom,
                                            description: description,
                                            localisation: niveau3,
                                            etatMateriel: etat,
                                            typeMateriel: typeMateriel,
                                            acteur: acteur,
                                            monnaie: monnaie,
                                          )
                                          .then((value) => {
                                                Provider.of<MaterielService>(
                                                        context,
                                                        listen: false)
                                                    .applyChange(),
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
                                                          "Matériel ajouté avec succèss",
                                                          style: TextStyle(
                                                              overflow:
                                                                  TextOverflow
                                                                      .ellipsis),
                                                        ),
                                                      ],
                                                    ),
                                                    duration:
                                                        Duration(seconds: 5),
                                                  ),
                                                )
                                              })
                                          .catchError((onError) => {
                                                setState(() {
                                                  _isLoading = false;
                                                }),
                                                ScaffoldMessenger.of(context)
                                                    .showSnackBar(
                                                  const SnackBar(
                                                    content: Row(
                                                      children: [
                                                        Text(
                                                          "Une erreur s'est produite",
                                                          style: TextStyle(
                                                              overflow:
                                                                  TextOverflow
                                                                      .ellipsis),
                                                        ),
                                                      ],
                                                    ),
                                                    duration:
                                                        Duration(seconds: 5),
                                                  ),
                                                ),
                                                _etatController.clear(),
                                                _nomController.clear(),
                                                _descriptionController.clear(),
                                                setState(() {
                                                  _isLoading = false;
                                                  n3Value = null;
                                                }),
                                                Navigator.pop(context, true)
                                              });
                                    }
                                  } catch (e) {
                                    print("Error: " + e.toString());
                                    setState(() {
                                      _isLoading = false;
                                    });
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Row(
                                          children: [
                                            Text(
                                              "Une erreur est survenu lors de l'ajout",
                                              style: TextStyle(
                                                  overflow:
                                                      TextOverflow.ellipsis),
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
                                backgroundColor:
                                    Colors.orange, // Orange color code
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
        ));
  }

  //  static Future<Iterable<String>> search(String query) async {
  //   if (query == '') {
  //     return const Iterable<String>.empty();
  //   }
  //   return AutoComplet.getAgriculturalInputs().where((String option) {
  //     return option.toLowerCase().contains(query.toLowerCase());
  //   });
  // }
}
