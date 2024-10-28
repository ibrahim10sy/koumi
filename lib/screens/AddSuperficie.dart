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
import 'package:koumi/screens/SuperficiePage.dart';
import 'package:koumi/service/CampagneService.dart';
import 'package:koumi/service/Niveau3Service.dart';
import 'package:koumi/service/SpeculationService.dart';
import 'package:koumi/service/SuperficieService.dart';
import 'package:koumi/widgets/LoadingOverlay.dart';
import 'package:provider/provider.dart';
import 'package:dropdown_plus_plus/dropdown_plus_plus.dart';
import 'package:get/get.dart';

class AddSuperficie extends StatefulWidget {
  String? distanceParcourue = "";
  String? positionInitiale = "";
  AddSuperficie({super.key, this.positionInitiale, this.distanceParcourue});

  @override
  State<AddSuperficie> createState() => _AddSuperficieState();
}

const d_colorGreen = Color.fromRGBO(43, 103, 6, 1);
const d_colorOr = Color.fromRGBO(255, 138, 0, 1);

class _AddSuperficieState extends State<AddSuperficie> {
  final formkey = GlobalKey<FormState>();
  TextEditingController _localiteController = TextEditingController();
  late TextEditingController _searchController;
  TextEditingController _superficieHaController = TextEditingController();
  TextEditingController speculationController = TextEditingController();
  TextEditingController campagneController = TextEditingController();
  TextEditingController _dateController = TextEditingController();
  TextEditingController _descriptionController = TextEditingController();
  TextEditingController nomController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();
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
  late Future _campList;
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
    if (widget.distanceParcourue != null) {
      _searchController = TextEditingController();
      _superficieHaController.text = widget.distanceParcourue!;
      // _localiteController.text = widget.positionInitiale!;
    }
    _speculationList =
        http.get(Uri.parse('$apiOnlineUrl/Speculation/getAllSpeculation'));
    _campList = http.get(Uri.parse(
        '$apiOnlineUrl/Campagne/getAllCampagneByActeur/${acteur.idActeur}'));
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
  void dispose() {
    _searchController.dispose();
    super.dispose();
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
                            "Superficie (m²)",
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
                        child: GestureDetector(
                          onTap: _showLocalite,
                          child: TextFormField(
                            onTap: _showLocalite,
                            controller: _localiteController,
                            decoration: InputDecoration(
                              suffixIcon: Icon(Icons.arrow_drop_down,
                                  color: Colors.blueGrey[400]),
                              hintText: "Sélectionner une localité",
                              contentPadding: const EdgeInsets.symmetric(
                                  vertical: 10, horizontal: 20),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
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
                            "Choisir une spéculation",
                            style:
                                TextStyle(color: (Colors.black), fontSize: 18),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            vertical: 10, horizontal: 20),
                        child: GestureDetector(
                          onTap: _showSpeculation,
                          child: TextFormField(
                            onTap: _showSpeculation,
                            controller: speculationController,
                            keyboardType: TextInputType.text,
                            decoration: InputDecoration(
                              suffixIcon: Icon(Icons.arrow_drop_down,
                                  color: Colors.blueGrey[400]),
                              hintText: "Sélectionner une speculation",
                              contentPadding: const EdgeInsets.symmetric(
                                  vertical: 10, horizontal: 20),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
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
                            "Choisir une campagne",
                            style:
                                TextStyle(color: (Colors.black), fontSize: 18),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            vertical: 10, horizontal: 20),
                        child: GestureDetector(
                          onTap: _showCampagne,
                          child: TextFormField(
                            onTap: _showCampagne,
                            controller: campagneController,
                            keyboardType: TextInputType.text,
                            decoration: InputDecoration(
                              suffixIcon: Icon(Icons.arrow_drop_down,
                                  color: Colors.blueGrey[400]),
                              hintText: "Sélectionner une campagne",
                              contentPadding: const EdgeInsets.symmetric(
                                  vertical: 10, horizontal: 20),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
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
                                firstDate: DateTime(2000),
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
                              // Navigator.pop(context, true),

                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => SuperficiePage()))
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

  void _showCampagne() async {
    final BuildContext context = this.context;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Padding(
                padding: const EdgeInsets.all(10.0),
                child: TextField(
                  controller: _searchController,
                  onChanged: (value) {
                    if (mounted) setState(() {});
                  },
                  decoration: InputDecoration(
                    hintText: 'Rechercher une campagne',
                    border: UnderlineInputBorder(
                      borderSide: BorderSide(
                        color: Colors.grey[300]!,
                        width: 1,
                      ),
                    ),
                    suffixIcon: const Icon(Icons.search),
                  ),
                ),
              ),
              content: FutureBuilder(
                future: _campList,
                builder: (_, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (snapshot.hasError) {
                    return const Center(
                      child: Text("Erreur lors du chargement des données"),
                    );
                  }

                  if (snapshot.hasData) {
                    final responseData =
                        json.decode(utf8.decode(snapshot.data.bodyBytes));
                    if (responseData is List) {
                      List<Campagne> typeListe = responseData
                          .map((e) => Campagne.fromMap(e))
                          .where((con) => con.statutCampagne == true)
                          .toList();

                      if (typeListe.isEmpty) {
                        return Padding(
                            padding: EdgeInsets.all(10),
                            child: Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Text(
                                    "Aucune campagne trouvée",
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.black87,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                  const SizedBox(
                                      height:
                                          20), // Ajout d'espace entre les éléments
                                  TextButton(
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                      _showDialog();
                                    },
                                    style: TextButton.styleFrom(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 20, vertical: 10),
                                      backgroundColor:
                                          d_colorOr, // Style de fond personnalisé
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(
                                            8), // Bords arrondis
                                      ),
                                    ),
                                    child: const Text(
                                      "Ajouter une campagne",
                                      style: TextStyle(
                                        color: Colors.white, // Couleur du texte
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ));
                      }

                      String searchText = _searchController.text.toLowerCase();
                      List<Campagne> filteredSearch = typeListe
                          .where((type) => type.nomCampagne
                              .toLowerCase()
                              .contains(searchText))
                          .toList();

                      return filteredSearch.isEmpty
                          ? const Text(
                              'Aucune campagne trouvée',
                              style:
                                  TextStyle(color: Colors.black, fontSize: 17),
                            )
                          : SizedBox(
                              width: double.maxFinite,
                              child: ListView.builder(
                                itemCount: filteredSearch.length,
                                itemBuilder: (context, index) {
                                  final type = filteredSearch[index];
                                  final isSelected = campagneController.text ==
                                      type.nomCampagne;

                                  return Column(
                                    children: [
                                      ListTile(
                                        title: Text(
                                          type.nomCampagne!,
                                          style: TextStyle(
                                            color: Colors.black,
                                            fontWeight: isSelected
                                                ? FontWeight.bold
                                                : FontWeight.normal,
                                            fontSize: 16,
                                          ),
                                        ),
                                        trailing: isSelected
                                            ? const Icon(
                                                Icons.check_box_outlined,
                                                color: d_colorOr,
                                              )
                                            : null,
                                        onTap: () {
                                          setState(() {
                                            campagne = type;
                                            campagneController.text =
                                                type.nomCampagne;
                                          });
                                        },
                                      ),
                                      Divider()
                                    ],
                                  );
                                },
                              ),
                            );
                    }
                  }

                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          "Aucune campagne trouvée",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                            color: Colors.black87,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(
                            height: 20), // Ajout d'espace entre les éléments
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).pop();

                            _showDialog();
                          },
                          style: TextButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 20, vertical: 10),
                            backgroundColor:
                                d_colorOr, // Style de fond personnalisé
                            shape: RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.circular(8), // Bords arrondis
                            ),
                          ),
                          child: const Text(
                            "Ajouter une campagne",
                            style: TextStyle(
                              color: Colors.white, // Couleur du texte
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
              actions: <Widget>[
                TextButton(
                  child: const Text(
                    'Annuler',
                    style: TextStyle(color: d_colorOr, fontSize: 16),
                  ),
                  onPressed: () {
                    _searchController.clear();
                    Navigator.of(context).pop();
                  },
                ),
                TextButton(
                  child: const Text(
                    'Valider',
                    style: TextStyle(color: d_colorOr, fontSize: 16),
                  ),
                  onPressed: () {
                    _searchController.clear();
                    print('Options sélectionnées : $campagne');
                    Navigator.of(context).pop();
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) => Dialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Container(
          padding: const EdgeInsets.all(16),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  title: Text(
                    "Ajouter une campagne ",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                      fontSize: 18,
                    ),
                    textAlign: TextAlign.center,
                    overflow: TextOverflow.ellipsis,
                  ),
                  trailing: IconButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      icon: Icon(
                        Icons.close,
                        color: Colors.red,
                        size: 30,
                      )),
                ),

                // const SizedBox(height: 10),
                Form(
                  // key: formkey,
                  child: Column(
                    children: [
                      const SizedBox(
                        height: 10,
                      ),
                      const Text(
                        'Nom campagne',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 22,
                        ),
                      ),
                      TextFormField(
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return "Veuillez remplir les champs";
                          }
                          return null;
                        },
                        controller: nomController,
                        decoration: InputDecoration(
                          hintText: "Nom campagne",
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      const Text(
                        'Description',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 22,
                        ),
                      ),
                      TextFormField(
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return "Veuillez remplir les champs";
                            }
                            return null;
                          },
                          controller: descriptionController,
                          maxLines: null,
                          decoration: InputDecoration(
                            labelText: "Description",
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          )),
                      const SizedBox(height: 20),
                      ElevatedButton.icon(
                        onPressed: () async {
                          final String nom = nomController.text;
                          final String desc = descriptionController.text;
                          // if (formkey.currentState!.validate()) {
                          try {
                            await CampagneService()
                                .addCampagne(
                                    nomCampagne: nom,
                                    description: desc,
                                    acteur: acteur)
                                .then((value) => {
                                      Navigator.of(context).pop(),
                                      nomController.clear(),
                                      descriptionController.clear(),
                                      setState(() {
                                        _campList = http.get(Uri.parse(
                                            '$apiOnlineUrl/Campagne/getAllCampagneByActeur/${acteur.idActeur}'));
                                      }),
                                    });
                          } catch (e) {
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
                          // }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                          minimumSize: const Size(290, 45),
                        ),
                        icon: const Icon(
                          Icons.add,
                          color: Colors.white,
                        ),
                        label: const Text(
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
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showSpeculation() async {
    final BuildContext context = this.context;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Padding(
                padding: const EdgeInsets.all(10.0),
                child: TextField(
                  controller: _searchController,
                  onChanged: (value) {
                    if (mounted) setState(() {});
                  },
                  decoration: InputDecoration(
                    hintText: 'Rechercher une speculation',
                    border: UnderlineInputBorder(
                      borderSide: BorderSide(
                        color: Colors.grey[300]!,
                        width: 1,
                      ),
                    ),
                    suffixIcon: const Icon(Icons.search),
                  ),
                ),
              ),
              content: FutureBuilder(
                future: _speculationList,
                builder: (_, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (snapshot.hasError) {
                    return const Center(
                      child: Text("Erreur lors du chargement des données"),
                    );
                  }

                  if (snapshot.hasData) {
                    final responseData =
                        json.decode(utf8.decode(snapshot.data.bodyBytes));
                    if (responseData is List) {
                      List<Speculation> typeListe = responseData
                          .map((e) => Speculation.fromMap(e))
                          .where((con) => con.statutSpeculation == true)
                          .toList();

                      if (typeListe.isEmpty) {
                        return const Padding(
                          padding: EdgeInsets.all(10),
                          child:
                              Center(child: Text("Aucune speculation trouvée")),
                        );
                      }

                      String searchText = _searchController.text.toLowerCase();
                      List<Speculation> filteredSearch = typeListe
                          .where((type) => type.nomSpeculation!
                              .toLowerCase()
                              .contains(searchText))
                          .toList();

                      return filteredSearch.isEmpty
                          ? const Text(
                              'Aucune speculation trouvée',
                              style:
                                  TextStyle(color: Colors.black, fontSize: 17),
                            )
                          : SizedBox(
                              width: double.maxFinite,
                              child: ListView.builder(
                                itemCount: filteredSearch.length,
                                itemBuilder: (context, index) {
                                  final type = filteredSearch[index];
                                  final isSelected =
                                      speculationController.text ==
                                          type.nomSpeculation;

                                  return Column(
                                    children: [
                                      ListTile(
                                        title: Text(
                                          type.nomSpeculation!,
                                          style: TextStyle(
                                            color: Colors.black,
                                            fontWeight: isSelected
                                                ? FontWeight.bold
                                                : FontWeight.normal,
                                            fontSize: 16,
                                          ),
                                        ),
                                        trailing: isSelected
                                            ? const Icon(
                                                Icons.check_box_outlined,
                                                color: d_colorOr,
                                              )
                                            : null,
                                        onTap: () {
                                          setState(() {
                                            speculation = type;
                                            speculationController.text =
                                                type.nomSpeculation!;
                                          });
                                        },
                                      ),
                                      Divider()
                                    ],
                                  );
                                },
                              ),
                            );
                    }
                  }

                  return const SizedBox(height: 8);
                },
              ),
              actions: <Widget>[
                TextButton(
                  child: const Text(
                    'Annuler',
                    style: TextStyle(color: d_colorOr, fontSize: 16),
                  ),
                  onPressed: () {
                    _searchController.clear();
                    Navigator.of(context).pop();
                  },
                ),
                TextButton(
                  child: const Text(
                    'Valider',
                    style: TextStyle(color: d_colorOr, fontSize: 16),
                  ),
                  onPressed: () {
                    _searchController.clear();
                    print('Options sélectionnées : $speculation');
                    Navigator.of(context).pop();
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showLocalite() async {
    final BuildContext context = this.context;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Padding(
                padding: const EdgeInsets.all(10.0),
                child: TextField(
                  controller: _searchController,
                  onChanged: (value) {
                    if (mounted) setState(() {});
                  },
                  decoration: InputDecoration(
                    hintText: 'Rechercher une localité',
                    border: UnderlineInputBorder(
                      borderSide: BorderSide(
                        color: Colors.grey[300]!,
                        width: 1,
                      ),
                    ),
                    suffixIcon: const Icon(Icons.search),
                  ),
                ),
              ),
              content: FutureBuilder(
                future: _niveau3List,
                builder: (_, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (snapshot.hasError) {
                    return const Center(
                      child: Text("Erreur lors du chargement des données"),
                    );
                  }

                  if (snapshot.hasData) {
                    final responseData =
                        json.decode(utf8.decode(snapshot.data.bodyBytes));
                    if (responseData is List) {
                      List<Niveau3Pays> typeListe = responseData
                          .map((e) => Niveau3Pays.fromMap(e))
                          .where((con) => con.statutN3 == true)
                          .toList();

                      if (typeListe.isEmpty) {
                        return const Padding(
                          padding: EdgeInsets.all(10),
                          child: Center(child: Text("Aucune localité trouvée")),
                        );
                      }

                      String searchText = _searchController.text.toLowerCase();
                      List<Niveau3Pays> filteredSearch = typeListe
                          .where((type) =>
                              type.nomN3.toLowerCase().contains(searchText))
                          .toList();

                      return filteredSearch.isEmpty
                          ? const Text(
                              'Aucune localité trouvée',
                              style:
                                  TextStyle(color: Colors.black, fontSize: 17),
                            )
                          : SizedBox(
                              width: double.maxFinite,
                              child: ListView.builder(
                                itemCount: filteredSearch.length,
                                itemBuilder: (context, index) {
                                  final type = filteredSearch[index].nomN3;
                                  final isSelected =
                                      _localiteController.text == type;

                                  return Column(
                                    children: [
                                      ListTile(
                                        title: Text(
                                          type,
                                          style: TextStyle(
                                            color: Colors.black,
                                            fontWeight: isSelected
                                                ? FontWeight.bold
                                                : FontWeight.normal,
                                            fontSize: 16,
                                          ),
                                        ),
                                        trailing: isSelected
                                            ? const Icon(
                                                Icons.check_box_outlined,
                                                color: d_colorOr,
                                              )
                                            : null,
                                        onTap: () {
                                          setState(() {
                                            niveau3 = type;
                                            _localiteController.text = type;
                                          });
                                        },
                                      ),
                                      Divider()
                                    ],
                                  );
                                },
                              ),
                            );
                    }
                  }

                  return const SizedBox(height: 8);
                },
              ),
              actions: <Widget>[
                TextButton(
                  child: const Text(
                    'Annuler',
                    style: TextStyle(color: d_colorOr, fontSize: 16),
                  ),
                  onPressed: () {
                    _searchController.clear();
                    Navigator.of(context).pop();
                  },
                ),
                TextButton(
                  child: const Text(
                    'Valider',
                    style: TextStyle(color: d_colorOr, fontSize: 16),
                  ),
                  onPressed: () {
                    _searchController.clear();
                    print('Options sélectionnées : $niveau3');
                    Navigator.of(context).pop();
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }
}
