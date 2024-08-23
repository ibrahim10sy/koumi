import 'dart:io';

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
import 'package:multi_dropdown/multiselect_dropdown.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class RegisterEndScreen extends StatefulWidget {
  String nomActeur, email, adresse, localistaion;
  String telephoneActeur, numeroWhatsApp, pays;
  File? image1;
  late List<TypeActeur>? typeActeur;
  //  late List<TypeActeur> idTypeActeur;

  RegisterEndScreen(
      {super.key,
      required this.nomActeur,
      this.image1,
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

class _RegisterEndScreenState extends State<RegisterEndScreen> {
  bool isLoading = false;
  String errorMessage = "";
  String exception = "";

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  //  final MultiSelectController _controllerCategorie = MultiSelectController();

  final MultiSelectController _controllerCategorie = MultiSelectController();
  final MultiSelectController _controllerSpeculation = MultiSelectController();

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

  List<String> idsCategorieProduit = [];
  String idsCategorieProduitAsString = "";

  String? image2Src;
  File? image2;

  String url = "";

  Future<File> saveImagePermanently(String imagePath) async {
    final directory = await getApplicationDocumentsDirectory();
    final name = basename(imagePath);
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
        this.image2 = image;
        image2Src = image.path;
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
          ),
        );
      },
    );
  }

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

  registerUser(BuildContext context) async {
    final nomActeur = widget.nomActeur;
    final emailActeur = widget.email;
    final adresse = widget.adresse;
    final localisation = widget.localistaion;
    final typeActeur = widget.typeActeur;
    final password = passwordController.text;
    final confirmPassword = confirmPasswordController.text;

    if (password != confirmPassword) {
      // Gérez le cas où l'email ou le mot de passe est vide.
      const String errorMessage = "Les mot de passe ne correspondent pas ";
      // Gérez le cas où l'email ou le mot de passe est vide.
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Center(
                child: Text(
              'Erreur',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
            )),
            content: const Text(errorMessage),
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
      return;
    }
    // Utilize your backend service to send the request
    ActeurService acteurService = ActeurService();
    // Si widget.typeActeur est bien une liste de TypeActeur
    try {
      // String type = typeActeurList.toString();
      if (widget.image1 != null && image2 != null) {
        await acteurService
            .creerActeur(
                logoActeur: widget.image1,
                photoSiegeActeur: image2,
                nomActeur: nomActeur,
                adresseActeur: adresse,
                telephoneActeur: widget.telephoneActeur,
                whatsAppActeur: widget.numeroWhatsApp,
                niveau3PaysActeur: widget.pays,
                localiteActeur: localisation,
                emailActeur: emailActeur,
                typeActeur: widget
                    .typeActeur, // Convertir les IDs en chaînes de caractères
                password: password,
                speculation: selectedSpec)
            .then((value) => showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: const Center(child: Text('Succès')),
                      content: const Text("Inscription réussi avec succès"),
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
                ))
            .catchError((error) => {
                  if (error is Exception)
                    {
                      exception = error.toString(),
                      if (exception.toString().contains(
                          'Un compte avec le même numéro de téléphone existe déjà'))
                        {
                          errorMessage =
                              'Un compte avec le même numéro de téléphone existe déjà',
                        }
                      else if (exception
                          .toString()
                          .contains('Un compte avec le même email existe déjà'))
                        {
                          errorMessage =
                              'Un compte avec le même email existe déjà 1',
                        }
                      else
                        {
                          errorMessage =
                              'Un compte avec le même email et numéro de téléphone  existe déjà',
                        }
                    },
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: Text("Erreur lors de l'inscription"),
                        content: Text(errorMessage,
                            style: TextStyle(
                              color: Colors.black87,
                            )),
                        actions: [
                          TextButton(
                            child: Text("OK"),
                            onPressed: () => Navigator.pop(context),
                          ),
                        ],
                      );
                    },
                  )
                });
      } else if (widget.image1 != null) {
        await acteurService
            .creerActeur(
                logoActeur: widget.image1,
                nomActeur: nomActeur,
                adresseActeur: adresse,
                telephoneActeur: widget.telephoneActeur,
                whatsAppActeur: widget.numeroWhatsApp,
                niveau3PaysActeur: widget.pays,
                localiteActeur: localisation,
                emailActeur: emailActeur,
                typeActeur: widget
                    .typeActeur, // Convertir les IDs en chaînes de caractères
                password: password,
                speculation: selectedSpec)
            .then((value) => showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: const Center(child: Text('Succès')),
                      content: const Text("Inscription réussi avec succès"),
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
                ))
            .catchError((error) => {
                  if (error is Exception)
                    {
                      exception = error.toString(),
                      if (exception.toString().contains(
                          'Un compte avec le même numéro de téléphone existe déjà'))
                        {
                          errorMessage =
                              'Un compte avec le même numéro de téléphone existe déjà',
                        }
                      else if (exception
                          .toString()
                          .contains('Un compte avec le même email existe déjà'))
                        {
                          errorMessage =
                              'Un compte avec le même email existe déjà 2',
                        }
                      else
                        {
                          errorMessage =
                              'Un compte avec le même email et numéro de téléphone  existe déjà',
                        }
                    },
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: Text("Erreur lors de l'inscription"),
                        content: Text(errorMessage,
                            style: TextStyle(
                              color: Colors.black87,
                            )),
                        actions: [
                          TextButton(
                            child: Text("OK"),
                            onPressed: () => Navigator.pop(context),
                          ),
                        ],
                      );
                    },
                  )
                });
      } else if (image2 != null) {
        await acteurService
            .creerActeur(
                photoSiegeActeur: image2,
                nomActeur: nomActeur,
                adresseActeur: adresse,
                telephoneActeur: widget.telephoneActeur,
                whatsAppActeur: widget.numeroWhatsApp,
                niveau3PaysActeur: widget.pays,
                localiteActeur: localisation,
                emailActeur: emailActeur,
                typeActeur: widget
                    .typeActeur, // Convertir les IDs en chaînes de caractères
                password: password,
                speculation: selectedSpec)
            .then((value) => showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: const Center(child: Text('Succès')),
                      content: const Text("Inscription réussi avec succès"),
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
                ))
            .catchError((error) => {
                  if (error is Exception)
                    {
                      exception = error.toString(),
                      if (exception.toString().contains(
                          'Un compte avec le même numéro de téléphone existe déjà'))
                        {
                          errorMessage =
                              'Un compte avec le même numéro de téléphone existe déjà',
                        }
                      else if (exception
                          .toString()
                          .contains('Un compte avec le même email existe déjà'))
                        {
                          errorMessage =
                              'Un compte avec le même email existe déjà 6',
                        }
                      else
                        {
                          errorMessage =
                              'Un compte avec le même email et numéro de téléphone  existe déjà',
                        }
                    },
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: Text("Erreur lors de l'inscription"),
                        content: Text(errorMessage,
                            style: TextStyle(
                              color: Colors.black87,
                            )),
                        actions: [
                          TextButton(
                            child: Text("OK"),
                            onPressed: () => Navigator.pop(context),
                          ),
                        ],
                      );
                    },
                  )
                });
      } else {
        await acteurService
            .creerActeur(
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
            )
            .then((value) => showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: const Center(child: Text('Succès')),
                      content: const Text("Inscription réussi avec succès"),
                      actions: <Widget>[
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) =>
                                      const LoginSuccessScreen()),
                            );
                          },
                          child: const Text('OK'),
                        ),
                      ],
                    );
                  },
                ))
            .catchError((error) => {
                  if (error is Exception)
                    {
                      exception = error.toString(),
                      if (exception.toString().contains(
                          'Un compte avec le même numéro de téléphone existe déjà'))
                        {
                          errorMessage =
                              'Un compte avec le même numéro de téléphone existe déjà',
                        }
                      else if (exception
                          .toString()
                          .contains('Un compte avec le même email existe déjà'))
                        {
                          errorMessage =
                              'Un compte avec le même email existe déjà 8',
                        }
                      else
                        {
                          errorMessage =
                              'Un compte avec le même email et numéro de téléphone  existe déjà',
                        }
                    },
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: Text("Erreur lors de l'inscription"),
                        content: Text(errorMessage,
                            style: TextStyle(
                              color: Colors.black87,
                            )),
                        actions: [
                          TextButton(
                            child: Text("OK"),
                            onPressed: () => Navigator.pop(context),
                          ),
                        ],
                      );
                    },
                  )
                });
      }
      // print("Demande envoyée avec succès: ${updatedDemande.toString()}");
      debugPrint("yes ");
      // Navigate to the next page if necessary
    } catch (error) {
      String errorMessage = "";
      if (error is Exception) {
        final exception = error;
        if (exception.toString().contains(
            'Un compte avec le même numéro de téléphone existe déjà')) {
          errorMessage =
              'Un compte avec le même numéro de téléphone existe déjà';
        } else if (exception
            .toString()
            .contains('Un compte avec le même email existe déjà')) {
          errorMessage = 'Un compte avec le même email existe déjà 10';
        } else {
          errorMessage =
              'Un compte avec le même email et numéro de téléphone  existe déjà';
        }
        print(errorMessage);
      }

      debugPrint("no " + errorMessage);
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text("Erreur lors de l'inscription"),
          content: Text(errorMessage,
              style: TextStyle(
                color: Colors.black87,
              )),
          actions: [
            TextButton(
              child: Text("OK"),
              onPressed: () => Navigator.pop(context),
            ),
          ],
        ),
      );
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
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
  Widget build(BuildContext context) {
    return LoadingOverlay(
      isLoading: isLoading,
      child: Scaffold(
        backgroundColor: const Color.fromARGB(255, 250, 250, 250),
        appBar: AppBar(
            leading: IconButton(
              onPressed: () {
                // Fonction de retour
                Navigator.pop(context);
              },
              icon: Icon(
                Icons.arrow_back,
                color: Colors.black,
                size: 30,
              ),
              iconSize: 30,
              splashRadius: 20,
              padding: EdgeInsets.zero,
              constraints: BoxConstraints(minWidth: 40, minHeight: 40),
            ),
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
                SizedBox(
                  height: 15,
                ),
                Container(
                  height: 100,
                  width: 200, // Spécifiez une largeur fixe pour le conteneur
                  child: (image2 == null)
                      ? Center(child: Image.asset('assets/images/logo-pr.png'))
                      : SizedBox(
                          height: 50,
                          child: Image.file(
                            image2!,
                            height: 100,
                            width: 200,
                            fit: BoxFit.cover,
                          ),
                        ),
                ),
                const SizedBox(
                  height: 10,
                ),
                Container(
                  height: 42,
                  width: MediaQuery.of(context).size.width * 0.9,
                  decoration: BoxDecoration(
                    color: const Color(0xFFFF8A00),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: TextButton(
                    onPressed: () {
                      _showImageSourceDialog();
                    },
                    child: Center(
                      child: Text(
                        "Choisir la photo du siège",
                        style: TextStyle(
                          fontSize: 20,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
                Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(
                          height: 20,
                        ),

                        const SizedBox(
                          height: 5,
                        ),

                        // Deuxième widget MultiSelectDropDown pour sélectionner les spéculations
                        Padding(
                          padding: const EdgeInsets.only(left: 10.0),
                          child: Text(
                            "Spéculation",
                            style: TextStyle(color: Colors.black, fontSize: 18),
                          ),
                        ),
                        const SizedBox(height: 5),
                        MultiSelectDropDown.network(
                          networkConfig: NetworkConfig(
                            url:
                                '$apiOnlineUrl/Speculation/getAllSpeculation', //e40ijxd5k0n0yrzj5f80,
                            method: RequestMethod.get,
                            headers: {'Content-Type': 'application/json'},
                          ),
                          searchEnabled: true,
                          searchLabel: 'Rechercher...',
                          searchBackgroundColor: Colors.blueGrey[50],
                          chipConfig: const ChipConfig(wrapType: WrapType.wrap),
                          responseParser: (response) {
                            listeSpeculations =
                                (response as List<dynamic>).map((e) {
                              return Speculation(
                                idSpeculation: e['idSpeculation'] as String,
                                nomSpeculation: e['nomSpeculation'] as String,
                                statutSpeculation:
                                    e['statutSpeculation'] as bool,
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
                          hint: 'Sélectionner une spéculation',
                          dropdownHeight: 320,
                          fieldBackgroundColor:
                              Color.fromARGB(255, 219, 219, 219),
                          onOptionSelected: (options) {
                            setState(() {
                              selectedSpec = options
                                  .map<Speculation>((item) => item.value!)
                                  .toList();
                              print("Types sélectionnés : $selectedSpec");
                              libelleSpeculation.clear();
                              libelleSpeculation.addAll(
                                  options.map((data) => data.label).toList());
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

                        // fin  filiere
                        const SizedBox(
                          height: 10,
                        ),
                        // debut mot de passe
                        Padding(
                          padding: const EdgeInsets.only(left: 10.0),
                          child: Text(
                            "Mot de passe",
                            style:
                                TextStyle(color: (Colors.black), fontSize: 18),
                          ),
                        ),
                        // debut  mot de pass
                        TextFormField(
                          controller: passwordController,
                          decoration: InputDecoration(
                            hintText: "Entrez votre mot de passe",
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
                              return "Veillez entrez votre  mot de passe ";
                            }
                            if (val.length < 6) {
                              return 'Le mot de passe doit contenir au moins 6 caractères';
                            } else if (val.length > 6) {
                              return 'Le mot de passe ne doit pas dépassé 6 caractères';
                            } else {
                              return null;
                            }
                          },
                          onSaved: (val) => password = val!,
                        ),
                        // fin mot de pass

                        // confirm password
                        const SizedBox(
                          height: 10,
                        ),
                        // debut mot de passe
                        Padding(
                          padding: const EdgeInsets.only(left: 10.0),
                          child: Text(
                            "Confirm mot de passe",
                            style:
                                TextStyle(color: (Colors.black), fontSize: 18),
                          ),
                        ),
                        // debut  mot de pass
                        TextFormField(
                          controller: confirmPasswordController,
                          decoration: InputDecoration(
                            hintText:
                                "Entrez votre confirmer votre mot de passe",
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
                              return "Veillez entrez votre  mot de passe à nouveau";
                            }
                            if (val.length < 6) {
                              return 'Le mot de passe doit contenir au moins 6 caractères';
                            } else if (val.length > 6) {
                              return 'Le mot de passe ne doit pas dépassé 6 caractères';
                            } else {
                              return null;
                            }
                          },
                          onSaved: (val) => password = val!,
                        ),
                        // fin mot de pass

                        // fin confirm password

                        const SizedBox(
                          height: 20,
                        ),
                        Center(
                          child: ElevatedButton(
                            onPressed: () async {
                              if (_formKey.currentState!.validate()) {
                                if (selectedSpec.isEmpty) {
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
                                  ScaffoldMessenger.of(context)
                                      .showSnackBar(SnackBar(
                                    content: Text(
                                        'Mot de passe faible, veuillez saisir un mot de passe sécurisé.'),
                                  ));
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
                              backgroundColor:
                                  const Color(0xFFFF8A00), // Orange color code
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15),
                              ),
                              minimumSize: Size(250, 40),
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
