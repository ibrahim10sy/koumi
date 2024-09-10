import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:koumi/constants.dart';
import 'package:koumi/models/Acteur.dart';
import 'package:koumi/models/Campagne.dart';
import 'package:koumi/models/Niveau3Pays.dart';
import 'package:koumi/models/Speculation.dart';
import 'package:koumi/providers/ActeurProvider.dart';
import 'package:koumi/service/CampagneService.dart';
import 'package:koumi/service/Niveau3Service.dart';
import 'package:koumi/service/SpeculationService.dart';
import 'package:koumi/service/SuperficieService.dart';
import 'package:koumi/widgets/LoadingOverlay.dart';
import 'package:provider/provider.dart';
import 'package:dropdown_plus_plus/dropdown_plus_plus.dart';

class AddSuperficie extends StatefulWidget {
  const AddSuperficie({super.key});

  @override
  State<AddSuperficie> createState() => _AddSuperficieState();
}

const d_colorGreen = Color.fromRGBO(43, 103, 6, 1);
const d_colorOr = Color.fromRGBO(255, 138, 0, 1);

class _AddSuperficieState extends State<AddSuperficie> {
  final formkey = GlobalKey<FormState>();
  TextEditingController _localiteController = TextEditingController();
  TextEditingController _superficieHaController = TextEditingController();
  TextEditingController _dateController = TextEditingController();
  TextEditingController _descriptionController = TextEditingController();
  List<Widget> listeIntrantFields = [];
  List<TextEditingController> intrantController = [];
  List<String> selectedIntrant = [];
  String? speValue;
  String? catValue;
  String niveau3 = '';
  String? n3Value;
  late Future _niveau3List;
  // late Future<List<Campagne>> _liste;
  late Future _liste;

  late Future _speculationList;
  late Speculation speculation;
  late Campagne campagne;
  DateTime selectedDate = DateTime.now();
  late Acteur acteur;
  bool _isLoading = false;
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

    acteur = Provider.of<ActeurProvider>(context, listen: false).acteur!;
    _liste = http.get(Uri.parse(
        '$apiOnlineUrl/Campagne/getAllCampagneByActeur/${acteur.idActeur}'));

    _speculationList =
        http.get(Uri.parse('$apiOnlineUrl/Speculation/getAllSpeculation'));

