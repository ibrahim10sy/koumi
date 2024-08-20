import 'dart:async';
import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:koumi/constants.dart';
import 'package:koumi/models/Acteur.dart';
import 'package:koumi/models/Speculation.dart';
import 'package:koumi/models/TypeActeur.dart';
import 'package:koumi/providers/ActeurProvider.dart';
import 'package:koumi/screens/ForgetPassScreen.dart';
import 'package:koumi/screens/ListeIntrantByActeur.dart';
import 'package:koumi/screens/LoginScreen.dart';
import 'package:koumi/screens/RegisterScreen.dart';
import 'package:koumi/screens/VehiculesActeur.dart';
import 'package:koumi/service/BottomNavigationService.dart';
import 'package:koumi/widgets/BottomNavBarAdmin.dart';
import 'package:koumi/widgets/BottomNavigationPage.dart';
import 'package:koumi/widgets/LoadingOverlay.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PinLoginScreen extends StatefulWidget {
  const PinLoginScreen({super.key});

  @override
  State<PinLoginScreen> createState() => _PinLoginScreenState();
}

const d_colorOr = Color.fromRGBO(255, 138, 0, 1);

class _PinLoginScreenState extends State<PinLoginScreen> {
  String enteredPin = '';
  bool isPinVisible = false;
  bool isLoading = false;
  String? codeActeur;
  late SharedPreferences prefs;

  @override
  void initState() {
    super.initState();
    _loadCodeActeur();
  }

  Future<void> _loadCodeActeur() async {
    prefs = await SharedPreferences.getInstance();
    setState(() {
      codeActeur = prefs.getString('codeActeur');
    });
  }

  _handleButtonPress() async {
    setState(() {
      isLoading = true;
    });
    await loginUser().then((_) {
      setState(() {
        isLoading = false;
      });
    });
  }

  // Future<void> loginUser() async {
  //   const String baseUrl = '$apiOnlineUrl/acteur/pinLogin';

  //   ActeurProvider acteurProvider =
  //       Provider.of<ActeurProvider>(context, listen: false);


  //   // Assurez-vous que le code acteur est chargé
  //   if (codeActeur == null) {
  //     showDialog(
  //       context: context,
  //       builder: (context) => AlertDialog(
  //         title: Text("Connexion"),
  //         content: Text(
  //             "Veillez vous connectez d'abord avec votre email et le mot de passe puis réessayer plus tard",
  //             style: TextStyle(
  //               color: Colors.black87,
  //             )),
  //         actions: [
  //           TextButton(
  //             child: Text("OK"),
  //             onPressed: () => Navigator.pop(context),
  //           ),
  //           TextButton(
  //             child: Text("connexion"),
  //             onPressed: () {
  //               Get.offAll(LoginScreen(),
  //                   duration: Duration(seconds: 1),
  //                   transition: Transition.leftToRight);
  //             },
  //           ),
  //         ],
  //       ),
  //     );

  //     return;
  //   }

  //   // Construire l'URL de l'API avec le codeActeur récupéré
  //   final Uri apiUrl =
  //       Uri.parse('$baseUrl?codeActeur=$codeActeur&password=$enteredPin');

  //   try {
  //     final response = await http.get(
  //       apiUrl,
  //       headers: {
  //         'Content-Type': 'application/json',
  //       },
  //     );

  //   SharedPreferences prefs = await SharedPreferences.getInstance();
  //     if (response.statusCode == 200) {
  //       final responseBody = json.decode(utf8.decode(response.bodyBytes));

  //       // Sauvegarder les données de l'utilisateur dans shared preferences
  //       final password = responseBody['password'];
  //       final codeActeur = responseBody['codeActeur'];
  //       prefs.setString('password', password);
  //       prefs.setString('codeActeur', codeActeur);
  //       final nomActeur = responseBody['nomActeur'];
  //       final emailActeur = responseBody['emailActeur'];
  //       final idActeur = responseBody['idActeur'];
  //       final adresseActeur = responseBody['adresseActeur'];
  //       final telephoneActeur = responseBody['telephoneActeur'];
  //       final whatsAppActeur = responseBody['whatsAppActeur'];
  //       final niveau3PaysActeur = responseBody['niveau3PaysActeur'];
  //       final localiteActeur = responseBody['localiteActeur'];

  //       prefs.setString('nomActeur', nomActeur);
  //       prefs.setString('idActeur', idActeur);
  //       prefs.setString('adresseActeur', adresseActeur);
  //       prefs.setString('telephoneActeur', telephoneActeur);
  //       prefs.setString('whatsAppActeur', whatsAppActeur);
  //       prefs.setString('niveau3PaysActeur', niveau3PaysActeur);
  //       prefs.setString('localiteActeur', localiteActeur);
  //       prefs.setString('emailActeur', emailActeur);

