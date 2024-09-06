import 'dart:async';

import 'package:flutter/material.dart';
import 'package:koumi/models/Acteur.dart';
import 'package:koumi/providers/ActeurProvider.dart';
import 'package:koumi/screens/ListeIntrantByActeur.dart';
import 'package:koumi/screens/VehiculesActeur.dart';
import 'package:koumi/service/BottomNavigationService.dart';
import 'package:koumi/widgets/AnimatedBackground.dart';
import 'package:koumi/widgets/BottomNavBarAdmin.dart';
import 'package:koumi/widgets/BottomNavigationPage.dart';
import 'package:koumi/widgets/connection_verify.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';
import 'package:get/get.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

const d_colorPage = Color.fromRGBO(255, 255, 255, 1);

class _SplashScreenState extends State<SplashScreen> {
  late Acteur acteur;
  late ConnectionVerify connectionVerify;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    checkCodeActeurInSharedPreferences();
    // checkInternetConnection();
  }

  void checkCodeActeurInSharedPreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? codeAc = prefs.getString('codeActeur');
    if (codeAc != null) {
      checkLoggedIn();
    } else {
      Timer(
        const Duration(seconds: 5),
        () => Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => BottomNavigationPage()),
        ),
      );
      // Si l'email de l'acteur n'est pas présent, redirige directement vers l'écran de connexion
    }
  }

  void checkLoggedIn() async {
    // Initialise les données de l'utilisateur à partir de SharedPreferences
    await Provider.of<ActeurProvider>(context, listen: false)
        .initializeActeurFromSharedPreferences();

    // Vérifie si l'utilisateur est connecté
    if (Provider.of<ActeurProvider>(context, listen: false).acteur != null) {
      acteur = Provider.of<ActeurProvider>(context, listen: false).acteur!;
      print("acteur splash  ${acteur.nomActeur}");
      // Vérifie le type de profil et effectue la redirection appropriée
      if (acteur.codeActeur != null) {
        if (acteur.typeActeur!.any((type) =>
            type.libelle!.toLowerCase() == 'admin' ||
            type.libelle == 'Admin')) {
          Timer(
            const Duration(seconds: 3),
            () => Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (_) => const BottomNavBarAdmin()),
            ),
          );
        } else if (acteur.typeActeur!.any((type) =>
            type.libelle!.toLowerCase() == 'producteur' ||
            type.libelle!.toLowerCase() == 'commercant' ||
            type.libelle!.toLowerCase() == 'commerçant' ||
            type.libelle!.toLowerCase() == 'transformeur' ||
            type.libelle!.toLowerCase() == 'transformateur' ||
            type.libelle!.toLowerCase() == 'partenaires de développement')) {
          Timer(const Duration(seconds: 2), () {
            Get.offAll(BottomNavigationPage(),
                transition: Transition.leftToRight);
            Provider.of<BottomNavigationService>(context, listen: false)
                .changeIndex(1);
          });
        } else if (acteur.typeActeur!
            .any((type) => type.libelle!.toLowerCase() == 'fournisseur')) {
          Timer(const Duration(seconds: 2), () {
            Get.offAll(BottomNavigationPage(),
                transition: Transition.leftToRight);
            Provider.of<BottomNavigationService>(context, listen: false)
                .changeIndex(1);
          });
        } else if (acteur.typeActeur!
            .any((type) => type.libelle!.toLowerCase() == 'transporteur')) {
          // Mise à jour de l'index de navigation
          Timer(const Duration(seconds: 2), () {
            Get.offAll(BottomNavigationPage(),
                transition: Transition.leftToRight);
            Provider.of<BottomNavigationService>(context, listen: false)
                .changeIndex(1);
          });
        } else if (acteur.typeActeur!
            .any((type) => type.libelle!.toLowerCase() == 'prestataire')) {
          // Mise à jour de l'index de navigation
          Timer(const Duration(seconds: 2), () {
            Get.offAll(BottomNavigationPage(),
                transition: Transition.leftToRight);
            Provider.of<BottomNavigationService>(context, listen: false)
                .changeIndex(1);
          });
        }
      } else {
        // Redirection par défaut si l'utilisateur n'est pas trouvé
        Timer(const Duration(seconds: 2), () {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (_) => BottomNavigationPage()),
          );
          Provider.of<BottomNavigationService>(context, listen: false)
              .changeIndex(0);
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: d_colorPage,
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const AnimatedBackground(),
          const SizedBox(height: 10),
          Center(
              child: Image.asset(
            'assets/images/logo.png',
            height: 350,
            width: 250,
          )),
          CircularProgressIndicator(
            backgroundColor: (Color.fromARGB(255, 245, 212, 169)),
            color: (Colors.orange),
          ),
        ],
      ),
    );
  }
}
