import 'dart:convert';
import 'dart:io';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:koumi/constants.dart';
import 'package:koumi/models/Speculation.dart';
import 'package:koumi/models/TypeActeur.dart';
import 'package:koumi/screens/LoginSuccessScreen.dart';
import 'package:koumi/service/ActeurService.dart';
import 'package:koumi/service/BottomNavigationService.dart';
import 'package:koumi/widgets/BottomNavigationPage.dart';
import 'package:koumi/widgets/LoadingOverlay.dart';
import 'package:koumi/widgets/TermeConditionPage.dart';
import 'package:multi_dropdown/multiselect_dropdown.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class RegisterEndScreen extends StatefulWidget {
  String nomActeur, email, adresse, localistaion;
  String telephoneActeur, numeroWhatsApp, pays;
  // File? image1;
  late List<TypeActeur>? typeActeur;
  //  late List<TypeActeur> idTypeActeur;

  RegisterEndScreen(
      {super.key,
      required this.nomActeur,
      // this.image1,
      required this.email,
      required this.telephoneActeur,
      this.typeActeur,
      required this.adresse,
      required this.numeroWhatsApp,
      required this.localistaion,
      required this.pays});

  @override
  State<RegisterEndScreen> createState() => _RegisterEndScreenState();
}

const d_colorOr = Color.fromRGBO(255, 138, 0, 1);

class _RegisterEndScreenState extends State<RegisterEndScreen> {
  bool isLoading = false;
  String errorMessage = "";
  String exception = "";

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  //  final MultiSelectController _controllerCategorie = MultiSelectController();
  TextEditingController imageController = TextEditingController();
  final MultiSelectController _controllerCategorie = MultiSelectController();
  final MultiSelectController _controllerSpeculation = MultiSelectController();
  TextEditingController typeController = TextEditingController();

  String password = "";
  String confirmPassword = "";

  String filiere = "";
  String idsJson = "";
  bool _obscureText = true;
  List<String> libelleCategorie = [];
  List<String> libelleSpeculation = [];
  List<String> typeLibelle = [];
  List<String> selectedCategoryIds = [];
  List<Speculation> listeSpeculations = [];

  List<Speculation> selectedSpec = [];
  String responses = "";
  late Future _typeList;
  List<String> idsCategorieProduit = [];
  String idsCategorieProduitAsString = "";
  late TextEditingController _searchController;
  String? image2Src;
  File? image2;
  String pinStrength = "";
  double strength = 0;
  String pin = "";
  String url = "";
  List<Speculation> options = [];
  bool showStrengthIndicator = false;

  Future<File> saveImagePermanently(String imagePath) async {
    final directory = await getApplicationDocumentsDirectory();
    final name = basename(imagePath);
    final image = File('${directory.path}/$name');

    return File(imagePath).copy(image.path);
  }

  Future<File?> getImage(ImageSource source) async {
    final image = await ImagePicker().pickImage(source: source);
    if (image == null) return null;
    imageController.text = image.name;
    return File(image.path);
  }

