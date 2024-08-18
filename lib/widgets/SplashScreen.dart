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

  Future<void> clearCart() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('cart');
    // Récupérer le codeActeur depuis SharedPreferences
    String? codeActeur = prefs.getString('codeActeur');
    String? emailActeur = prefs.getString('emailActeur');

    if (emailActeur == null || emailActeur.isEmpty) {
      // Nettoyer toutes les données de SharedPreferences
      // await prefs.clear();
      debugPrint("Email shared : $emailActeur");
    } else {
      debugPrint("Email shared isExist : $emailActeur");
    }

// Vérifier si le codeActeur est présent dans SharedPreferences
    if (codeActeur == null || codeActeur.isEmpty) {
      // Gérer le cas où le codeActeur est manquant
      // Sauvegarder le codeActeur avant de nettoyer les SharedPreferences
      String savedCodeActeur = "VF212";
      // String savedCodeActeur = codeActeur;

      // Nettoyer toutes les données de SharedPreferences
      await prefs.clear();

      // Réenregistrer le codeActeur dans SharedPreferences
      prefs.setString('codeActeur', savedCodeActeur);
    } else {
      // Sauvegarder le codeActeur avant de nettoyer les SharedPreferences
      String savedCodeActeur = "VF212";

      // // Nettoyer toutes les données de SharedPreferences
      await prefs.clear();

      // // Réenregistrer le codeActeur dans SharedPreferences
      prefs.setString('codeActeur', savedCodeActeur);
    }
  }

  void checkLoggedIn() async {
    // Initialise les données de l'utilisateur à partir de SharedPreferences
    await Provider.of<ActeurProvider>(context, listen: false)
        .initializeActeurFromSharedPreferences();

    if (Provider.of<ActeurProvider>(context, listen: false).acteur != null) {
      acteur = Provider.of<ActeurProvider>(context, listen: false).acteur!;
      print("acteur ${acteur.toString()}");
      // Vérifie si l'utilisateur est déjà connecté
      if (acteur != null) {
        // Vérifie si l'utilisateur est un administrateur
        if (acteur.typeActeur!.any(
            (type) => type.libelle!.toLowerCase() == 'admin' || type.libelle == 'Admin')) {
          Timer(
            const Duration(seconds: 3),
            () => Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (_) => const BottomNavBarAdmin()),
            ),
          );
        } else if (acteur.typeActeur!.any((type) =>
            type.libelle!.toLowerCase() == 'transformateur' ||
            type.libelle!.toLowerCase() == 'producteur' ||
            type.libelle!.toLowerCase() == 'producteur' ||
            type.libelle!.toLowerCase() == 'commercant' ||
            type.libelle!.toLowerCase() == 'commerçant' ||
            type.libelle!.toLowerCase() == 'commercants')) {
          Timer(const Duration(seconds: 3), () {
            Get.offAll(BottomNavigationPage(),
                transition: Transition.leftToRight);
            Provider.of<BottomNavigationService>(context, listen: false)
                .changeIndex(1);
          });
        } else if (acteur.typeActeur!.any((type) =>
            type.libelle!.toLowerCase() == 'transporteur' ||
            type.libelle!.toLowerCase() == 'transporteurs')) {
          Timer(const Duration(seconds: 3), () {
            Get.offAll(VehiculeActeur(),
                transition: Transition.leftToRight);
          });
        } else if (acteur.typeActeur!.any((type) =>
            type.libelle!.toLowerCase() == 'fournisseur' ||
            type.libelle!.toLowerCase() == 'fournisseurs')) {
          Timer(const Duration(seconds: 3), () {
            Get.offAll(ListeIntrantByActeur(),
                transition: Transition.leftToRight);
          });
        } 
        else {
          Timer(
            const Duration(seconds: 2),
            () => Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (_) => BottomNavigationPage()),
            ),
          );
        }
      }
    } else {
      Timer(
        const Duration(seconds: 5),
        () => Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => BottomNavigationPage()),
        ),
      );
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
