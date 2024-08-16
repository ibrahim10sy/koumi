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
    final response = await http.get(Uri.parse('$apiOnlineUrl/acteur/libelleNiveau3Pays/$id'));

    if (response.statusCode == 200) {
      print("libelle : ${response.body}");
      return response.body;  // Return the body directly since it's a plain string
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
    _liste = getCampListe();

    _speculationList = http.get(
        Uri.parse('$apiOnlineUrl/Speculation/getAllSpeculation'));
  
    _niveau3List =
        http.get(Uri.parse('$apiOnlineUrl/nivveau3Pays/listeNiveau3PaysByNomPays/${acteur.niveau3PaysActeur}'));
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
          centerTitle: true,
          toolbarHeight: 100,
          leading: IconButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              icon: const Icon(Icons.arrow_back_ios, color: d_colorGreen)),
          title: Text(
            'Ajout de superficie ',
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
                      SizedBox(
                        height: 10,
                      ),
                          isLoadingLibelle ?
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Align(
                          alignment: Alignment.topLeft,
                          child: Text("Chargement ................",style: TextStyle(
                                  fontSize: 15, fontWeight: FontWeight.bold),)),
                      )
                      :
                      Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: 22,
                        ),
                        child: Align(
                          alignment: Alignment.topLeft,
                          child: Text(
                           libelleNiveau3Pays != null ? libelleNiveau3Pays!.toUpperCase() : "Localité",
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
                                        borderRadius: BorderRadius.circular(8),
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
                                        niveau3 = niveau3List
                                            .map((e) => e.nomN3)
                                            .first;
                                        print("niveau 3 : ${niveau3}");
                                      }
                                    });
                                  },
                                  decoration: InputDecoration(
                                    labelText: 'Selectionner une localité',
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
                            "Chosir une spéculation",
                            style:
                                TextStyle(color: (Colors.black), fontSize: 18),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            vertical: 10, horizontal: 20),
                        child: Consumer<SpeculationService>(
                            builder: (context, speculationService, child) {
                          return FutureBuilder(
                            future: _speculationList,
                            // future: speculationService.fetchSpeculationByCategorie(categorieProduit.idCategorieProduit!),
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
                                  List<Speculation> speList = responseData
                                      .map((e) => Speculation.fromMap(e))
                                      .toList();

                                  if (speList.isEmpty) {
                                    return DropdownButtonFormField(
                                      items: [],
                                      onChanged: null,
                                      decoration: InputDecoration(
                                        labelText: 'Aucune speculation trouvé',
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
                                      labelText: 'Sélectionner une speculation',
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
                                      labelText: 'Aucune speculation trouvé',
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
                                    labelText: 'Aucune speculation trouvé',
                                    contentPadding: const EdgeInsets.symmetric(
                                        vertical: 10, horizontal: 20),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                );
                              }
                            },
                          );
                        }),
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
                            "Chosir une campagne",
                            style:
                                TextStyle(color: (Colors.black), fontSize: 18),
                          ),
                        ),
                      ),
                      Padding(
                        padding:
                            EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                        child: FutureBuilder(
                          future: _liste,
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
                              List<Campagne> campListe = snapshot.data;

                              if (campListe.isEmpty) {
                                return DropdownButtonFormField(
                                  items: [],
                                  onChanged: null,
                                  decoration: InputDecoration(
                                    labelText: 'Aucune campagne trouvé',
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                );
                              }

                              return DropdownButtonFormField<String>(
                                isExpanded: true,
                                items: campListe
                                    .map(
                                      (e) => DropdownMenuItem(
                                        value: e.idCampagne,
                                        child: Text(e.nomCampagne),
                                      ),
                                    )
                                    .toList(),
                                value: catValue,
                                onChanged: (newValue) {
                                  setState(() {
                                    catValue = newValue;
                                    if (newValue != null) {
                                      campagne = campListe.firstWhere(
                                        (element) =>
                                            element.idCampagne == newValue,
                                      );
                                    }
                                  });
                                },
                                decoration: InputDecoration(
                                  labelText: 'Sélectionner une campagne',
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
                                  labelText: 'Aucune campagne trouvé',
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
                            SizedBox(height: 10),
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
                      // Column(
                      //   children: listeIntrantFields,
                      // ),
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
                              Navigator.of(context).pop()
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
