// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:dropdown_plus_plus/dropdown_plus_plus.dart';

import 'package:intl/intl.dart';
import 'package:koumi/constants.dart';
import 'package:koumi/models/Acteur.dart';
import 'package:koumi/models/CategorieProduit.dart';
import 'package:koumi/models/Forme.dart';
import 'package:koumi/models/Monnaie.dart';
import 'package:koumi/models/Speculation.dart';
import 'package:koumi/providers/ActeurProvider.dart';
import 'package:koumi/service/FormeService.dart';
import 'package:koumi/service/IntrantService.dart';
import 'package:koumi/widgets/LoadingOverlay.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:pattern_formatter/pattern_formatter.dart';

class NextAddIntrat extends StatefulWidget {
  final String nom;
  final String description;
  final double quantite;
  final String unite;
  final CategorieProduit categorieProduit;
  const NextAddIntrat({
    Key? key,
    required this.nom,
    required this.description,
    required this.quantite,
    required this.unite,
    required this.categorieProduit,
  }) : super(key: key);

  @override
  State<NextAddIntrat> createState() => _NextAddIntratState();
}

const d_colorGreen = Color.fromRGBO(43, 103, 6, 1);
const d_colorOr = Color.fromRGBO(255, 138, 0, 1);

class _NextAddIntratState extends State<NextAddIntrat> {
  TextEditingController _prixController = TextEditingController();
  TextEditingController _dateController = TextEditingController();
  late Speculation speculation;
  // late ParametreGeneraux para = ParametreGeneraux();
  // List<ParametreGeneraux> paraList = [];
  // late CategorieProduit categorieProduit;
  late CategorieProduit categorieProduit = CategorieProduit();
  String? monnaieValue;
  late Future _monnaieList;
  late Monnaie monnaie = Monnaie();
  DateTime selectedDate = DateTime.now();
  bool _isLoading = false;
  final formkey = GlobalKey<FormState>();
  late Acteur acteur;
  String? imageSrc;
  File? photo;
  String? formeValue;
  late Future _formeList;
  late Forme forme;

  bool isLoadingLibelle = true;

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

  void _handleButtonPress() async {
    // Afficher l'indicateur de chargement
    setState(() {
      _isLoading = true;
    });
  }

  @override
  void initState() {
    super.initState();
    acteur = Provider.of<ActeurProvider>(context, listen: false).acteur!;

    _monnaieList = http.get(Uri.parse('$apiOnlineUrl/Monnaie/getAllMonnaie'));
    _formeList = http.get(Uri.parse('$apiOnlineUrl/formeproduit/getAllForme/'));
  }

  Future<List<Forme>> fetchList() async {
    final response = await FormeService().fetchForme();
    return response;
  }

