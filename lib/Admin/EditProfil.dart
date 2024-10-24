import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:koumi/constants.dart';
import 'package:koumi/models/Acteur.dart';
import 'package:koumi/models/Speculation.dart';
import 'package:koumi/models/TypeActeur.dart';
import 'package:koumi/providers/ActeurProvider.dart';
import 'package:koumi/service/ActeurService.dart';
import 'package:koumi/widgets/LoadingOverlay.dart';
import 'package:multi_dropdown/multiselect_dropdown.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:profile_photo/profile_photo.dart';
import 'package:provider/provider.dart';

class EditProfil extends StatefulWidget {
  Acteur? acteurs;
  EditProfil({super.key, this.acteurs});

  @override
  State<EditProfil> createState() => _EditProfilState();
}

const d_colorGreen = Color.fromRGBO(43, 103, 6, 1);
const d_colorOr = Color.fromRGBO(255, 138, 0, 1);
const d_colorPage = Color.fromRGBO(255, 255, 255, 1);

class _EditProfilState extends State<EditProfil> {
  TextEditingController nomActeurController = TextEditingController();
  TextEditingController whatsAppController = TextEditingController();
  TextEditingController telephoneActeurController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController localisationController = TextEditingController();
  TextEditingController adresseController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController confirmPasswordController = TextEditingController();
  MultiSelectController _controllerTypeActeur = MultiSelectController();
  // MultiSelectController mdpController = MultiSelectController();
  // MultiSelectController confirmerController = MultiSelectController();
  MultiSelectController _controllerSpeculation = MultiSelectController();
  List<TypeActeur> typeActeur = [];
  final _tokenTextController = TextEditingController();

  bool isEditing = false;
  bool _isLoading = false;
  bool _obscureText = true;
  late Acteur acteur;
  String? imageSrc;
  File? photo;
  late List<TypeActeur> typeActeurData = [];
  late String type;
  List<TypeActeur> selectedTypes = [];
  List<Speculation> selectedSpec = [];
  List<String> specu = [];
  List<String> typeLibelle = [];
  List<String> libelleSpeculation = [];
  List<Speculation> listeSpeculations = [];

