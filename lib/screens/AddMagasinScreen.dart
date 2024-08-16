import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:koumi/constants.dart';
import 'package:koumi/models/Acteur.dart';
import 'package:koumi/models/Niveau1Pays.dart';
import 'package:koumi/providers/ActeurProvider.dart';
import 'package:koumi/service/MagasinService.dart';
import 'package:koumi/widgets/LoadingOverlay.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';

class AddMagasinScreen extends StatefulWidget {
  bool? isEditable;
  String? nomMagasin = "";
  String? contactMagasin = "";
  String? localiteMagasin = "";
  String? idMagasin = "";
  File? photo;
  late Niveau1Pays? niveau1Pays;

  AddMagasinScreen(
      {super.key,
      this.isEditable,
      this.idMagasin,
      this.nomMagasin,
      this.contactMagasin,
      this.localiteMagasin,
      this.photo,
      this.niveau1Pays});

  @override
  State<AddMagasinScreen> createState() => _AddMagasinScreenState();
}

class _AddMagasinScreenState extends State<AddMagasinScreen> {
  late Acteur acteur = Acteur();
  String nomMagasin = "";
  String contactMagasin = "";
  // String niveau3PaysMagasin = "";
  String localiteMagasin = "";

  File? photos;
  String? imageSrc;
  String? libelleNiveau1Pays;

  Niveau1Pays niveau1Pays = Niveau1Pays();

  List<String> regions = [];
  String? niveauPaysValue;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  TextEditingController nomMagasinController = TextEditingController();
  TextEditingController contactMagasinController = TextEditingController();
  TextEditingController localiteMagasinController = TextEditingController();
  // late ParametreGeneraux para;
  // List<ParametreGeneraux> paraList = [];
  List<Map<String, dynamic>> regionsData = [];
  bool isLoading = false;
  bool isLoadingLibelle = true;

  late Future niveau1PaysList;
  final String message = "Encore quelques secondes";

  Set<String> loadedRegions =
      {}; // Ensemble pour garder une trace des régions pour lesquelles les magasins ont déjà été chargés

  Future<String> getLibelleNiveau1PaysByActor(String id) async {
    final response = await http
        .get(Uri.parse('$apiOnlineUrl/acteur/libelleNiveau1Pays/$id'));

    if (response.statusCode == 200) {
      print("libelle : ${response.body}");
      return response
          .body; // Return the body directly since it's a plain string
    } else {
      throw Exception('Failed to load libelle niveau1Pays');
    }
  }

  Future<void> fetchLibelleNiveau1Pays() async {
    try {
      String libelle = await getLibelleNiveau1PaysByActor(acteur.idActeur!);
      setState(() {
        libelleNiveau1Pays = libelle;
        isLoadingLibelle = false;
      });
    } catch (e) {
      setState(() {
        isLoadingLibelle = false;
      });
      print('Error: $e');
    }
  }