  //       // Enregistrer la liste des types d'utilisateur dans SharedPreferences
  //       List<dynamic> speculationData = responseBody['speculation'];
  //       List<Speculation> speculationList =
  //           speculationData.map((data) => Speculation.fromMap(data)).toList();

  //       List<dynamic> typeActeurData = responseBody['typeActeur'];
  //       List<TypeActeur> typeActeurList =
  //           typeActeurData.map((data) => TypeActeur.fromMap(data)).toList();

  //       List<String> userTypeLabels =
  //           typeActeurList.map((typeActeur) => typeActeur.libelle!).toList();
  //       List<String> speculationLabels = speculationList
  //           .map((typeActeur) => typeActeur.nomSpeculation!)
  //           .toList();

  //       prefs.setStringList('speculation', speculationLabels);
  //       prefs.setStringList('userType', userTypeLabels);

  //       Acteur acteur = Acteur(
  //         idActeur: responseBody['idActeur'],
  //         resetToken: responseBody['resetToken'],
  //         tokenCreationDate: responseBody['tokenCreationDate'],
  //         codeActeur: codeActeur,
  //         nomActeur: responseBody['nomActeur'],
  //         adresseActeur: responseBody['adresseActeur'],
  //         telephoneActeur: responseBody['telephoneActeur'],
  //         latitude: responseBody['latitude'],
  //         longitude: responseBody['longitude'],
  //         photoSiegeActeur: responseBody['photoSiegeActeur'],
  //         logoActeur: responseBody['logoActeur'],
  //         whatsAppActeur: responseBody['whatsAppActeur'],
  //         niveau3PaysActeur: responseBody['niveau3PaysActeur'],
  //         dateAjout: responseBody['dateAjout'],
  //         dateModif: responseBody['dateModif'],
  //         personneModif: responseBody['personneModif'],
  //         localiteActeur: responseBody['localiteActeur'],
  //         emailActeur: responseBody['emailActeur'],
  //         statutActeur: responseBody['statutActeur'],
  //         typeActeur: typeActeurList,
  //         speculation: speculationList,
  //         password: password,
  //       );

  //       acteurProvider.setActeur(acteur);
  //         print("login acteur :${acteur.toString()}");


  //       final List<String> type =
  //           acteur.typeActeur!.map((e) => e.libelle!.toLowerCase()).toList();
  //       if (type.contains('admin') || type.contains('Admin')) {
  //         Get.off(BottomNavBarAdmin(),
  //             duration: Duration(seconds: 1),
  //             transition: Transition.leftToRight);
  //       } else if (type.contains('transformateur') ||
  //           type.contains('producteur') ||
  //           type.contains('commercant') ||
  //           type.contains('commerçant') ||
  //           type.contains('transformateur')) {
  //         Timer(const Duration(seconds: 3), () {
  //           Get.offAll(BottomNavigationPage(),
  //               transition: Transition.leftToRight);
  //           Provider.of<BottomNavigationService>(context, listen: false)
  //               .changeIndex(1);
  //         });
  //       } else if (type.contains('transporteur')) {
  //         Timer(const Duration(seconds: 3), () {
  //            Navigator.pushReplacement(context,
  //               MaterialPageRoute(builder: (context) => VehiculeActeur()));
  //           // Get.offAll(VehiculeActeur(), transition: Transition.leftToRight);
  //         });
  //       } else if (type.contains('fournisseur')) {
  //         Timer(const Duration(seconds: 3), () {
  //           Get.offAll(ListeIntrantByActeur(),
  //               transition: Transition.leftToRight);
  //         });
  //       } else {
  //         Get.off(BottomNavigationPage(),
  //             duration: Duration(seconds: 1),
  //             transition: Transition.leftToRight);
  //       }
  //     } else {
  //       enteredPin = '';
  //       String errorMessage = '';
  //       final responseBody = json.decode(utf8.decode(response.bodyBytes));
  //       errorMessage = responseBody['message'];
  //       if (errorMessage.contains('Code Pin incorrect')) {
  //         errorMessage = 'Code Pin incorrect';
  //       } else if (errorMessage.contains(
  //           'votre compte est désactivé. Veuillez contacter l\'administrateur pour la procédure d\'activation de votre compte !')) {
  //         errorMessage =
  //             'votre compte est désactivé. Veuillez contacter l\'administrateur pour la procédure d\'activation de votre compte !';
  //       }
  //       print("if : $errorMessage");
  //       ScaffoldMessenger.of(context).showSnackBar(
  //         SnackBar(
  //           content: Center(
  //               child: Text(
  //             errorMessage,
  //             maxLines: 2,
  //           )),
  //           duration: Duration(seconds: 5),
  //         ),
  //       );
  //     }
  //   } catch (e) {
  //     String errorMessage = "";
  //     debugPrint(e.toString());
  //     if (e is Exception) {
  //       final exception = e;
  //       if (exception.toString().contains('Code Pin incorrect')) {
  //         errorMessage = 'Code Pin incorrect';
  //       } else if (exception.toString().contains(
  //           'votre compte est désactivé. Veuillez contacter l\'administrateur pour la procédure d\'activation de votre compte !')) {
  //         errorMessage =
  //             'votre compte est désactivé. Veuillez contacter l\'administrateur pour la procédure d\'activation de votre compte !';
  //       }
  //       print("error : $errorMessage");
  //       ScaffoldMessenger.of(context).showSnackBar(
  //         SnackBar(
  //           content: Center(child: Text(errorMessage, maxLines: 2)),
  //           duration: Duration(seconds: 5),
  //         ),
  //       );
  //       throw Exception(errorMessage);
  //     }
  //   }
  // }

