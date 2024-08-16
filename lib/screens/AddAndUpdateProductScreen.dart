import 'dart:convert';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:koumi/constants.dart';
import 'package:koumi/models/Acteur.dart';
import 'package:koumi/models/Filiere.dart';
import 'package:koumi/models/Forme.dart';
import 'package:koumi/models/Monnaie.dart';
import 'package:koumi/models/Niveau3Pays.dart';
import 'package:koumi/models/Stock.dart';
import 'package:koumi/models/TypeActeur.dart';
import 'package:koumi/providers/ActeurProvider.dart';
import 'package:koumi/screens/AddAndUpdateProductEndScreen.dart';
import 'package:koumi/widgets/AutoComptet.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:pattern_formatter/pattern_formatter.dart';
import 'package:provider/provider.dart';

class AddAndUpdateProductScreen extends StatefulWidget {
  bool? isEditable;
  final Stock? stock;
  AddAndUpdateProductScreen({super.key, this.isEditable, this.stock});

  @override
  State<AddAndUpdateProductScreen> createState() =>
      _AddAndUpdateProductScreenState();
}

const d_colorGreen = Color.fromRGBO(43, 103, 6, 1);
const d_colorOr = Color.fromRGBO(255, 138, 0, 1);

class _AddAndUpdateProductScreenState extends State<AddAndUpdateProductScreen> {
  final formkey = GlobalKey<FormState>();
  TextEditingController _prixController = TextEditingController();
  TextEditingController _quantiteController = TextEditingController();
  TextEditingController _nomController = TextEditingController();
  TextEditingController _formController = TextEditingController();
  TextEditingController _origineController = TextEditingController();