    _niveau3List = http.get(Uri.parse(
        '$apiOnlineUrl/nivveau3Pays/listeNiveau3PaysByNomPays/${acteur.niveau3PaysActeur}'));
    fetchLibelleNiveau3Pays();
  }

  List<String?> selectedIntrantList = [];

  void addIntrant() {
    TextEditingController newIntrantController = TextEditingController();

    setState(() {
      intrantController.add(newIntrantController);
      selectedIntrantList.add(null);
    });
  }

  Future<List<Niveau3Pays>> fetchniveauList() async {
    final response = await Niveau3Service().fetchNiveau3Pays();
    return response;
  }

  Future<List<Campagne>> getCampListe() async {
    final response =
        await CampagneService().fetchCampagneByActeur(acteur.idActeur!);
    return response;
  }

  Future<List<Speculation>> fetchSpeculationList() async {
    final response = await SpeculationService().fetchSpeculation();
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
            'Ajout de superficie ',
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
                            "Superficie (Hectare)",
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
                          controller: _superficieHaController,
                          decoration: InputDecoration(
                            hintText: "Superficie ",
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
                                      labelText: 'Selectionner une localité'),
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

                      Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: 22,
                        ),
                        child: Align(
                          alignment: Alignment.topLeft,
                          child: Text(
                            "Choisir une spéculation",
                            style:
                                TextStyle(color: (Colors.black), fontSize: 18),
                          ),
                        ),
                      ),
                      Padding(
                          padding: const EdgeInsets.symmetric(
                              vertical: 10, horizontal: 20),
                          child: FutureBuilder(
                            future: _speculationList,
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
                                      .map((e) => Speculation.fromMap(e))
                                      .where((con) =>
                                          con.statutSpeculation == true)
                                      .toList();
                                  if (monaieList.isEmpty) {
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
                                          labelText:
                                              "Aucune spéculation trouvé"),
                                      cursorColor: Colors.green,
                                    );
                                  }

                                  return DropdownFormField<Speculation>(
                                    onEmptyActionPressed: (String str) async {},
                                    dropdownHeight: 200,
                                    decoration: InputDecoration(
                                        contentPadding:
                                            const EdgeInsets.symmetric(
                                                vertical: 10, horizontal: 20),
                                        border: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(8),
                                        ),
                                        suffixIcon: Icon(Icons.search),
                                        labelText:
                                            'Selectionner une spécumation'),
                                    onSaved: (dynamic n) {
                                      speculation = n;
                                      print("onSaved : $speculation");
                                    },
                                    onChanged: (dynamic n) {
                                      speculation = n;
                                      print("selected : $speculation");
                                    },
                                    displayItemFn: (dynamic item) => Text(
                                      item?.nomSpeculation ?? '',
                                      style: TextStyle(fontSize: 16),
                                    ),
                                    findFn: (String str) async => monaieList,
                                    selectedFn: (dynamic item1, dynamic item2) {
                                      if (item1 != null && item2 != null) {
                                        return item1.idSpeculation ==
                                            item2.idSpeculation;
                                      }
                                      return false;
                                    },
                                    filterFn: (dynamic item, String str) => item
                                        .nomSpeculation!
                                        .toLowerCase()
                                        .contains(str.toLowerCase()),
                                    dropdownItemFn: (dynamic item,
                                            int position,
                                            bool focused,
                                            bool selected,
                                            Function() onTap) =>
                                        ListTile(
                                      title: Text(item.nomSpeculation!),
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
                                    labelText: "Aucune spéculation trouvé"),
                                cursorColor: Colors.green,
                              );
                            },
                          )),

                      Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: 22,
                        ),
                        child: Align(
                          alignment: Alignment.topLeft,
                          child: Text(
                            "Choisir une campagne",
                            style:
                                TextStyle(color: (Colors.black), fontSize: 18),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            vertical: 10, horizontal: 20),
                        child: FutureBuilder(
                          future: _liste,
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
                                    .map((e) => Campagne.fromMap(e))
                                    .where((con) => con.statutCampagne == true)
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
                                        labelText: "Aucune campagne trouvé"),
                                    cursorColor: Colors.green,
                                  );
                                }

                                return DropdownFormField<Campagne>(
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
                                      labelText: 'Selectionner une campagne'),
                                  onSaved: (dynamic n) {
                                    campagne = n;
                                    print("onSaved : $campagne");
                                  },
                                  onChanged: (dynamic n) {
                                    campagne = n;
                                    print("selected : $campagne");
                                  },
                                  displayItemFn: (dynamic item) => Text(
                                    item?.nomCampagne ?? '',
                                    style: TextStyle(fontSize: 16),
                                  ),
                                  findFn: (String str) async => niveau3List,
                                  selectedFn: (dynamic item1, dynamic item2) {
                                    if (item1 != null && item2 != null) {
                                      return item1.idCampagne ==
                                          item2.idCampagne;
                                    }
                                    return false;
                                  },
                                  filterFn: (dynamic item, String str) => item
                                      .nomCampagne!
                                      .toLowerCase()
                                      .contains(str.toLowerCase()),
                                  dropdownItemFn: (dynamic item,
                                          int position,
                                          bool focused,
                                          bool selected,
                                          Function() onTap) =>
                                      ListTile(
                                    title: Text(item.nomCampagne!),
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
                                  labelText: "Aucune campagne trouvé"),
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
                            "Date de semence",
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
                                  DateFormat('yyyy-MM-dd HH:mm')
                                      .format(pickedDate);
                              print(formattedDate);
                              setState(() {
                                _dateController.text = formattedDate;
                              });
                            } else {}
                          },
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  "Ajouter les intrants utilisées",
                                  style: TextStyle(
                                      color: Colors.black, fontSize: 18),
                                ),
                                IconButton(
                                    onPressed: addIntrant,
                                    icon: Icon(Icons.add))
                              ],
                            ),
                          
                            Column(
                              children: List.generate(
                                intrantController.length,
                                (index) => Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: TextFormField(
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return "Veuillez remplir les champs";
                                      }
                                      return null;
                                    },
                                    controller: intrantController[index],
                                    decoration: InputDecoration(
                                      hintText: "Intrant utilisé",
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                        vertical: 10,
                                        horizontal: 20,
                                      ),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(height: 10),
                          ],
                        ),
                      ),
                    ],
                  )),
              ElevatedButton(
                onPressed: () async {
                  final String superficie = _superficieHaController.text;
                  final String date = _dateController.text;
                  setState(() {
                    for (int i = 0; i < selectedIntrantList.length; i++) {
                      String item = intrantController[i].text;
                      if (item.isNotEmpty) {
                        selectedIntrant.addAll({item});
                      }
                    }
                  });
                  try {
                    setState(() {
                      _isLoading = true;
                    });
                    await SuperficieService()
                        .addSuperficie(
                            localite: niveau3,
                            superficieHa: superficie,
                            dateSemi: date,
                            acteur: acteur,
                            intrants: selectedIntrant,
                            speculation: speculation,
                            campagne: campagne)
                        .then((value) => {
                              Provider.of<SuperficieService>(context,
                                      listen: false)
                                  .applyChange(),
                              _superficieHaController.clear(),
                              _dateController.clear(),
                              setState(() {
                                _isLoading = false;
                                catValue = null;
                                speValue = null;
                                n3Value = null;
                              }),
                              Navigator.pop(context, true)
                            })
                        .catchError((onError) => {
                              setState(() {
                                _isLoading = false;
                              }),
                            });
                  } catch (e) {
                    setState(() {
                      _isLoading = false;
                    });
                    final String errorMessage = e.toString();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Row(
                          children: [
                            Text("Une erreur s'est produit"),
                          ],
                        ),
                        duration: const Duration(seconds: 5),
                      ),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: d_colorOr,
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
                    fontWeight: FontWeight.w700,
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