 Future<void> loginUser() async {
    const String baseUrl = '$apiOnlineUrl/acteur/pinLogin';


    ActeurProvider acteurProvider =
        Provider.of<ActeurProvider>(context, listen: false);

     // Assurez-vous que le code acteur est chargé
    if (codeActeur == null) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text("Connexion"),
          content: Text(
              "Veillez vous connectez d'abord avec votre email et le mot de passe puis réessayer plus tard",
              style: TextStyle(
                color: Colors.black87,
              )),
          actions: [
            TextButton(
              child: Text("OK"),
              onPressed: () => Navigator.pop(context),
            ),
            TextButton(
              child: Text("connexion"),
              onPressed: () {
                Get.offAll(LoginScreen(),
                    duration: Duration(seconds: 1),
                    transition: Transition.leftToRight);
              },
            ),
          ],
        ),
      );

      return;
    }


   final Uri apiUrl =
        Uri.parse('$baseUrl?codeActeur=$codeActeur&password=$enteredPin');

    try {
      final response = await http.get(
        apiUrl,
        headers: {
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final responseBody = json.decode(utf8.decode(response.bodyBytes));
       
        // Sauvegarder les données de l'utilisateur dans shared preferences
        SharedPreferences prefs = await SharedPreferences.getInstance();
       
      
        final nomActeur = responseBody['nomActeur'];
        final idActeur = responseBody['idActeur'];
        final adresseActeur = responseBody['adresseActeur'];
        final telephoneActeur = responseBody['telephoneActeur'];
        final whatsAppActeur = responseBody['whatsAppActeur'];
        final emailActeur = responseBody['emailActeur'];
        final niveau3PaysActeur = responseBody['niveau3PaysActeur'];
        final localiteActeur = responseBody['localiteActeur'];
        prefs.setString('nomActeur', nomActeur);
        prefs.setString('idActeur', idActeur);
        prefs.setString('emailActeur', emailActeur);
        prefs.setString('adresseActeur', adresseActeur);
        prefs.setString('telephoneActeur', telephoneActeur);
        prefs.setString('whatsAppActeur', whatsAppActeur);
        prefs.setString('niveau3PaysActeur', niveau3PaysActeur);
        prefs.setString('localiteActeur', localiteActeur);
         prefs.setString('codeActeur', codeActeur!);
        prefs.setString('password', enteredPin);
        // Enregistrer la liste des types d'utilisateur dans SharedPreferences

        // Enregistrer la liste des types d'utilisateur dans SharedPreferences

        List<dynamic> typeActeurData = responseBody['typeActeur'];
        List<dynamic> speculationData = responseBody['speculation'];

        List<TypeActeur> typeActeurList =
            typeActeurData.map((data) => TypeActeur.fromMap(data)).toList();

        List<Speculation> speculationsList =
            speculationData.map((data) => Speculation.fromMap(data)).toList();

        // Extraire les libellés des types d'utilisateur et les ajouter à une nouvelle liste de chaînes
        List<String> userTypeLabels =
            typeActeurList.map((typeActeur) => typeActeur.libelle!).toList();

        List<String> speculationLabels =
            speculationsList.map((spec) => spec.nomSpeculation!).toList();

    // Enregistrer la liste des libellés des types d'utilisateur dans SharedPreferences
        prefs.setStringList('userType', userTypeLabels);
        prefs.setStringList('specType', speculationLabels);
        Acteur acteurs = Acteur(
          idActeur: responseBody['idActeur'],
          nomActeur: responseBody['nomActeur'],
          adresseActeur: responseBody['adresseActeur'],
          codeActeur: codeActeur,
          telephoneActeur: responseBody['telephoneActeur'],
          whatsAppActeur: responseBody['whatsAppActeur'],
          niveau3PaysActeur: responseBody['niveau3PaysActeur'],
          dateAjout: responseBody['dateAjout'],
          localiteActeur: responseBody['localiteActeur'],
          emailActeur: responseBody['emailActeur'],
          statutActeur: responseBody['statutActeur'],
          typeActeur: typeActeurList,
          speculation: speculationsList,
          password: enteredPin,
        );

        acteurProvider.setActeur(acteurs);
        print("login acteur :${acteurs.toString()}");

        final List<String> type =
            acteurs.typeActeur!.map((e) => e.libelle!).toList();
        if (type.contains('admin') || type.contains('Admin')) {
          Get.offAll(BottomNavBarAdmin(),
              duration: Duration(seconds: 1),
              transition: Transition.leftToRight);
        } else if (type.contains('transformateur') ||
            type.contains('producteur') ||
            type.contains('commercant') ||
            type.contains('commerçant') ||
            type.contains('transformateur')) {
          Timer(const Duration(seconds: 3), () {
            Get.offAll(BottomNavigationPage(),
                transition: Transition.leftToRight);
            Provider.of<BottomNavigationService>(context, listen: false)
                .changeIndex(1);
          });
        } else if (type.contains('transporteur')) {
          Timer(const Duration(seconds: 3), () {
            Get.offAll(VehiculeActeur(),
              transition: Transition.leftToRight);
                Provider.of<BottomNavigationService>(context, listen: false)
                    .changeIndex(4);
          });
        } else if (type.contains('fournisseur')) {
          Timer(const Duration(seconds: 3), () {
          
                 Get.offAll(ListeIntrantByActeur(),
              transition: Transition.leftToRight);
      
                Provider.of<BottomNavigationService>(context, listen: false)
                    .changeIndex(5);
          });
        } else {
          Get.offAll(BottomNavigationPage(),
              duration: Duration(seconds: 1),
              transition: Transition.leftToRight);
        }
      } else {
        enteredPin = '';
        String errorMessage = '';
        final responseBody = json.decode(utf8.decode(response.bodyBytes));
        errorMessage = responseBody['message'];
        if (errorMessage.contains('Code Pin incorrect')) {
          errorMessage = 'Code Pin incorrect';
        } else if (errorMessage.contains(
            'votre compte est désactivé. Veuillez contacter l\'administrateur pour la procédure d\'activation de votre compte !')) {
          errorMessage =
              'votre compte est désactivé. Veuillez contacter l\'administrateur pour la procédure d\'activation de votre compte !';
        }
        print("if : $errorMessage");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Center(
                child: Text(
              errorMessage,
              maxLines: 2,
            )),
            duration: Duration(seconds: 5),
          ),
        );
      }
    } catch (e) {
      String errorMessage = "";
      debugPrint(e.toString());
      if (e is Exception) {
        final exception = e;
        if (exception.toString().contains('Code Pin incorrect')) {
          errorMessage = 'Code Pin incorrect';
        } else if (exception.toString().contains(
            'votre compte est désactivé. Veuillez contacter l\'administrateur pour la procédure d\'activation de votre compte !')) {
          errorMessage =
              'votre compte est désactivé. Veuillez contacter l\'administrateur pour la procédure d\'activation de votre compte !';
        }
        print("error : $errorMessage");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Center(child: Text(errorMessage, maxLines: 2)),
            duration: Duration(seconds: 5),
          ),
        );
        throw Exception(errorMessage);
      }
    }
  }

  /// this widget will be use for each digit
  Widget numButton(int number) {
    return Padding(
      padding: const EdgeInsets.only(top: 16),
      child: TextButton(
        onPressed: () {
          setState(() {
            if (enteredPin.length < 6) {
              enteredPin += number.toString();
            }

            debugPrint("Pin : $enteredPin");
          });
          if (enteredPin.length == 6) {
            _handleButtonPress();
          }
        },
        child: Text(
          number.toString(),
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return LoadingOverlay(
      isLoading: isLoading,
      child: Scaffold(
        backgroundColor: const Color.fromARGB(255, 250, 250, 250),
        appBar: AppBar(
            // backgroundColor: d_colorOr,
            centerTitle: true,
            toolbarHeight: 75,
            leading: IconButton(
              onPressed: () {
                Get.offAll(BottomNavigationPage(),
                    transition: Transition.leftToRight);
                Provider.of<BottomNavigationService>(context, listen: false)
                    .changeIndex(0);
              },
              icon: const Icon(
                Icons.arrow_back_ios,
              ),
            ),
            actions: [
              PopupMenuButton<String>(
                padding: EdgeInsets.zero,
                itemBuilder: (context) {
                  return <PopupMenuEntry<String>>[
                    PopupMenuItem<String>(
                      child: ListTile(
                        leading: const Icon(
                          Icons.login,
                        ),
                        title: const Text(
                          "S'authentifier",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        onTap: () async {
                          Navigator.of(context).pop();
                          Future.microtask(() {
                            Provider.of<BottomNavigationService>(context,
                                    listen: false)
                                .changeIndex(0);
                          });
                          Get.to(LoginScreen(),
                              duration: Duration(seconds: 1),
                              transition: Transition.leftToRight);
                        },
                      ),
                    ),
                  ];
                },
              )
            ]),
        body: SafeArea(
          minimum: EdgeInsets.only(top: 10),
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            physics: const BouncingScrollPhysics(),
            children: [
              const SizedBox(
                height: 30,
              ),
              const Center(
                child: Text(
                  'Entrer votre code pin',
                  style: TextStyle(
                    fontSize: 32,
                    color: Colors.black,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(height: 60),

              /// pin code area
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  6,
                  (index) {
                    return Container(
                      margin: const EdgeInsets.all(6.0),
                      width: isPinVisible ? 40 : 18,
                      height: isPinVisible ? 40 : 18,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(6.0),
                        color: index < enteredPin.length
                            ? isPinVisible
                                ? Colors.green
                                : CupertinoColors.activeBlue
                            : CupertinoColors.activeBlue.withOpacity(0.1),
                      ),
                      child: isPinVisible && index < enteredPin.length
                          ? Center(
                              child: Text(
                                enteredPin[index],
                                style: const TextStyle(
                                  fontSize: 17,
                                  color: Colors.white,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            )
                          : null,
                    );
                  },
                ),
              ),

              /// visiblity toggle button
              IconButton(
                onPressed: () {
                  setState(() {
                    isPinVisible = !isPinVisible;
                  });
                },
                icon: Icon(
                  isPinVisible ? Icons.visibility_off : Icons.visibility,
                ),
              ),

              SizedBox(height: isPinVisible ? 50.0 : 8.0),

              /// digits
              for (var i = 0; i < 3; i++)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: List.generate(
                      3,
                      (index) => numButton(1 + 3 * i + index),
                    ).toList(),
                  ),
                ),

              /// 0 digit with back remove
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const TextButton(onPressed: null, child: SizedBox()),
                    numButton(0),
                    TextButton(
                      onPressed: () {
                        setState(
                          () {
                            if (enteredPin.isNotEmpty) {
                              enteredPin = enteredPin.substring(
                                  0, enteredPin.length - 1);
                            }
                            debugPrint("Pin : $enteredPin");
                          },
                        );
                      },
                      child: const Icon(
                        Icons.backspace,
                        color: Colors.black,
                        size: 24,
                      ),
                    ),
                  ],
                ),
              ),

              /// reset button
              TextButton(
                onPressed: () {
                  // setState(() {
                  //   enteredPin = '';
                  //   if (enteredPin.length < 1) {
                  //     Get.snackbar(
                  //         "Alerte", "Le champ de saisi est déjà vide !");
                  //   }
                  // });
                  Get.to(ForgetPassScreen(),
                      duration: Duration(seconds: 1),
                      transition: Transition.leftToRight);
                },
                child: const Text(
                  'Réinitialiser le code ',
                  style: TextStyle(
                    fontSize: 20,
                    color: Colors.black,
                  ),
                ),
              ),

              const SizedBox(
                height: 10,
              ),
              Container(
                height: 30,
                // decoration: const BoxDecoration(
                //   color: Color.fromARGB(255, 240, 178, 107),
                // ),
                child: Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        "Pas de compte ?.",
                        style: TextStyle(
                            color: Colors.black,
                            fontSize: 19,
                            fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(
                        width: 4,
                      ),
                      GestureDetector(
                        onTap: () {
                          Get.to(RegisterScreen(),
                              duration: Duration(seconds: 1),
                              transition: Transition.leftToRight);
                        },
                        child: const Text(
                          "S'inscrire",
                          style: TextStyle(
                              color: const Color.fromARGB(255, 3, 100, 179),
                              fontSize: 22,
                              fontStyle: FontStyle.italic,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
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