  Future<void> _pickImage(ImageSource source) async {
    final image = await getImage(source);
    if (image != null) {
      setState(() {
        this.image2 = image;
        image2Src = image.path;
        imageController.text = image.path;
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
            title: Text("Photo du siège"),
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

  bool _isAgreed = false;
  TextEditingController passwordController = TextEditingController();
  TextEditingController confirmPasswordController = TextEditingController();

  // Fonction pour afficher la boîte de dialogue de chargement
  void _handleButtonPress(BuildContext context) async {
    // Afficher l'indicateur de chargement
    setState(() {
      isLoading = true;
    });
    await registerUser(context).then((_) {
      // Cacher l'indicateur de chargement lorsque votre fonction est terminée
      setState(() {
        isLoading = false;
      });
    });
  }

  void _saveUserToPrefs(String nomActeur, String codeActeur) async {
    final prefs = await SharedPreferences.getInstance();
    List<String>? acteurs = prefs.getStringList('acteur');

    // Si c'est la première fois que vous enregistrez des utilisateurs, initialisez la liste
    if (acteurs == null) {
      acteurs = [];
    }

    // Ajouter les informations de l'utilisateur actuel
    acteurs.add('$nomActeur|$codeActeur');
    prefs.setStringList('acteurs', acteurs);
  }

  void _showMultiSelectDialogt() async {
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
                    hintText: 'Rechercher une spéculation...',
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
                future: _typeList,
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
                              Center(child: Text("Aucune spéculation trouvé")),
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
                              'Aucune spéculation trouvé',
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
                                      selectedSpec.contains(type);

                                  return Column(
                                    children: [
                                      ListTile(
                                        title: Text(
                                          type.nomSpeculation!,
                                          style: TextStyle(
                                            color: isSelected
                                                ? d_colorOr
                                                : Colors.black,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16,
                                          ),
                                        ),
                                        trailing: Checkbox(
                                          activeColor: d_colorOr,
                                          value: isSelected,
                                          onChanged: (value) {
                                            setState(() {
                                              if (value == true) {
                                                selectedSpec.add(type);
                                              } else {
                                                selectedSpec.remove(type);
                                              }
                                            });
                                          },
                                        ),
                                        onTap: () {
                                          // Inverser la sélection avec un clic sur toute la ligne
                                          setState(() {
                                            if (isSelected) {
                                              selectedSpec.remove(type);
                                            } else {
                                              selectedSpec.add(type);
                                            }
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
                    style: TextStyle(
                      color: d_colorOr,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  onPressed: () {
                    _searchController.clear();
                    Navigator.of(context).pop();
                  },
                ),
                TextButton(
                  child: const Text(
                    'Valider',
                    style: TextStyle(
                      color: d_colorOr,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  onPressed: () {
                    List<String> typeLibelle =
                        selectedSpec.map((e) => e.nomSpeculation!).toList();
                    typeController.text = typeLibelle.join(', ');
                    _searchController.clear();
                    print('Options sélectionnées : $selectedSpec');
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

  Future<void> registerUser(BuildContext context) async {
    final nomActeur = widget.nomActeur;
    final emailActeur = widget.email;
    final adresse = widget.adresse;
    final localisation = widget.localistaion;
    final typeActeur = widget.typeActeur;
    final password = passwordController.text;
    final confirmPassword = confirmPasswordController.text;

    // Vérification des mots de passe
    if (password != confirmPassword) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  'Les mots de passe ne correspondent pas',
                  maxLines: 2,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white,
                  ),
                ),
              ),
              Icon(Icons.error_outline, color: Colors.white),
            ],
          ),
          backgroundColor: Colors.redAccent, // Couleur de fond du SnackBar
          duration: Duration(seconds: 5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          behavior: SnackBarBehavior.floating, // Flottant pour un style moderne
          margin: EdgeInsets.all(10), // Espace autour du SnackBar
        ),
      );
      return;
    }

    ActeurService acteurService = ActeurService();

    try {
      // Création de l'acteur
      await acteurService.creerActeur(
        nomActeur: nomActeur,
        adresseActeur: adresse,
        telephoneActeur: widget.telephoneActeur,
        whatsAppActeur: widget.numeroWhatsApp,
        niveau3PaysActeur: widget.pays,
        localiteActeur: localisation,
        emailActeur: emailActeur,
        typeActeur: typeActeur,
        password: password,
        speculation: selectedSpec,
      );

      // Affichage de la boîte de dialogue de succès
      showSuccessDialog(context, "Inscription réussie avec succès");
    } catch (error) {
      String errorMessage;
      if (error
          .toString()
          .contains('Un compte avec le même numéro de téléphone existe déjà')) {
        errorMessage = 'Un compte avec le même numéro de téléphone existe déjà';
      } else if (error
          .toString()
          .contains('Un compte avec le même email existe déjà')) {
        errorMessage = 'Un compte avec le même email existe déjà';
      } else if (error.toString().contains('https://api.greenapi.com')) {
        // Si une condition spécifique doit entraîner un succès malgré l'exception
        showSuccessDialog(context, "Inscription réussie avec succès ");
        return;
      } else {
        errorMessage =
            'Une erreur s\'est produite. Vérifiez les informations du compte puis réessayez';
      }
      // Affichage de la boîte de dialogue d'erreur
      showErrorDialog(context, errorMessage);
    }
  }

  void showSuccessDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Center(child: Text('Succès')),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Get.back();
                Get.offAll(LoginSuccessScreen());
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  void showErrorDialog(BuildContext context, String errorMessage) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Erreur lors de l'inscription"),
          content: Text(
            errorMessage,
            style: TextStyle(color: Colors.black87),
          ),
          actions: [
            TextButton(
              child: Text("OK"),
              onPressed: () => Navigator.pop(context),
            ),
          ],
        );
      },
    );
  }

  // Méthode pour évaluer la qualité du code PIN
  void evaluatePinStrength(String pin) {
    setState(() {
      if (pin.isEmpty) {
        showStrengthIndicator = false;
      } else if (pin.length < 6) {
        strength = 0.3;
        pinStrength = "Trop court";
        showStrengthIndicator = true;
      } else if (RegExp(r'^(.)\1*$').hasMatch(pin)) {
        // Vérifie si tous les chiffres sont identiques (ex. 111111)
        strength = 0.4;
        showStrengthIndicator = true;
        pinStrength = "Faible";
      } else if (RegExp(r'^(123456|654321|987654|012345)$').hasMatch(pin)) {
        // Vérifie les séquences prévisibles
        strength = 0.4;
        pinStrength = "Faible";
        showStrengthIndicator = true;
      } else {
        strength = 1.0;
        pinStrength = "Bon";
        showStrengthIndicator = false;
      }
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    _searchController = TextEditingController();
    _typeList =
        http.get(Uri.parse('$apiOnlineUrl/Speculation/getAllSpeculation'));

    debugPrint("Adresse : " +
        widget.adresse +
        " Type : ${widget.typeActeur}" +
        " Tel : ${widget.telephoneActeur}" +
        "pays : ${widget.pays}" +
        " Localisation :  " +
        widget.localistaion +
        " Whats app : " +
        widget.numeroWhatsApp +
        "Email :" +
        widget.email);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LoadingOverlay(
      isLoading: isLoading,
      child: Scaffold(
        backgroundColor: const Color.fromARGB(255, 250, 250, 250),
        appBar: AppBar(
            leading: IconButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                icon: const Icon(
                  Icons.arrow_back_sharp,
                  size: 30,
                )),
            actions: [
              TextButton(
                onPressed: () {
                  Get.offAll(BottomNavigationPage(),
                      transition: Transition.leftToRight);
                  Provider.of<BottomNavigationService>(context, listen: false)
                      .changeIndex(0);
                },
                child: const Text(
                  'Fermer',
                  style: TextStyle(color: Colors.orange, fontSize: 17),
                ),
              )
            ]),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              children: [
                const SizedBox(
                  height: 75,
                ),
                Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(left: 10.0),
                          child: Text(
                            "Spéculation (Multi-sélection)",
                            style: TextStyle(color: Colors.black, fontSize: 18),
                          ),
                        ),
                        const SizedBox(height: 10),
                        GestureDetector(
                          onTap: _showMultiSelectDialogt,
                          child: TextFormField(
                            onTap: _showMultiSelectDialogt,
                            controller: typeController,
                            decoration: InputDecoration(
                              suffixIcon: Icon(Icons.arrow_drop_down,
                                  color: Colors.blueGrey[400]),
                              hintText: "Sélectionner une spéculation ",
                              contentPadding: const EdgeInsets.symmetric(
                                  vertical: 10, horizontal: 20),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        Padding(
                          padding: const EdgeInsets.only(left: 10.0),
                          child: Text(
                            "Code PIN (6 chiffres)",
                            style:
                                TextStyle(color: (Colors.black), fontSize: 18),
                          ),
                        ),
                        const SizedBox(height: 10),
                        TextFormField(
                          controller: passwordController,
                          onChanged: evaluatePinStrength,
                          decoration: InputDecoration(
                            hintText: "Entrez votre code PIN",
                            suffixIcon: IconButton(
                              onPressed: () {
                                setState(() {
                                  _obscureText =
                                      !_obscureText; // Inverser l'état du texte masqué
                                });
                              },
                              icon: Icon(
                                _obscureText
                                    ? Icons.visibility_off
                                    : Icons
                                        .visibility, // Choisir l'icône basée sur l'état du texte masqué
                                color: Colors.grey,
                              ),
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                                vertical: 10, horizontal: 20),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          keyboardType: TextInputType.number,
                          obscureText: _obscureText,
                          validator: (val) {
                            if (val == null || val.isEmpty) {
                              return "Veuillez entrer votre code PIN";
                            }
                            if (val.length != 6) {
                              return 'Le code PIN doit contenir exactement 6 chiffres';
                            }
                            return null;
                          },
                          onSaved: (val) => password = val!,
                        ),
                        if (showStrengthIndicator)
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text("$pinStrength ",
                                  style: const TextStyle(fontSize: 15)),
                              Expanded(
                                child: LinearProgressIndicator(
                                  value: strength,
                                  color: strength == 1.0
                                      ? Colors.green
                                      : (strength > 0.3
                                          ? Colors.orange
                                          : Colors.red),
                                  backgroundColor: Colors.grey[300],
                                ),
                              ),
                            ],
                          ),
                        const SizedBox(height: 20),
                        Padding(
                          padding: const EdgeInsets.only(left: 10.0),
                          child: Text(
                            "Confirmer le code PIN",
                            style:
                                TextStyle(color: (Colors.black), fontSize: 18),
                          ),
                        ),
                        const SizedBox(height: 10),
                        TextFormField(
                          controller: confirmPasswordController,
                          decoration: InputDecoration(
                            hintText: "Confirmez votre code PIN",
                            suffixIcon: IconButton(
                              onPressed: () {
                                setState(() {
                                  _obscureText =
                                      !_obscureText; // Inverser l'état du texte masqué
                                });
                              },
                              icon: Icon(
                                _obscureText
                                    ? Icons.visibility_off
                                    : Icons
                                        .visibility, // Choisir l'icône basée sur l'état du texte masqué
                                color: Colors.grey,
                              ),
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                                vertical: 10, horizontal: 20),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          keyboardType: TextInputType.number,
                          obscureText: _obscureText,
                          validator: (val) {
                            if (val == null || val.isEmpty) {
                              return "Veuillez confirmer votre code PIN";
                            }
                            if (val != passwordController.text) {
                              return 'Les codes PIN ne correspondent pas';
                            }
                            return null;
                          },
                          onSaved: (val) => password = val!,
                        ),

                        // Padding(
                        //   padding: const EdgeInsets.symmetric(
                        //       horizontal: 10, vertical: 12),
                        //   child: Wrap(
                        //     children: [
                        //       const Text(
                        //         "Voir les ",
                        //         style: TextStyle(
                        //           color: Colors.black,
                        //           fontSize: 14,
                        //           fontWeight: FontWeight.bold,
                        //         ),
                        //       ),
                        //       const SizedBox(width: 4),
                        //       GestureDetector(
                        //         onTap: () async {
                        //           Get.to(
                        //             TermsConditionsPage(),
                        //             duration: const Duration(milliseconds: 500),
                        //             transition: Transition.leftToRight,
                        //           );
                        //         },
                        //         child: const Text(
                        //           "Conditions d'utilisation",
                        //           style: TextStyle(
                        //             decoration: TextDecoration.underline,
                        //             color: Colors.blue,
                        //             fontSize: 16,
                        //             fontStyle: FontStyle.italic,
                        //             fontWeight: FontWeight.bold,
                        //           ),
                        //         ),
                        //       ),
                        //       const SizedBox(width: 8),
                        //       const Text(
                        //         "et la ",
                        //         style: TextStyle(
                        //           color: Colors.black,
                        //           fontSize: 14,
                        //           fontWeight: FontWeight.bold,
                        //         ),
                        //       ),
                        //       GestureDetector(
                        //         onTap: () async {
                        //           Get.to(
                        //             TermsConditionsPage(), // La même page inclut déjà les deux sections.
                        //             duration: const Duration(milliseconds: 500),
                        //             transition: Transition.leftToRight,
                        //           );
                        //         },
                        //         child: const Text(
                        //           "Politique de confidentialité",
                        //           maxLines: 2,
                        //           style: TextStyle(
                        //             decoration: TextDecoration.underline,
                        //             color: Colors.blue,
                        //             fontSize: 16,
                        //             fontStyle: FontStyle.italic,
                        //             fontWeight: FontWeight.bold,
                        //           ),
                        //         ),
                        //       ),
                        //     ],
                        //   ),
                        // ),
                        // const SizedBox(height: 8),
                        // Row(
                        //   children: [
                        //     Checkbox(
                        //       value: _isAgreed,
                        //       onChanged: (bool? value) {
                        //         setState(() {
                        //           _isAgreed = value!;
                        //         });
                        //       },
                        //     ),
                        //     Flexible(
                        //       child: Text(
                        //         "J'accepte les conditions d'utilisation.",
                        //         maxLines: 3,
                        //         style: TextStyle(fontSize: 16),
                        //       ),
                        //     ),
                        //   ],
                        // ),
                        SizedBox(height: 15),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Checkbox(
                              value: _isAgreed,
                              onChanged: (bool? value) {
                                setState(() {
                                  _isAgreed = value!;
                                });
                              },
                            ),
                            SizedBox(width: 15),
                            Flexible(
                              child: RichText(
                                text: TextSpan(
                                  text: "J'accepte les termes de la ",
                                  style: const TextStyle(
                                      fontSize: 16, color: Colors.black),
                                  children: [
                                    TextSpan(
                                      text: "Conditions d'utilisation",
                                      style: const TextStyle(
                                        color: Colors.blue,
                                        decoration: TextDecoration.underline,
                                        fontStyle: FontStyle.italic,
                                      ),
                                      recognizer: TapGestureRecognizer()
                                        ..onTap = () {
                                          Get.to(
                                            TermsConditionsPage(),
                                            duration: const Duration(
                                                milliseconds: 500),
                                            transition: Transition.leftToRight,
                                          );
                                        },
                                    ),
                                    const TextSpan(
                                      text: " et la ",
                                      style: TextStyle(
                                          fontSize: 16, color: Colors.black),
                                    ),
                                    TextSpan(
                                      text: "Politique de confidentialité.",
                                      style: const TextStyle(
                                        color: Colors.blue,
                                        decoration: TextDecoration.underline,
                                        fontStyle: FontStyle.italic,
                                      ),
                                      recognizer: TapGestureRecognizer()
                                        ..onTap = () {
                                          Get.to(
                                            TermsConditionsPage(),
                                            duration: const Duration(
                                                milliseconds: 500),
                                            transition: Transition.leftToRight,
                                          );
                                        },
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),

                        // fin confirm password

                        const SizedBox(height: 35),
                        SizedBox(
                          height: 60,
                          child: Center(
                            child: ElevatedButton(
                              onPressed: () async {
                                if (_formKey.currentState!.validate()) {
                                  if (!_isAgreed) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Expanded(
                                              child: Text(
                                                "Veuillez acceptez les termes",
                                                maxLines: 2,
                                                style: TextStyle(
                                                  fontSize: 16,
                                                  color: Colors.white,
                                                ),
                                              ),
                                            ),
                                            Icon(Icons.error_outline,
                                                color: Colors.white),
                                          ],
                                        ),
                                        backgroundColor: Colors
                                            .redAccent, // Couleur de fond du SnackBar
                                        duration: Duration(seconds: 5),
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(10),
                                        ),
                                        behavior: SnackBarBehavior
                                            .floating, // Flottant pour un style moderne
                                        margin: EdgeInsets.all(
                                            10), // Espace autour du SnackBar
                                      ),
                                    );
                                  } else if (selectedSpec.isEmpty) {
                                    ScaffoldMessenger.of(context)
                                        .showSnackBar(SnackBar(
                                      content: Text(
                                          'Veuillez sélectionner au moins une speculation.'),
                                    ));
                                  } else if (passwordController.text
                                              .toString()
                                              .trim() ==
                                          "123456" ||
                                      confirmPasswordController.text
                                              .toString()
                                              .trim() ==
                                          "123456") {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Expanded(
                                              child: Text(
                                                'Mot de passe faible, veuillez saisir un mot de passe sécurisé.',
                                                maxLines: 2,
                                                style: TextStyle(
                                                  fontSize: 16,
                                                  color: Colors.white,
                                                ),
                                              ),
                                            ),
                                            Icon(Icons.error_outline,
                                                color: Colors.white),
                                          ],
                                        ),
                                        backgroundColor: Colors
                                            .redAccent, // Couleur de fond du SnackBar
                                        duration: Duration(seconds: 3),
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(10),
                                        ),
                                        behavior: SnackBarBehavior
                                            .floating, // Flottant pour un style moderne
                                        margin: EdgeInsets.all(
                                            10), // Espace autour du SnackBar
                                      ),
                                    );
                                  } else {
                                    _handleButtonPress(context);
                                  }
                                }
                                // Handle button press action here
                              },
                              child: Text(
                                " Enregister ",
                                style: TextStyle(
                                  fontSize: 20,
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(
                                    0xFFFF8A00), // Orange color code
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(15),
                                ),
                                minimumSize: Size(250, 40),
                              ),
                            ),
                          ),
                        ),
                      ],
                    )),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
