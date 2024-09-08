import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:koumi/constants.dart';
import 'package:koumi/models/Acteur.dart';
import 'package:koumi/models/CategorieProduit.dart';
import 'package:koumi/models/Filiere.dart';
import 'package:koumi/providers/ActeurProvider.dart';
import 'package:koumi/screens/NextAddIntrat.dart';
import 'package:koumi/service/CategorieService.dart';
import 'package:koumi/widgets/AutoComptet.dart';
import 'package:koumi/widgets/LoadingOverlay.dart';
import 'package:provider/provider.dart';
import 'package:dropdown_plus_plus/dropdown_plus_plus.dart';

class AddIntrant extends StatefulWidget {
  AddIntrant({super.key});

  @override
  State<AddIntrant> createState() => _AddIntrantState();
}

const d_colorGreen = Color.fromRGBO(43, 103, 6, 1);
const d_colorOr = Color.fromRGBO(255, 138, 0, 1);

class _AddIntrantState extends State<AddIntrant> {
  TextEditingController _nomController = TextEditingController();
  TextEditingController _descriptionController = TextEditingController();
  TextEditingController _quantiteController = TextEditingController();
  TextEditingController _uniteController = TextEditingController();
  DateTime selectedDate = DateTime.now();
  bool _isLoading = false;
  final formkey = GlobalKey<FormState>();
  late Acteur acteur;
  String? imageSrc;
  File? photo;
  List<CategorieProduit> categorieList = [];
  // List<Speculation> speculationList = [];
  String? filiereValue;
  late Future _filiereList;
  late Filiere filiere = Filiere();
  String? catValue;
  late Future _categorieList;

  // late ParametreGeneraux para = ParametreGeneraux();
  // List<ParametreGeneraux> paraList = [];
  late CategorieProduit categorieProduit = CategorieProduit();
  late Future<List<CategorieProduit>> _liste;

  // void verifyParam() {
  //   paraList = Provider.of<ParametreGenerauxProvider>(context, listen: false)
  //       .parametreList!;

  //   if (paraList.isNotEmpty) {
  //     para = paraList[0];
  //   } else {
  //     // Gérer le cas où la liste est null ou vide, par exemple :
  //     // Afficher un message d'erreur, initialiser 'para' à une valeur par défaut, etc.
  //   }
  // }

  @override
  void initState() {
    super.initState();
    // verifyParam();
    acteur = Provider.of<ActeurProvider>(context, listen: false).acteur!;

    _categorieList =
        http.get(Uri.parse('$apiOnlineUrl/Categorie/allCategorie'));
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
                  Navigator.pop(context, true);
                },
                icon: const Icon(Icons.arrow_back_ios, color: Colors.white)),
            title: Text(
              'Ajouter un intrant ',
              style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 20),
            ),
          ),
          body: SingleChildScrollView(
            child: Column(
              children: [
                SizedBox(
                  height: 10,
                ),
                Form(
                  key: formkey,
                  child: Column(children: [
                    Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: 22,
                      ),
                      child: Align(
                        alignment: Alignment.topLeft,
                        child: Text(
                          "Choisir une catégorie",
                          style: TextStyle(color: (Colors.black), fontSize: 18),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 10, horizontal: 20),
                      child: FutureBuilder(
                        future: _categorieList,
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
                                  .map((e) => CategorieProduit.fromMap(e))
                                  .where((con) => con.statutCategorie == true)
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
                                      labelText: "Aucune catégorie trouvé"),
                                  cursorColor: Colors.green,
                                );
                              }

                              return DropdownFormField<CategorieProduit>(
                                onEmptyActionPressed: (String str) async {},
                                dropdownHeight: 200,
                                decoration: InputDecoration(
                                    contentPadding: const EdgeInsets.symmetric(
                                        vertical: 10, horizontal: 20),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    suffixIcon: Icon(Icons.search),
                                    labelText: 'Sélectionner une catégorie'),
                                onSaved: (dynamic n) {
                                  categorieProduit = n;
                                  print("onSaved : $categorieProduit");
                                },
                                onChanged: (dynamic n) {
                                  categorieProduit = n;
                                  print("selected : $categorieProduit");
                                },
                                displayItemFn: (dynamic item) => Text(
                                  item?.libelleCategorie ?? '',
                                  style: TextStyle(fontSize: 16),
                                ),
                                findFn: (String str) async => monaieList,
                                selectedFn: (dynamic item1, dynamic item2) {
                                  if (item1 != null && item2 != null) {
                                    return item1.idCategorieProduit ==
                                        item2.idCategorieProduit;
                                  }
                                  return false;
                                },
                                filterFn: (dynamic item, String str) => item
                                    .libelleCategorie!
                                    .toLowerCase()
                                    .contains(str.toLowerCase()),
                                dropdownItemFn: (dynamic item,
                                        int position,
                                        bool focused,
                                        bool selected,
                                        Function() onTap) =>
                                    ListTile(
                                  title: Text(item.libelleCategorie!),
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
                                labelText: "Aucune catégorie trouvé"),
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
                          "Nom de l'intrant",
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
                        controller: _nomController,
                        maxLines: null,
                        decoration: InputDecoration(
                          hintText: "Nom intrant",
                          contentPadding: const EdgeInsets.symmetric(
                              vertical: 10, horizontal: 20),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 5),
                    Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: 22,
                      ),
                      child: Align(
                        alignment: Alignment.topLeft,
                        child: Text(
                          "Description",
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
                    const SizedBox(height: 5),
                    Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: 22,
                      ),
                      child: Align(
                        alignment: Alignment.topLeft,
                        child: Text(
                          "Quantité",
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
                        controller: _quantiteController,
                        keyboardType: TextInputType.number,
                        inputFormatters: <TextInputFormatter>[
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                        decoration: InputDecoration(
                          hintText: "Quantité intant",
                          contentPadding: const EdgeInsets.symmetric(
                              vertical: 10, horizontal: 20),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 5),
                    Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: 22,
                      ),
                      child: Align(
                        alignment: Alignment.topLeft,
                        child: Text(
                          "Unité",
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
                        controller: _uniteController,
                        decoration: InputDecoration(
                          hintText: "Unité",
                          contentPadding: const EdgeInsets.symmetric(
                              vertical: 10, horizontal: 20),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                        onPressed: () async {
                          final String nom = _nomController.text;
                          final String description =
                              _descriptionController.text;
                          final double quantite =
                              double.tryParse(_quantiteController.text) ?? 0.0;
                          final String unit = _uniteController.text;
                          if (formkey.currentState!.validate()) {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => NextAddIntrat(
                                          nom: nom,
                                          description: description,
                                          quantite: quantite,
                                          categorieProduit: categorieProduit,
                                          unite: unit,
                                        ))).then((value) => {
                                  _nomController.clear(),
                                  _descriptionController.clear(),
                                  _quantiteController.clear(),
                                  _uniteController.clear(),
                                  setState(() {
                                    filiereValue = null;
                                    catValue = null;
                                  }),
                                });
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
                          "Suivant",
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
