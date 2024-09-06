import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:koumi/constants.dart';
import 'package:koumi/models/Acteur.dart';
import 'package:koumi/models/Niveau3Pays.dart';
import 'package:koumi/models/TypeVoiture.dart';
import 'package:koumi/providers/ActeurProvider.dart';
import 'package:koumi/screens/NextAddVehiculeActeur.dart';
import 'package:koumi/service/VehiculeService.dart';
import 'package:koumi/widgets/AutoComptet.dart';
import 'package:koumi/widgets/LoadingOverlay.dart';
import 'package:provider/provider.dart';
import 'package:dropdown_plus_plus/dropdown_plus_plus.dart';

class AddVehicule extends StatefulWidget {
  const AddVehicule({super.key});

  @override
  State<AddVehicule> createState() => _AddVehiculeState();
}

const d_colorGreen = Color.fromRGBO(43, 103, 6, 1);
const d_colorOr = Color.fromRGBO(255, 138, 0, 1);

class _AddVehiculeState extends State<AddVehicule> {
  TextEditingController _nomController = TextEditingController();
  TextEditingController _localiteController = TextEditingController();
  TextEditingController _descriptionController = TextEditingController();
  TextEditingController _nbKilometrageController = TextEditingController();
  TextEditingController _capaciteController = TextEditingController();

  String? typeValue;
  String? n3Value;
  late Future _typeList;
  late Future _niveau3List;
  String niveau3 = '';
  late TypeVoiture typeVoiture;
  late TypeVoiture type;
  File? photo;
  late Acteur acteur;
  bool _isLoading = false;
  final formkey = GlobalKey<FormState>();

  bool isLoadingLibelle = true;
  String? libelleNiveau3Pays;

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

    _typeList = http.get(Uri.parse('$apiOnlineUrl/TypeVoiture/read'));
    _niveau3List = http.get(Uri.parse(
        '$apiOnlineUrl/nivveau3Pays/listeNiveau3PaysByNomPays/${acteur.niveau3PaysActeur}'));