  late Acteur acteur;
  late Stock stock = Stock();
  late List<TypeActeur> typeActeurData = [];
  late String type;
  late TextEditingController _searchController;
  List<Filiere> filiereListe = [];
  String? imageSrc;
  File? photo;
  String? formeValue;
  late Future _formeList;
  late Future _niveau3List;
  String? n3Value;
  String niveau3 = '';
  String forme = '';
  bool isLoadingLibelle = true;
  String? libelleNiveau3Pays;
  String? monnaieValue;
  late Future _monnaieList;
  late Monnaie monnaie = Monnaie();

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
  void initState() {
    super.initState();
    acteur = Provider.of<ActeurProvider>(context, listen: false).acteur!;
    // typeActeurData = acteur.typeActeur!;
    // type = typeActeurData.map((data) => data.libelle).join(', ');
    _searchController = TextEditingController();

    if (widget.isEditable! == true) {
      _nomController.text = widget.stock!.nomProduit!;
      _formController.text = widget.stock!.formeProduit!;
      // _origineController.text = widget.stock!.origineProduit!;
      _prixController.text = widget.stock!.prix!.toString();
      _quantiteController.text = widget.stock!.quantiteStock!.toString();
      forme = widget.stock!.formeProduit!;
      niveau3 = widget.stock!.origineProduit!;
      monnaie = widget.stock!.monnaie!;
      monnaieValue = widget.stock!.monnaie!.idMonnaie;
    }
    _monnaieList = http.get(Uri.parse('$apiOnlineUrl/Monnaie/getAllMonnaie'));
    _formeList = http.get(Uri.parse('$apiOnlineUrl/formeproduit/getAllForme/'));
    _niveau3List = http.get(Uri.parse(
        '$apiOnlineUrl/nivveau3Pays/listeNiveau3PaysByNomPays/${acteur.niveau3PaysActeur}'));
    // verifyParam();
    fetchLibelleNiveau3Pays();
    // fetchPaysDataByActor();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
          widget.isEditable! ? 'Modifier de produit' : 'Ajout de produit',
          style: const TextStyle(
              color: d_colorGreen, fontWeight: FontWeight.bold, fontSize: 20),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(children: [
          Column(
            children: [
              SizedBox(
                height: 30,
              ),
              Form(
                  key: formkey,
                  child: Column(
                    children: [
                      Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: 22,
                        ),
                        child: Align(
                          alignment: Alignment.topLeft,
                          child: Text(
                            "Nom produit",
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
                      // Padding(
                      //   padding: const EdgeInsets.symmetric(
                      //       vertical: 10, horizontal: 20),
                      //   child: Autocomplete<String>(
                      //     optionsBuilder: (TextEditingValue textEditingValue) {
                      //       if (textEditingValue.text.isEmpty) {
                      //         return const Iterable<String>.empty();
                      //       }
                      //       return AutoComplet.getSuggestions()
                      //           .where((String option) {
                      //         return option.toLowerCase().contains(
                      //             textEditingValue.text.toLowerCase());
                      //       });
                      //     },
                      //     onSelected: (String selection) {
                      //       _nomController.text = selection;
                      //        print("nom : ${_nomController.text}");
                      //     },
                      //     fieldViewBuilder: (BuildContext context,
                      //         TextEditingController fieldTextEditingController,
                      //         FocusNode fieldFocusNode,
                      //         VoidCallback onFieldSubmitted) {
                      //       return TextFormField(
                      //         controller: fieldTextEditingController,
                      //         focusNode: fieldFocusNode,
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
                      // Padding(
                      //   padding: const EdgeInsets.symmetric(
                      //       vertical: 10, horizontal: 20),
                      //   child: TextFormField(
                      //     validator: (value) {
                      //       if (value == null || value.isEmpty) {
                      //         return "Veuillez remplir le champs";
                      //       }
                      //       return null;
                      //     },
                      //     controller: _nomController,
                      //     decoration: InputDecoration(
                      //       hintText: "Nom produit",
                      //       contentPadding: const EdgeInsets.symmetric(
                      //           vertical: 10, horizontal: 20),
                      //       border: OutlineInputBorder(
                      //         borderRadius: BorderRadius.circular(8),
                      //       ),
                      //     ),
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
                            "Forme produit",
                            style:
                                TextStyle(color: (Colors.black), fontSize: 18),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            vertical: 10, horizontal: 20),
                        child: FutureBuilder(
                          future: _formeList,
                          // future: speculationService.fetchSpeculationByCategorie(categorieProduit.idCategorieProduit!),
                          builder: (_, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return DropdownButtonFormField(
                                items: [],
                                onChanged: null,
                                decoration: InputDecoration(
                                  labelText: 'En cours de chargement ...',
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
                                final reponse = responseData;
                                final formeListe = reponse
                                    .map((e) => Forme.fromMap(e))
                                    .where((element) =>
                                        element.statutForme == true)
                                    .toList();

                                if (formeListe.isEmpty) {
                                  return DropdownButtonFormField(
                                    items: [],
                                    onChanged: null,
                                    decoration: InputDecoration(
                                      labelText: 'Aucune forme trouvé',
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
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return "Veuillez sélectionner une forme";
                                    }
                                    return null;
                                  },
                                  items: formeListe
                                      .map(
                                        (e) => DropdownMenuItem(
                                          value: e.idForme,
                                          child: Text(e.libelleForme!),
                                        ),
                                      )
                                      .toList(),
                                  value: formeValue,
                                  onChanged: (newValue) {
                                    setState(() {
                                      formeValue = newValue;
                                      if (newValue != null) {
                                        forme = formeListe
                                            .firstWhere(
                                                (e) => e.idForme == newValue)
                                            .libelleForme!;
                                      }
                                      debugPrint("fr : ${forme}");
                                    });
                                  },
                                  decoration: InputDecoration(
                                    labelText: widget.isEditable == false
                                        ? 'Sélectionner la forme'
                                        : widget.stock!.formeProduit,
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
                                    labelText: 'Aucune forme de produit trouvé',
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
                                  labelText: 'Aucune forme trouvé',
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
                            "Origine du produit",
                            style:
                                TextStyle(color: (Colors.black), fontSize: 18),
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
                                  labelText: 'En cours de chargement...',
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
                                final reponse = responseData;
                                final niveau3Liste = reponse
                                    .map((e) => Niveau3Pays.fromMap(e))
                                    .where((con) => con.statutN3 == true)
                                    .toList();

                                if (niveau3Liste.isEmpty) {
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

                                return DropdownButtonFormField<String>(
                                  isExpanded: true,
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return "Veuillez sélectionner la localité";
                                    }
                                    return null;
                                  },
                                  items: niveau3Liste
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
                                        niveau3 = niveau3Liste
                                            .firstWhere((e) =>
                                                e.idNiveau3Pays == newValue)
                                            .nomN3;
                                      }
                                      print("niveau 3 origne : ${niveau3}");
                                    });
                                  },
                                  decoration: InputDecoration(
                                    labelText: widget.isEditable == false
                                        ? 'Selectionner une localité'
                                        : widget.stock!.origineProduit,
                                    contentPadding: const EdgeInsets.symmetric(
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
                                    contentPadding: const EdgeInsets.symmetric(
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
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return "Veuillez sélectionner une monnaie";
                                    }
                                    return null;
                                  },
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
                            "Prix du produit",
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
                              return "Veuillez saisir le prix du produit";
                            }
                            return null;
                          },
                          controller: _prixController,
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            ThousandsFormatter(),
                          ],
                          decoration: InputDecoration(
                            hintText: "Prix du produit",
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
                            "Quantite Produit",
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
                              return "Veuillez saisir la quantité du produit";
                            }
                            return null;
                          },
                          controller: _quantiteController,
                          keyboardType: TextInputType.phone,
                          inputFormatters: <TextInputFormatter>[
                            FilteringTextInputFormatter.digitsOnly,
                          ],
                          decoration: InputDecoration(
                            hintText: "Quantite produit",
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
                      SizedBox(
                        child: Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: photo != null
                              ? GestureDetector(
                                  onTap: _showImageSourceDialog,
                                  child: Image.file(
                                    photo!,
                                    fit: BoxFit.fitWidth,
                                    height: 150,
                                    width: 200,
                                  ),
                                )
                              : widget.isEditable == false
                                  ?
                                  // :  widget.stock!.photo == null || widget.stock!.photo!.isEmpty ?
                                  SizedBox(
                                      child: IconButton(
                                        onPressed: _showImageSourceDialog,
                                        icon: const Icon(
                                          Icons.add_a_photo_rounded,
                                          size: 60,
                                        ),
                                      ),
                                    )
                                  : Center(
                                      child: widget.stock!.photo != null &&
                                              !widget.stock!.photo!.isEmpty
                                          ? GestureDetector(
                                              onTap: _showImageSourceDialog,
                                              child: CachedNetworkImage(
                                                height: 120,
                                                width: 150,
                                                imageUrl:
                                                    "https://koumi.ml/api-koumi/Stock/${widget.stock!.idStock}/image",
                                                fit: BoxFit.cover,
                                                placeholder: (context, url) =>
                                                    const Center(
                                                        child:
                                                            CircularProgressIndicator()),
                                                errorWidget:
                                                    (context, url, error) =>
                                                        Image.asset(
                                                  'assets/images/default_image.png',
                                                  fit: BoxFit.cover,
                                                ),
                                              ),
                                            )
                                          : SizedBox(
                                              child: IconButton(
                                                onPressed:
                                                    _showImageSourceDialog,
                                                icon: const Icon(
                                                  Icons.add_a_photo_rounded,
                                                  size: 60,
                                                ),
                                              ),
                                            )),
                        ),
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton(
                          onPressed: () async {
                            String formattedMontant =
                                _prixController.text.replaceAll(',', '');

                            final int prix =
                                int.tryParse(formattedMontant) ?? 0;
                            print("prix formated $prix");

                            if (formkey.currentState!.validate()) {
                              debugPrint(
                                  "forme: ${forme} , formeValue : ${formeValue}, origin : ${niveau3} , value : ${n3Value}");
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          (AddAndUpdateProductEndSreen(
                                            monnaies: monnaie,
                                            isEditable: widget.isEditable!,
                                            nomProduit: _nomController.text,
                                            forme: forme,
                                            origine: niveau3,
                                            prix: prix.toString(),
                                            image: photo,
                                            quantite: _quantiteController.text,
                                            stock: widget.stock,
                                          )))).then((value) => {
                                    if (widget.isEditable! == false)
                                      {
                                        _nomController.clear(),
                                        _prixController.clear(),
                                        _quantiteController.clear(),
                                        setState(() {
                                          n3Value = null;
                                          monnaieValue = null;
                                          formeValue = null;
                                        })
                                      }
                                  });
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
                            "Suivant",
                            style: TextStyle(
                              fontSize: 20,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          )),
                      SizedBox(
                        height: 10,
                      ),
                    ],
                  ))
            ],
          ),
        ]),
      ),
    );
  }

  Widget _buildItem(String title, String value) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(
                color: Colors.black87,
                fontWeight: FontWeight.w500,
                fontStyle: FontStyle.italic,
                overflow: TextOverflow.ellipsis,
                fontSize: 16),
          ),
          Text(
            value,
            style: const TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.w800,
                overflow: TextOverflow.ellipsis,
                fontSize: 16),
          )
        ],
      ),
    );
  }
}