  Future<File> saveImagePermanently(String imagePath) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final name = path.basename(imagePath);
      final image = File('${directory.path}/$name');
      return File(imagePath).copy(image.path);
    } catch (e) {
      // Gérer l'exception
      print('Erreur lors de la sauvegarde de l\'image : $e');
      rethrow;
    }
  }

  Future<File?> getImage(ImageSource source) async {
    try {
      final image = await ImagePicker().pickImage(source: source);
      if (image == null) return null;
      return File(image.path);
    } catch (e) {
      // Gérer l'exception
      print('Erreur lors de la sélection de l\'image : $e');
      return null;
    }
  }

  Future<void> _pickImage(ImageSource source) async {
    final image = await getImage(source);
    if (image != null) {
      setState(() {
        photo = image;
        imageSrc = image.path;
      });
      await saveImagePermanently(image.path);
    }
  }

  Future<void> _showImageSourceDialog() async {
    final BuildContext context = this.context;
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Photo d'identité"),
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
        );
      },
    );
  }

  void toggleEditing() {
    setState(() {
      isEditing = !isEditing; // Inverse l'état d'édition
    });
  }

  @override
  void initState() {
    super.initState();
    acteur = widget.acteurs!;
    nomActeurController.text = acteur.nomActeur!;
    whatsAppController.text = acteur.whatsAppActeur!;
    telephoneActeurController.text = acteur.telephoneActeur!;
    localisationController.text = acteur.localiteActeur!;
    adresseController.text = acteur.adresseActeur!;

    if (acteur.emailActeur != null) {
      emailController.text = acteur.emailActeur!;
      print("email : ${acteur.emailActeur}");
    }

    if (acteur.speculation != null) {
      selectedSpec = acteur.speculation!;
      libelleSpeculation = selectedSpec.map((e) => e.nomSpeculation!).toList();

      print("speculation acteur: ${selectedSpec.toString()}");
    }
    print("niveau 3 : ${acteur.niveau3PaysActeur!}");
    typeActeur = acteur.typeActeur!;
    typeLibelle = typeActeur.map((e) => e.libelle!).toList();
    selectedTypes = typeActeur;
    // print("speculation acteur: ${acteur.speculations!}");
    print("type acteur : ${typeActeur.toString()}");

    print("type libelle : ${typeLibelle}");
  }

  @override
  void dispose() {
    _controllerTypeActeur.dispose();
    _controllerSpeculation.dispose();
    super.dispose();
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
            icon: const Icon(Icons.arrow_back_ios, color: d_colorGreen),
          ),
          title: const Text(
            "Modification de Profil",
            style: TextStyle(color: d_colorGreen, fontWeight: FontWeight.bold),
          ),
        ),
        body: SingleChildScrollView(
          child: Column(
            children: [
              Row(
                children: [
                  SizedBox(width: 15),
                  SizedBox(height: 10),
                  photo != null
                      ? Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: SizedBox(
                            height: 100,
                            width: 100,
                            child: Image.file(
                              photo!,
                              height: 100,
                              width: 200,
                              fit: BoxFit.cover,
                            ),
                          ))
                      : Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: acteur.logoActeur == null ||
                                  acteur.logoActeur!.isEmpty
                              ? ProfilePhoto(
                                  totalWidth: 100,
                                  cornerRadius: 100,
                                  color: Colors.black,
                                  image: const AssetImage(
                                      'assets/images/profil.jpg'),
                                )
                              : ProfilePhoto(
                                  totalWidth: 100,
                                  cornerRadius: 100,
                                  color: Colors.black,
                                  image: NetworkImage(
                                      "https://koumi.ml/api-koumi/acteur/${acteur.idActeur}/image"),
                                ),
                        ),
                  TextButton(
                      onPressed: () {
                        _showImageSourceDialog();
                      },
                      // onHover : true,
                      child: Text(
                        "Changer le logo",
                        style: TextStyle(
                            fontSize: 18,
                            color: d_colorOr,
                            fontWeight: FontWeight.w900),
                      ))
                ],
              ),
              SizedBox(
                height: 20,
              ),
              Padding(
                padding: const EdgeInsets.all(10.0),
                child: TextFormField(
                  controller: nomActeurController,
                  decoration: InputDecoration(
                    labelText: "Nom complet",
                    contentPadding: const EdgeInsets.symmetric(
                        vertical: 10, horizontal: 20),
                    // hintText: "Entrez votre prenom et nom",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  keyboardType: TextInputType.text,
                  validator: (val) {
                    if (val == null || val.isEmpty) {
                      return "Veillez entrez votre prenom et nom";
                    } else {
                      return null;
                    }
                  },
                ),
              ),
              SizedBox(
                height: 5,
              ),
              Padding(
                padding: const EdgeInsets.all(10.0),
                child: MultiSelectDropDown.network(
                  networkConfig: NetworkConfig(
                    url: '$apiOnlineUrl/typeActeur/read',
                    method: RequestMethod.get,
                    headers: {
                      'Content-Type': 'application/json',
                    },
                  ),

                  chipConfig: const ChipConfig(wrapType: WrapType.wrap),
                  responseParser: (response) {
                    typeActeur = (response as List<dynamic>)
                        .where((data) =>
                            (data['libelle']).trim().toLowerCase() != 'admin')
                        .map((e) {
                      return TypeActeur(
                        idTypeActeur: e['idTypeActeur'] as String,
                        libelle: e['libelle'] as String,
                        statutTypeActeur: e['statutTypeActeur'] as bool,
                      );
                    }).toList();

                    // Filtrer les types avec un libellé différent de "admin" et dont le statutTypeActeur est true
                    final filteredTypes = typeActeur
                        .where((typeActeur) =>
                            typeActeur.libelle != "admin" ||
                            typeActeur.libelle != "Admin" &&
                                typeActeur.statutTypeActeur == true)
                        .toList();

                    // Créer des ValueItems pour les types filtrés
                    final List<ValueItem<TypeActeur>> valueItems =
                        filteredTypes.map((typeActeur) {
                      return ValueItem<TypeActeur>(
                        label: typeActeur.libelle!,
                        value: typeActeur,
                      );
                    }).toList();

                    return Future<List<ValueItem<TypeActeur>>>.value(
                        valueItems);
                  },

                  controller: _controllerTypeActeur,

                  dropdownHeight: 320,
                  hint: typeLibelle.map((e) => e).join(','),

                  fieldBackgroundColor: Color.fromARGB(255, 228, 227, 227),
                  searchEnabled: false,
                  searchLabel: "Search",
                  onOptionSelected: (options) {
                    if (mounted) {
                      setState(() {
                        typeLibelle.clear();
                        typeLibelle
                            .addAll(options.map((data) => data.label).toList());
                        selectedTypes = options
                            .map<TypeActeur>((item) => item.value!)
                            .toList();
                        print("Types sélectionnés : $selectedTypes");

                        print("Libellé sélectionné ${typeLibelle.toString()}");
                      });
                    }
                  },
                  responseErrorBuilder: ((context, body) {
                    return const Padding(
                      padding: EdgeInsets.all(10.0),
                      child: Text('Aucun type disponible'),
                    );
                  }),
                  // Exemple de personnalisation des styles
                ),
              ),
              SizedBox(
                height: 5,
              ),
              Padding(
                padding: const EdgeInsets.all(10.0),
                child: MultiSelectDropDown.network(
                  networkConfig: NetworkConfig(
                    url:
                        '$apiOnlineUrl/Speculation/getAllSpeculation', //e40ijxd5k0n0yrzj5f80,
                    method: RequestMethod.get,
                    headers: {'Content-Type': 'application/json'},
                  ),
                  chipConfig: const ChipConfig(wrapType: WrapType.wrap),
                  responseParser: (response) {
                    // List<dynamic> decodedResponse = jsonDecode(utf8.decode(response.bodyBytes));

                    listeSpeculations = (response as List<dynamic>).map((e) {
                      return Speculation(
                        idSpeculation: e['idSpeculation'] as String,
                        nomSpeculation: e['nomSpeculation'] as String,
                        statutSpeculation: e['statutSpeculation'] as bool,
                        // Assurez-vous de correspondre aux clés JSON avec les noms de propriétés de votre classe TypeActeur
                        // Ajoutez d'autres champs si nécessaire
                      );
                    }).toList();

                    // Filtrer les types avec un libellé différent de "admin" et dont le statutTypeActeur est true
                    final filteredTypes = listeSpeculations
                        .where((speculation) =>
                            speculation.statutSpeculation == true)
                        .toList();

                    // Créer des ValueItems pour les types filtrés
                    final List<ValueItem<Speculation>> valueItems =
                        filteredTypes.map((speculation) {
                      return ValueItem<Speculation>(
                        label: speculation.nomSpeculation!,
                        value: speculation,
                      );
                    }).toList();

                    return Future<List<ValueItem<Speculation>>>.value(
                        valueItems);
                  },

                  controller: _controllerSpeculation,
                  hint: libelleSpeculation.map((e) => e).join(', '),

                  dropdownHeight: 320,
                  fieldBackgroundColor: Color.fromARGB(255, 228, 227, 227),
                  onOptionSelected: (options) {
                    setState(() {
                      selectedSpec = options
                          .map<Speculation>((item) => item.value!)
                          .toList();

                      print("Types sélectionnés : $selectedSpec");
                      libelleSpeculation.clear();
                      libelleSpeculation
                          .addAll(options.map((data) => data.label).toList());
                      print(
                          "Spéculation sélectionnée ${libelleSpeculation.toString()}");
                    });
                    // Fermer automatiquement le dialogue
                    // FocusScope.of(context).unfocus();
                  },
                  responseErrorBuilder: ((context, body) {
                    return const Padding(
                      padding: EdgeInsets.all(10.0),
                      child: Text('Aucune spéculation disponible'),
                    );
                  }),
                  // Exemple de personnalisation des styles
                ),
              ),
              SizedBox(
                height: 5,
              ),
              Padding(
                padding: const EdgeInsets.all(10.0),
                child: TextFormField(
                  controller: emailController,
                  decoration: InputDecoration(
                    labelText: "Email",
                    contentPadding: const EdgeInsets.symmetric(
                        vertical: 10, horizontal: 20),
                    // hintText: "Entrez votre prenom et nom",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  keyboardType: TextInputType.text,
                  validator: (val) {
                    if (val == null || val.isEmpty) {
                      return "Veillez entrez votre prenom et nom";
                    } else {
                      return null;
                    }
                  },
                  // onSaved: (val) => nomActeur = val!,
                ),
              ),
              SizedBox(
                height: 5,
              ),
              Padding(
                padding: const EdgeInsets.all(10.0),
                child: TextFormField(
                  controller: whatsAppController,
                  decoration: InputDecoration(
                    labelText: "Numéro wathsApp",
                    contentPadding: const EdgeInsets.symmetric(
                        vertical: 10, horizontal: 20),
                    // hintText: "Entrez votre prenom et nom",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  keyboardType: TextInputType.text,
                  validator: (val) {
                    if (val == null || val.isEmpty) {
                      return "Veillez entrez votre prenom et nom";
                    } else {
                      return null;
                    }
                  },
                  // onSaved: (val) => nomActeur = val!,
                ),
              ),
              SizedBox(
                height: 5,
              ),
              Padding(
                padding: const EdgeInsets.all(10.0),
                child: TextFormField(
                  controller: telephoneActeurController,
                  decoration: InputDecoration(
                    labelText: "Numéro",
                    contentPadding: const EdgeInsets.symmetric(
                        vertical: 10, horizontal: 20),
                    // hintText: "Entrez votre prenom et nom",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  keyboardType: TextInputType.text,
                  validator: (val) {
                    if (val == null || val.isEmpty) {
                      return "Veillez entrez votre prenom et nom";
                    } else {
                      return null;
                    }
                  },
                  // onSaved: (val) => nomActeur = val!,
                ),
              ),
              SizedBox(
                height: 5,
              ),
              Padding(
                padding: const EdgeInsets.all(10.0),
                child: TextFormField(
                  controller: localisationController,
                  decoration: InputDecoration(
                    labelText: "Localité",
                    contentPadding: const EdgeInsets.symmetric(
                        vertical: 10, horizontal: 20),
                    // hintText: "Entrez votre prenom et nom",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  keyboardType: TextInputType.text,
                  validator: (val) {
                    if (val == null || val.isEmpty) {
                      return "Veillez entrez votre prenom et nom";
                    } else {
                      return null;
                    }
                  },
                  // onSaved: (val) => nomActeur = val!,
                ),
              ),
              SizedBox(
                height: 5,
              ),
              Padding(
                padding: const EdgeInsets.all(10.0),
                child: TextFormField(
                  controller: adresseController,
                  decoration: InputDecoration(
                    labelText: "Adresse",
                    contentPadding: const EdgeInsets.symmetric(
                        vertical: 10, horizontal: 20),
                    // hintText: "Entrez votre prenom et nom",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  keyboardType: TextInputType.text,
                  validator: (val) {
                    if (val == null || val.isEmpty) {
                      return "Veillez entrez votre prenom et nom";
                    } else {
                      return null;
                    }
                  },
                  // onSaved: (val) => nomActeur = val!,
                ),
              ),
              SizedBox(
                height: 10,
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: ElevatedButton(
                  onPressed: () async {
                    final nomActeur = nomActeurController.text;
                    final emailActeur = emailController.text;
                    final String? adresse = adresseController.text;
                    final localisation = localisationController.text;
                    final typeActeur = selectedTypes;
                    final spec = selectedSpec;
                    final whatsApp = whatsAppController.text;
                    final tel = telephoneActeurController.text;
                    print(
                        "acteur edit  nom : ${nomActeur} ,email ${emailActeur},adresse: ${adresse},loc: $localisation, type : ${selectedTypes.toList()} , speculation ${spec.toList()} , wa : ${whatsApp}, tel : ${tel}");

                    ActeurProvider acteurProvider =
                        Provider.of<ActeurProvider>(context, listen: false);
                    try {
                      setState(() {
                        _isLoading = true;
                      });
                      if (photo != null) {
                        var response = await ActeurService().updateActeur(
                          idActeur: acteur.idActeur!,
                          nomActeur: nomActeur,
                          adresseActeur: adresse!,
                          telephoneActeur: tel,
                          whatsAppActeur: whatsApp,
                          localiteActeur: localisation,
                          emailActeur: emailActeur,
                          niveau3PaysActeur: acteur.niveau3PaysActeur!,
                          typeActeur:
                              typeActeur, // Passez les objets TypeActeur ici
                          speculation:
                              spec, // Passez les objets Speculation ici
                          // password: password,
                          photo:
                              photo, // Assurez-vous que cette variable est définie si nécessaire
                        );

                        if (response.statusCode == 200 ||
                            response.statusCode == 201) {
                          setState(() {
                            _isLoading = false;
                            final responseBody =
                                json.decode(utf8.decode(response.bodyBytes));
                            print("response body ${responseBody.toString()}");

                            List<dynamic> typeActeurData =
                                responseBody['typeActeur'];
                            List<TypeActeur> typeActeurList = typeActeurData
                                .map((data) => TypeActeur.fromMap(data))
                                .toList();
                            List<dynamic> speculationData =
                                responseBody['speculation'];
                            List<Speculation> speculationsList = speculationData
                                .map((data) => Speculation.fromMap(data))
                                .toList();

                            Acteur acteurs = Acteur(
                              idActeur: responseBody['idActeur'],
                              resetToken: responseBody['resetToken'],
                              tokenCreationDate:
                                  responseBody['tokenCreationDate'],
                              codeActeur: responseBody['codeActeur'],
                              nomActeur: responseBody['nomActeur'],
                              adresseActeur: responseBody['adresseActeur'],
                              telephoneActeur: responseBody['telephoneActeur'],
                              latitude: responseBody['latitude'],
                              longitude: responseBody['longitude'],
                              photoSiegeActeur:
                                  responseBody['photoSiegeActeur'],
                              logoActeur: responseBody['logoActeur'],
                              whatsAppActeur: responseBody['whatsAppActeur'],
                              niveau3PaysActeur:
                                  responseBody['niveau3PaysActeur'],
                              dateAjout: responseBody['dateAjout'],
                              dateModif: responseBody['dateModif'],
                              personneModif: responseBody['personneModif'],
                              localiteActeur: responseBody['localiteActeur'],
                              emailActeur: emailActeur,
                              statutActeur: responseBody['statutActeur'],
                              typeActeur: typeActeurList,
                              speculation: speculationsList,
                              password: responseBody['password'],
                            );

                            acteurProvider.setActeur(acteurs);
                          });

                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text("Profil modifié avec succès"),
                              duration: Duration(seconds: 5),
                            ),
                          );
                        } else {
                          setState(() {
                            _isLoading = false;
                          });
                          print("Erreur HTTP: ${response.statusCode}  ");
                          throw Exception(
                              "Erreur HTTP: ${response.statusCode}");
                        }
                      } else {
                        var response = await ActeurService().updateActeur(
                          idActeur: acteur.idActeur!,
                          nomActeur: nomActeur,
                          adresseActeur: adresse!,
                          telephoneActeur: tel,
                          whatsAppActeur: whatsApp,
                          localiteActeur: localisation,
                          emailActeur: emailActeur,
                          niveau3PaysActeur: acteur.niveau3PaysActeur!,
                          typeActeur:
                              typeActeur, // Passez les objets TypeActeur ici
                          speculation:
                              spec, // Passez les objets Speculation ici
                          // password: password,
                        );

                        if (response.statusCode == 200 ||
                            response.statusCode == 201) {
                          setState(() {
                            _isLoading = false;
                            final responseBody =
                                json.decode(utf8.decode(response.bodyBytes));
                            print("response body ${responseBody.toString()}");

                            List<dynamic> typeActeurData =
                                responseBody['typeActeur'];
                            List<TypeActeur> typeActeurList = typeActeurData
                                .map((data) => TypeActeur.fromMap(data))
                                .toList();
                            List<dynamic> speculationData =
                                responseBody['speculation'];
                            List<Speculation> speculationsList = speculationData
                                .map((data) => Speculation.fromMap(data))
                                .toList();

                            Acteur acteurs = Acteur(
                              idActeur: responseBody['idActeur'],
                              resetToken: responseBody['resetToken'],
                              tokenCreationDate:
                                  responseBody['tokenCreationDate'],
                              codeActeur: responseBody['codeActeur'],
                              nomActeur: responseBody['nomActeur'],
                              adresseActeur: responseBody['adresseActeur'],
                              telephoneActeur: responseBody['telephoneActeur'],
                              latitude: responseBody['latitude'],
                              longitude: responseBody['longitude'],
                              photoSiegeActeur:
                                  responseBody['photoSiegeActeur'],
                              logoActeur: responseBody['logoActeur'],
                              whatsAppActeur: responseBody['whatsAppActeur'],
                              niveau3PaysActeur:
                                  responseBody['niveau3PaysActeur'],
                              dateAjout: responseBody['dateAjout'],
                              dateModif: responseBody['dateModif'],
                              personneModif: responseBody['personneModif'],
                              localiteActeur: responseBody['localiteActeur'],
                              emailActeur: emailActeur,
                              statutActeur: responseBody['statutActeur'],
                              typeActeur: typeActeurList,
                              speculation: speculationsList,
                              password: responseBody['password'],
                            );

                            acteurProvider.setActeur(acteurs);
                          });
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text("Profil modifié avec succès"),
                              duration: Duration(seconds: 5),
                            ),
                          );
                        } else {
                          setState(() {
                            _isLoading = false;
                          });
                          print("Erreur 2 HTTP: ${response.statusCode}");
                          throw Exception(
                              "Erreur HTTP: ${response.statusCode}");
                        }
                      }
                    } catch (e) {
                      var response = await ActeurService().updateActeur(
                        idActeur: acteur.idActeur!,
                        nomActeur: nomActeur,
                        adresseActeur: adresse!,
                        telephoneActeur: tel,
                        whatsAppActeur: whatsApp,
                        localiteActeur: localisation,
                        emailActeur: emailActeur,
                        niveau3PaysActeur: acteur.niveau3PaysActeur!,
                        typeActeur:
                            typeActeur, // Passez les objets TypeActeur ici
                        speculation: spec, // Passez les objets Speculation ici
                      );

                      if (response.statusCode == 200 ||
                          response.statusCode == 201) {
                        setState(() {
                          _isLoading = false;
                          final responseBody =
                              json.decode(utf8.decode(response.bodyBytes));
                          print("response body ${responseBody.toString()}");

                          List<dynamic> typeActeurData =
                              responseBody['typeActeur'];
                          List<TypeActeur> typeActeurList = typeActeurData
                              .map((data) => TypeActeur.fromMap(data))
                              .toList();
                          List<dynamic> speculationData =
                              responseBody['speculation'];
                          List<Speculation> speculationsList = speculationData
                              .map((data) => Speculation.fromMap(data))
                              .toList();

                          Acteur acteurs = Acteur(
                            idActeur: responseBody['idActeur'],
                            resetToken: responseBody['resetToken'],
                            tokenCreationDate:
                                responseBody['tokenCreationDate'],
                            codeActeur: responseBody['codeActeur'],
                            nomActeur: responseBody['nomActeur'],
                            adresseActeur: responseBody['adresseActeur'],
                            telephoneActeur: responseBody['telephoneActeur'],
                            latitude: responseBody['latitude'],
                            longitude: responseBody['longitude'],
                            photoSiegeActeur: responseBody['photoSiegeActeur'],
                            logoActeur: responseBody['logoActeur'],
                            whatsAppActeur: responseBody['whatsAppActeur'],
                            niveau3PaysActeur:
                                responseBody['niveau3PaysActeur'],
                            dateAjout: responseBody['dateAjout'],
                            dateModif: responseBody['dateModif'],
                            personneModif: responseBody['personneModif'],
                            localiteActeur: responseBody['localiteActeur'],
                            emailActeur: emailActeur,
                            statutActeur: responseBody['statutActeur'],
                            typeActeur: typeActeurList,
                            speculation: speculationsList,
                            password: responseBody['password'],
                          );

                          acteurProvider.setActeur(acteurs);
                        });

                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text("Profil  modifié avec succès"),
                            duration: Duration(seconds: 5),
                          ),
                        );
                      } else {
                        setState(() {
                          _isLoading = false;
                        });
                        print("Erreur HTTP: ${response.statusCode}  ");
                        throw Exception("Erreur HTTP: ${response.statusCode}");
                      }
                    }
                  },
                  child: Text(
                    "Modifier",
                    style: TextStyle(
                      fontSize: 20,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        const Color(0xFFFF8A00), // Code couleur orange
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    minimumSize: Size(250, 40),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