    fetchLibelleNiveau3Pays();
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
            'Ajout de véhicule',
            style: const TextStyle(
                color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20),
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
                  child: Column(
                    children: [
                      Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: 22,
                        ),
                        child: Align(
                          alignment: Alignment.topLeft,
                          child: Text(
                            "Nom du véhicule",
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
                            hintText: "Nom véhicule",
                            contentPadding: const EdgeInsets.symmetric(
                                vertical: 10, horizontal: 20),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 5,
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: 22,
                        ),
                        child: Align(
                          alignment: Alignment.topLeft,
                          child: Text(
                            "Description",
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
                        height: 5,
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: 22,
                        ),
                        child: Align(
                          alignment: Alignment.topLeft,
                          child: Text(
                            "Nombre de kilométrage",
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
                          controller: _nbKilometrageController,
                          keyboardType: TextInputType.number,
                          inputFormatters: <TextInputFormatter>[
                            FilteringTextInputFormatter.digitsOnly,
                          ],
                          decoration: InputDecoration(
                            hintText: "Nombre de kilometrage",
                            contentPadding: const EdgeInsets.symmetric(
                                vertical: 10, horizontal: 20),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 5,
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: 22,
                        ),
                        child: Align(
                          alignment: Alignment.topLeft,
                          child: Text(
                            "Type de véhicule",
                            style:
                                TextStyle(color: (Colors.black), fontSize: 18),
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
                                final vehiculeList = reponse
                                    .map((e) => TypeVoiture.fromMap(e))
                                    .where((con) => con.statutType == true)
                                    .toList();

                                if (vehiculeList.isEmpty) {
                                  return DropdownButtonFormField(
                                    items: [],
                                    onChanged: null,
                                    decoration: InputDecoration(
                                      labelText:
                                          'Aucun type de véhicule trouvé',
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
                                  items: vehiculeList
                                      .map(
                                        (e) => DropdownMenuItem(
                                          value: e.idTypeVoiture,
                                          child: Text(e.nom!),
                                        ),
                                      )
                                      .toList(),
                                  value: typeValue,
                                  onChanged: (newValue) {
                                    setState(() {
                                      typeValue = newValue;
                                      if (newValue != null) {
                                        typeVoiture = vehiculeList.firstWhere(
                                          (element) =>
                                              element.idTypeVoiture == newValue,
                                        );
                                      }
                                    });
                                  },
                                  decoration: InputDecoration(
                                    labelText:
                                        'Sélectionner un type de véhicule',
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
                                    labelText: 'Aucun type de véhicule trouvé',
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
                                labelText: 'Aucun type de véhicule trouvé',
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
                        height: 5,
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: 22,
                        ),
                        child: Align(
                          alignment: Alignment.topLeft,
                          child: Text(
                            "Localité",
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
                                final niveau3List = reponse
                                    .map((e) => Niveau3Pays.fromMap(e))
                                    .where((con) => con.statutN3 == true)
                                    .toList();
                                if (niveau3List.isEmpty) {
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
                                        labelText: "Aucune localité trouvé"),
                                    cursorColor: Colors.green,
                                  );
                                }

                                return DropdownFormField<Niveau3Pays>(
                                  onEmptyActionPressed: (String str) async {},
                                  dropdownHeight: 200,
                                  decoration: InputDecoration(
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                              vertical: 10, horizontal: 20),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      suffixIcon: Icon(Icons.search),
                                      labelText: "Rechercher une localité"),
                                  onSaved: (dynamic n) {
                                    niveau3 = n?.nomN3;
                                    print("onSaved : $niveau3");
                                  },
                                  onChanged: (dynamic n) {
                                    niveau3 = n?.nomN3;
                                    print("selected : $niveau3");
                                  },
                                  displayItemFn: (dynamic item) => Text(
                                    item?.nomN3 ?? '',
                                    style: TextStyle(fontSize: 16),
                                  ),
                                  findFn: (String str) async => niveau3List,
                                  selectedFn: (dynamic item1, dynamic item2) {
                                    if (item1 != null && item2 != null) {
                                      return item1.idNiveau3Pays ==
                                          item2.idNiveau3Pays;
                                    }
                                    return false;
                                  },
                                  filterFn: (dynamic item, String str) => item
                                      .nomN3!
                                      .toLowerCase()
                                      .contains(str.toLowerCase()),
                                  dropdownItemFn: (dynamic item,
                                          int position,
                                          bool focused,
                                          bool selected,
                                          Function() onTap) =>
                                      ListTile(
                                    title: Text(item.nomN3!),
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
                                  labelText: "Aucune localité trouvé"),
                              cursorColor: Colors.green,
                            );
                          },
                        ),
                      ),
                      SizedBox(
                        height: 5,
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: 22,
                        ),
                        child: Align(
                          alignment: Alignment.topLeft,
                          child: Text(
                            "Capacité de la véhicule",
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
                          controller: _capaciteController,
                          decoration: InputDecoration(
                            hintText: "capacité",
                            contentPadding: const EdgeInsets.symmetric(
                                vertical: 10, horizontal: 20),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                      ),
                      ElevatedButton(
                          onPressed: () {
                            if (formkey.currentState!.validate()) {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          NextAddVehiculeActeur(
                                              typeVoiture: typeVoiture,
                                              nomV: _nomController.text,
                                              localite: niveau3,
                                              description:
                                                  _descriptionController.text,
                                              nbKilo:
                                                  _nbKilometrageController.text,
                                              capacite: _capaciteController
                                                  .text))).then((value) => {
                                    _nomController.clear(),
                                    _descriptionController.clear(),
                                    _localiteController.clear(),
                                    _nbKilometrageController.clear(),
                                    _capaciteController.clear(),
                                    setState(() {
                                      typeValue = null;
                                      n3Value = null;
                                      niveau3 == null;
                                    })
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
                    ],
                  ))
            ],
          ),
        ),
      ),
    );
  }
}