  Future<void> updateMagasin() async {
    final nomMagasin = nomMagasinController.text;
    final contactMagasin = contactMagasinController.text;
    final localiteMagasin = localiteMagasinController.text;
    MagasinService magasinService = MagasinService();
    try {
      if (photos != null) {
        await magasinService
            .updateMagasin(
                idMagasin: widget.idMagasin!,
                nomMagasin: nomMagasin,
                contactMagasin: contactMagasin,
                localiteMagasin: localiteMagasin,
                photo: widget.photo,
                acteur: acteur,
                niveau1Pays: niveau1Pays)
            .then((value) => showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: const Center(child: Text('Succès')),
                      content: const Text("Magasin mis à jour avec succès"),
                      actions: <Widget>[
                        TextButton(
                          onPressed: () {
                             Navigator.pop(context, true);
                            nomMagasinController.clear();
                            contactMagasinController.clear();
                            localiteMagasinController.clear();
                          },
                          child: const Text('OK'),
                        ),
                      ],
                    );
                  },
                ));
      } else {
        await magasinService
            .updateMagasin(
                idMagasin: widget.idMagasin!,
                nomMagasin: nomMagasin,
                contactMagasin: contactMagasin,
                localiteMagasin: localiteMagasin,
                acteur: acteur,
                niveau1Pays: niveau1Pays)
            .then((value) => showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: const Center(child: Text('Succès')),
                      content: const Text("Magasin mis à jour avec succès"),
                      actions: <Widget>[
                        TextButton(
                          onPressed: () {
                            Navigator.pop(context, true);
                            nomMagasinController.clear();
                            contactMagasinController.clear();
                            localiteMagasinController.clear();
                          },
                          child: const Text('OK'),
                        ),
                      ],
                    );
                  },
                ));
      }
    } catch (e) {
      debugPrint("Erreur : $e");
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Center(child: Text('Erreur')),
            content: Text("Une erreur s'est produite veuiller réessayer $e"),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text('OK'),
              ),
            ],
          );
        },
      );
    }
  }

  void _handleButtonPress() async {
    // Afficher l'indicateur de chargement
    setState(() {
      isLoading = true;
    });

    if (widget.isEditable! == false) {
      await addMagasin().then((_) {
        // Cacher l'indicateur de chargement lorsque votre fonction est terminée
        setState(() {
          isLoading = false;
        });
        // Provider.of<MagasinService>(context, listen: false).applyChange();
        //  Navigator.of(context).pop();
      });
    } else {
      await updateMagasin().then((_) {
        // Cacher l'indicateur de chargement lorsque votre fonction est terminée
        setState(() {
          isLoading = false;
        });
        // Navigator.of(context).pop();
      });
    }
  }

  Future<void> addMagasin() async {
    final nomMagasin = nomMagasinController.text;
    final contactMagasin = contactMagasinController.text;
    final localiteMagasin = localiteMagasinController.text;
    MagasinService magasinService = MagasinService();
    try {
      if (photos != null) {
        await magasinService
            .creerMagasin(
                nomMagasin: nomMagasin,
                contactMagasin: contactMagasin,
                localiteMagasin: localiteMagasin,
                pays: acteur.niveau3PaysActeur!,
                photo: photos,
                acteur: acteur,
                niveau1Pays: niveau1Pays)
            .then((value) => {
                  Provider.of<MagasinService>(context, listen: false)
                      .applyChange(),
                  Navigator.pop(context, true),
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Row(
                        children: [
                          Text("Ajouté avec succèss "),
                        ],
                      ),
                      duration: Duration(seconds: 2),
                    ),
                  ),
                  nomMagasinController.clear(),
                  contactMagasinController.clear(),
                  localiteMagasinController.clear(),
                  setState(() {
                    // niveau1Pays == null;
                    photos == null;
                  }),
                });
      } else {
        await magasinService
            .creerMagasin(
                nomMagasin: nomMagasin,
                contactMagasin: contactMagasin,
                localiteMagasin: localiteMagasin,
                pays: acteur.niveau3PaysActeur!,
                acteur: acteur,
                niveau1Pays: niveau1Pays)
            .then((value) => {
                  Provider.of<MagasinService>(context, listen: false)
                      .applyChange(),
                  Navigator.pop(context, true),
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Row(
                        children: [
                          Text("Ajouté avec succèss "),
                        ],
                      ),
                      duration: Duration(seconds: 2),
                    ),
                  ),
                  nomMagasinController.clear(),
                  contactMagasinController.clear(),
                  localiteMagasinController.clear(),
                  setState(() {
                    niveauPaysValue == "Sélectionner une région";
                  }),
                });
      }
    } catch (e) {
      debugPrint("Erreur : $e");
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Center(child: Text('Erreur')),
            content: Text("Une erreur s'est produite veuiller réessayer "),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text('OK'),
              ),
            ],
          );
        },
      );
    }
  }

  Future<File> saveImagePermanently(String imagePath) async {
    final directory = await getApplicationDocumentsDirectory();
    final name = path.basename(imagePath);
    final image = File('${directory.path}/$name');

    return File(imagePath).copy(image.path);
  }

  Future<File?> getImage(ImageSource source) async {
    final image = await ImagePicker().pickImage(source: source);
    if (image == null) return null;

    return File(image.path);
  }

  Future<void> _pickImage(ImageSource source) async {
    final image = await getImage(source);
    if (image != null) {
      setState(() {
        this.photos = image;
        imageSrc = image.path;
      });
    }
  }

  Future<void> _showImageSourceDialog() async {
    final BuildContext context = this.context;
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return SizedBox(
          height: 150,
          child: AlertDialog(
            title: Text("Choisir une source"),
            content: Wrap(
              alignment: WrapAlignment.center,
              children: [
                GestureDetector(
                  onTap: () {
                    Navigator.pop(context); // Fermer le dialogue
                    _pickImage(ImageSource.camera);
                  },
                  child: Column(
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
                  child: Column(
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
    if (widget.isEditable! == true) {
      nomMagasinController.text = widget.nomMagasin!;
      contactMagasinController.text = widget.contactMagasin!;
      localiteMagasinController.text = widget.localiteMagasin!;
      // photos = widget.photo!;
      niveau1Pays = widget.niveau1Pays!;
      niveauPaysValue = widget.niveau1Pays!.idNiveau1Pays;
      debugPrint("Id Magasin " +
          widget.idMagasin! +
          "bool" +
          widget.isEditable!.toString());
    }
    debugPrint("bool" + widget.isEditable!.toString());
    acteur = Provider.of<ActeurProvider>(context, listen: false).acteur!;
    niveau1PaysList = http.get(Uri.parse(
        '$apiOnlineUrl/niveau1Pays/listeNiveau1PaysByNomPays/${acteur.niveau3PaysActeur}'));
    debugPrint(
        '$apiOnlineUrl/niveau1Pays/listeNiveau1PaysByNomPays/${acteur.niveau3PaysActeur}');
    fetchLibelleNiveau1Pays();
  }

// hh
  @override
  Widget build(BuildContext context) {
    const d_colorGreen = Color.fromRGBO(43, 103, 6, 1);

    return LoadingOverlay(
      isLoading: isLoading,
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
            widget.isEditable! == false
                ? "Ajouter magasin"
                : "Modifier magasin",
            style: TextStyle(
                fontSize: 20, fontWeight: FontWeight.bold, color: Colors.green),
          ),
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.all(10),
            child: Container(
              child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      // Nom magasin
                      Padding(
                        padding: const EdgeInsets.all(8),
                        child: Align(
                            alignment: Alignment.topLeft,
                            child: Text(
                              "Nom Magasin *",
                              style: TextStyle(
                                  fontSize: 15, fontWeight: FontWeight.bold),
                            )),
                      ),
                      TextFormField(
                        controller: nomMagasinController,
                        decoration: InputDecoration(
                          contentPadding: const EdgeInsets.symmetric(
                              vertical: 10, horizontal: 20),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          hintText: "Entrez le nom du magasin",
                        ),
                        keyboardType: TextInputType.text,
                        validator: (val) {
                          if (val == null || val.isEmpty) {
                            return "Veillez entrez le nom du magasin";
                          } else {
                            return null;
                          }
                        },
                        onSaved: (val) => nomMagasin = val!,
                      ),
                      // fin  nom magasin
                      const SizedBox(height: 10),

                      //Contact magasin
                      Padding(
                        padding: const EdgeInsets.all(8),
                        child: Align(
                            alignment: Alignment.topLeft,
                            child: Text(
                              "Contact Magasin *",
                              style: TextStyle(
                                  fontSize: 15, fontWeight: FontWeight.bold),
                            )),
                      ),
                      TextFormField(
                        controller: contactMagasinController,
                        decoration: InputDecoration(
                          contentPadding: const EdgeInsets.symmetric(
                              vertical: 10, horizontal: 20),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          hintText: "Entrez le contact du magasin",
                        ),
                        keyboardType: TextInputType.text,
                        validator: (val) {
                          if (val == null || val.isEmpty) {
                            return "Veillez entrez le contact du magasin";
                          } else {
                            return null;
                          }
                        },
                        onSaved: (val) => contactMagasin = val!,
                      ),
                      // fin contact magasin
                      const SizedBox(height: 10),

                      //Contact magasin
                      isLoadingLibelle
                          ? Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Align(
                                  alignment: Alignment.topLeft,
                                  child: Text(
                                    "Chargement...",
                                    style: TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.bold),
                                  )),
                            )
                          : Padding(
                              padding: const EdgeInsets.all(8),
                              child: Align(
                                  alignment: Alignment.topLeft,
                                  child: Text(
                                    libelleNiveau1Pays != null
                                        ? libelleNiveau1Pays!.toString()
                                        : "Region *",
                                    style: TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.bold),
                                  )),
                            ),
                      FutureBuilder(
                        future: niveau1PaysList,
                        builder: (_, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return DropdownButtonFormField(
                              items: [],
                              onChanged: null,
                              decoration: InputDecoration(
                                labelText: 'En cours de chargement',
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
                              final niveau1List = reponse
                                  .map((e) => Niveau1Pays.fromMap(e))
                                  .where((con) => con.statutN1 == true)
                                  .toList();

                              if (niveau1List.isEmpty) {
                                return DropdownButtonFormField(
                                  items: [],
                                  onChanged: null,
                                  decoration: InputDecoration(
                                    labelText: 'Aucune région trouvée',
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
                                items: niveau1List
                                    .map(
                                      (e) => DropdownMenuItem(
                                        value: e.idNiveau1Pays,
                                        child: Text(e.nomN1!),
                                      ),
                                    )
                                    .toList(),
                                value: niveau1Pays.idNiveau1Pays,
                                onChanged: (newValue) {
                                  setState(() {
                                    niveau1Pays.idNiveau1Pays = newValue;
                                    if (newValue != null) {
                                      niveau1Pays = niveau1List.firstWhere(
                                        (niveau1Pays) =>
                                            niveau1Pays.idNiveau1Pays ==
                                            newValue,
                                      );
                                      print("niveau 1 : ${niveau1Pays}");
                                    }
                                  });
                                },
                                decoration: InputDecoration(
                                  labelText: widget.isEditable! == false
                                      ? 'Selectionner une région'
                                      : widget.niveau1Pays!.nomN1,
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
                                  labelText: 'Aucune région trouvé',
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
                              labelText: 'Aucune région trouvé',
                              contentPadding: const EdgeInsets.symmetric(
                                  vertical: 10, horizontal: 20),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 10),

                      //Contact localiteMagasin
                      Padding(
                        padding: const EdgeInsets.all(8),
                        child: Align(
                            alignment: Alignment.topLeft,
                            child: Text(
                              "Adresse Magasin *",
                              style: TextStyle(
                                  fontSize: 15, fontWeight: FontWeight.bold),
                            )),
                      ),
                      TextFormField(
                        controller: localiteMagasinController,
                        decoration: InputDecoration(
                          contentPadding: const EdgeInsets.symmetric(
                              vertical: 10, horizontal: 20),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          hintText: "Adresse du magasin",
                        ),
                        keyboardType: TextInputType.text,
                        validator: (val) {
                          if (val == null || val.isEmpty) {
                            return "Veillez entrez la localité du magasin";
                          } else {
                            return null;
                          }
                        },
                        onSaved: (val) => localiteMagasin = val!,
                      ),
                      // fin localite magasin

                      const SizedBox(
                        height: 10,
                      ),

                      (photos == null)
                          ? IconButton(
                              onPressed: _showImageSourceDialog,
                              icon: Icon(Icons.camera_alt_sharp),
                              iconSize: 50,
                            )
                          : Image.file(
                              photos!,
                              height: 100,
                              width: 200,
                              fit: BoxFit.cover,
                            ),
                      Text("Choisir une image"),

                      const SizedBox(
                        height: 10,
                      ),
                      Center(
                        child: ElevatedButton(
                          onPressed: () async {
                            // Handle button press action here
                            if (_formKey.currentState!.validate()) {
                              _handleButtonPress();
                              // debugPrint("n1 : ${niveau1Pays}");
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                const Color(0xFFFF8A00), // Orange color code
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                            minimumSize: const Size(250, 40),
                          ),
                          child: Text(
                            widget.isEditable! == false
                                ? " Ajouter "
                                : " Modifier ",
                            style: TextStyle(
                              fontSize: 20,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  )),
            ),
          ),
        ),
      ),
    );
  }
}