  @override
  Widget build(BuildContext context) {
    return LoadingOverlay(
        isLoading: _isLoading,
        child: Scaffold(
          backgroundColor: const Color.fromARGB(255, 250, 250, 250),
          appBar: AppBar(
            backgroundColor: d_colorOr,
            centerTitle: true,
            toolbarHeight: 75,
            leading: IconButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                icon: const Icon(Icons.arrow_back_ios, color: Colors.white)),
            title: Text(
              'Etape 2 ',
              style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 20),
            ),
          ),
          body: SingleChildScrollView(
            child: Column(
              children: [
                Form(
                  key: formkey,
                  child: Column(children: [
                    SizedBox(height: 10),
                    Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: 22,
                      ),
                      child: Align(
                        alignment: Alignment.topLeft,
                        child: Text(
                          "Choisir la forme",
                          style: TextStyle(color: (Colors.black), fontSize: 18),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 10, horizontal: 20),
                      child: FutureBuilder(
                        future: _formeList,
                        builder: (_, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return TextDropdownFormField(
                              options: [],
                              decoration: InputDecoration(
                                  contentPadding: const EdgeInsets.symmetric(
                                      vertical: 10, horizontal: 20),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  suffixIcon: Icon(Icons.search),
                                  labelText: "Chargement..."),
                              cursorColor: Colors.green,
                            );
                          }

                          if (snapshot.hasData) {
                            dynamic jsonString =
                                utf8.decode(snapshot.data.bodyBytes);
                            dynamic responseData = json.decode(jsonString);

                            if (responseData is List) {
                              final reponse = responseData;
                              final monaieList = reponse
                                  .map((e) => Forme.fromMap(e))
                                  .where((con) => con.statutForme == true)
                                  .toList();
                              if (monaieList.isEmpty) {
                                return TextDropdownFormField(
                                  options: [],
                                  decoration: InputDecoration(
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                              vertical: 10, horizontal: 20),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      suffixIcon: Icon(Icons.search),
                                      labelText: "Aucune forme trouvé"),
                                  cursorColor: Colors.green,
                                );
                              }

                              return DropdownFormField<Forme>(
                                onEmptyActionPressed: (String str) async {},
                                dropdownHeight: 200,
                                decoration: InputDecoration(
                                    contentPadding: const EdgeInsets.symmetric(
                                        vertical: 10, horizontal: 20),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    suffixIcon: Icon(Icons.search),
                                    labelText: 'Sélectionner une forme'),
                                onSaved: (dynamic n) {
                                  forme = n;
                                  print("onSaved : $forme");
                                },
                                onChanged: (dynamic n) {
                                  forme = n;
                                  print("selected : $forme");
                                },
                                displayItemFn: (dynamic item) => Text(
                                  item?.libelleForme ?? '',
                                  style: TextStyle(fontSize: 16),
                                ),
                                findFn: (String str) async => monaieList,
                                selectedFn: (dynamic item1, dynamic item2) {
                                  if (item1 != null && item2 != null) {
                                    return item1.idForme == item2.idForme;
                                  }
                                  return false;
                                },
                                filterFn: (dynamic item, String str) => item
                                    .libelleForme!
                                    .toLowerCase()
                                    .contains(str.toLowerCase()),
                                dropdownItemFn: (dynamic item,
                                        int position,
                                        bool focused,
                                        bool selected,
                                        Function() onTap) =>
                                    ListTile(
                                  title: Text(item.libelleForme!),
                                  tileColor: focused
                                      ? Color.fromARGB(20, 0, 0, 0)
                                      : Colors.transparent,
                                  onTap: onTap,
                                ),
                              );
                            }
                          }
                          return TextDropdownFormField(
                            options: [],
                            decoration: InputDecoration(
                                contentPadding: const EdgeInsets.symmetric(
                                    vertical: 10, horizontal: 20),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                suffixIcon: Icon(Icons.search),
                                labelText: "Aucune forme trouvé"),
                            cursorColor: Colors.green,
                          );
                        },
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: 22,
                      ),
                      child: Align(
                        alignment: Alignment.topLeft,
                        child: Text(
                          "Date de péremption",
                          style: TextStyle(color: (Colors.black), fontSize: 18),
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
                        controller: _dateController,
                        decoration: InputDecoration(
                          hintText: 'Sélectionner la date',
                          prefixIcon: const Icon(
                            Icons.date_range,
                            color: d_colorGreen,
                            size: 30.0,
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                              vertical: 10, horizontal: 20),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        onTap: () async {
                          DateTime? pickedDate = await showDatePicker(
                              context: context,
                              initialDate: DateTime.now(),
                              firstDate: DateTime.now(),
                              lastDate: DateTime(2100));
                          if (pickedDate != null) {
                            print(pickedDate);
                            String formattedDate =
                                DateFormat('yyyy-MM-dd').format(pickedDate);
                            print(formattedDate);
                            setState(() {
                              _dateController.text = formattedDate;
                            });
                          } else {}
                        },
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: 22,
                          ),
                          child: Align(
                            alignment: Alignment.topLeft,
                            child: Text(
                              "Prix intrant",
                              style: TextStyle(
                                  color: (Colors.black), fontSize: 18),
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
                              "Choisir la monnaie",
                              style: TextStyle(
                                  color: (Colors.black), fontSize: 18),
                            ),
                          ),
                        ),
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 10,
                                ),
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
                                    hintText: "Prix intrant",
                                    contentPadding: const EdgeInsets.symmetric(
                                        vertical: 10, horizontal: 20),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                )),
                          ),
                          SizedBox(width: 10),
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                vertical: 10,
                              ),
                              child: FutureBuilder(
                                future: _monnaieList,
                                builder: (_, snapshot) {
                                  if (snapshot.connectionState ==
                                      ConnectionState.waiting) {
                                    return TextDropdownFormField(
                                      options: [],
                                      decoration: InputDecoration(
                                          contentPadding:
                                              const EdgeInsets.symmetric(
                                                  vertical: 10, horizontal: 20),
                                          border: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(8),
                                          ),
                                          suffixIcon: Icon(Icons.search),
                                          labelText: "Chargement..."),
                                      cursorColor: Colors.green,
                                    );
                                  }

                                  if (snapshot.hasData) {
                                    dynamic jsonString =
                                        utf8.decode(snapshot.data.bodyBytes);
                                    dynamic responseData =
                                        json.decode(jsonString);

                                    if (responseData is List) {
                                      final reponse = responseData;
                                      final monaieList = reponse
                                          .map((e) => Monnaie.fromMap(e))
                                          .where((con) => con.statut == true)
                                          .toList();
                                      if (monaieList.isEmpty) {
                                        return TextDropdownFormField(
                                          options: [],
                                          decoration: InputDecoration(
                                              contentPadding:
                                                  const EdgeInsets.symmetric(
                                                      vertical: 10,
                                                      horizontal: 20),
                                              border: OutlineInputBorder(
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                              ),
                                              suffixIcon: Icon(Icons.search),
                                              labelText:
                                                  "Aucune monnaie trouvé"),
                                          cursorColor: Colors.green,
                                        );
                                      }

                                      return DropdownFormField<Monnaie>(
                                        onEmptyActionPressed:
                                            (String str) async {},
                                        dropdownHeight: 200,
                                        decoration: InputDecoration(
                                            contentPadding:
                                                const EdgeInsets.symmetric(
                                                    vertical: 10,
                                                    horizontal: 20),
                                            border: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                            ),
                                            suffixIcon: Icon(Icons.search),
                                            labelText: 'Monnaie'),
                                        onSaved: (dynamic n) {
                                          monnaie = n;
                                          print("onSaved : $monnaie");
                                        },
                                        onChanged: (dynamic n) {
                                          monnaie = n;
                                          print("selected : $monnaie");
                                        },
                                        displayItemFn: (dynamic item) => Text(
                                          item?.libelle ?? '',
                                          style: TextStyle(fontSize: 16),
                                        ),
                                        findFn: (String str) async =>
                                            monaieList,
                                        selectedFn:
                                            (dynamic item1, dynamic item2) {
                                          if (item1 != null && item2 != null) {
                                            return item1.idMonnaie ==
                                                item2.idMonnaie;
                                          }
                                          return false;
                                        },
                                        filterFn: (dynamic item, String str) =>
                                            item.libelle!
                                                .toLowerCase()
                                                .contains(str.toLowerCase()),
                                        dropdownItemFn: (dynamic item,
                                                int position,
                                                bool focused,
                                                bool selected,
                                                Function() onTap) =>
                                            ListTile(
                                          title: Text(item.libelle!),
                                          tileColor: focused
                                              ? Color.fromARGB(20, 0, 0, 0)
                                              : Colors.transparent,
                                          onTap: onTap,
                                        ),
                                      );
                                    }
                                  }
                                  return TextDropdownFormField(
                                    options: [],
                                    decoration: InputDecoration(
                                        contentPadding:
                                            const EdgeInsets.symmetric(
                                                vertical: 10, horizontal: 20),
                                        border: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(8),
                                        ),
                                        suffixIcon: Icon(Icons.search),
                                        labelText: "Aucune monnaie trouvé"),
                                    cursorColor: Colors.green,
                                  );
                                },
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 10),
                    Text("Choisir une photo"),
                    SizedBox(
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
                    const SizedBox(height: 20),
                    ElevatedButton(
                        onPressed: () async {
                          final String nom = widget.nom;
                          final String description = widget.description;
                          final double quantite = widget.quantite;
                          final CategorieProduit categorieProduit =
                              widget.categorieProduit;
                          final String unite = widget.unite;
                          String formattedMontant =
                              _prixController.text.replaceAll(',', '');

                          final int prix = int.tryParse(formattedMontant) ?? 0;
                          print("prix formated $prix");
                          final String date = _dateController.text;

                          if (formkey.currentState!.validate()) {
                            try {
                              setState(() {
                                _isLoading = true;
                              });
                              if (photo != null) {
                                await IntrantService()
                                    .creerIntrant(
                                        nomIntrant: nom,
                                        quantiteIntrant: quantite,
                                        descriptionIntrant: description,
                                        prixIntrant: prix,
                                        photoIntrant: photo,
                                        dateExpiration: date,
                                        forme: forme,
                                        unite: unite,
                                        categorieProduit: categorieProduit,
                                        acteur: acteur,
                                        monnaie: monnaie)
                                    .then((value) => {
                                          Provider.of<IntrantService>(context,
                                                  listen: false)
                                              .applyChange(),
                                          _prixController.clear(),
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
                                                    "Intant ajouté avec succèss",
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
                                          setState(() {
                                            _isLoading = false;
                                          }),
                                          print('Erreur :${onError.message}'),
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                            const SnackBar(
                                              content: Row(
                                                children: [
                                                  Text(
                                                    "Une erreur s'est produite",
                                                    style: TextStyle(
                                                        overflow: TextOverflow
                                                            .ellipsis),
                                                  ),
                                                ],
                                              ),
                                              duration: Duration(seconds: 5),
                                            ),
                                          )
                                        });
                              } else {
                                await IntrantService()
                                    .creerIntrant(
                                        nomIntrant: nom,
                                        quantiteIntrant: quantite,
                                        descriptionIntrant: description,
                                        prixIntrant: prix,
                                        dateExpiration: date,
                                        categorieProduit: categorieProduit,
                                        forme: forme,
                                        unite: unite,
                                        acteur: acteur,
                                        monnaie: monnaie)
                                    .then((value) => {
                                          Provider.of<IntrantService>(context,
                                                  listen: false)
                                              .applyChange(),
                                          _prixController.clear(),
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
                                                    "Intant ajouté avec succèss",
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
                                          print('Erreur :${onError.message}'),
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
                                                        overflow: TextOverflow
                                                            .ellipsis),
                                                  ),
                                                ],
                                              ),
                                              duration: Duration(seconds: 5),
                                            ),
                                          )
                                        });
                              }
                            } catch (e) {
                              setState(() {
                                _isLoading = false;
                              });
                              print('Erreur :${e.toString()}');
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Row(
                                    children: [
                                      Text(
                                        "Erreur de connexion !",
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
                          backgroundColor: d_colorOr, // Orange color code
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
                  ]),
                )
              ],
            ),
          ),
        ));
  }
}
