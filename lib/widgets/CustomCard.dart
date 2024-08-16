import 'package:flutter/material.dart';
import 'package:koumi/screens/CommandeScreen.dart';

import 'package:koumi/screens/ComplementAlimentaire.dart';
import 'package:koumi/screens/ConseilScreen.dart';
import 'package:koumi/screens/EngraisAndApport.dart';
import 'package:koumi/screens/FruitsAndLegumes.dart';
import 'package:koumi/screens/IntrantScreen.dart';
import 'package:koumi/screens/Location.dart' as l;
import 'package:koumi/screens/MatereilAndEquipement.dart';
import 'package:koumi/screens/MesCommande.dart';
import 'package:koumi/screens/Products.dart';
import 'package:koumi/screens/ProduitElevage.dart';
import 'package:koumi/screens/ProduitPhytosanitaire.dart';
import 'package:koumi/screens/ProduitTransforme.dart';
import 'package:koumi/screens/SemenceAndPlant.dart';
import 'package:koumi/screens/Store.dart';
import 'package:koumi/screens/Transport.dart';
import 'package:koumi/screens/Weather.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CustomCard extends StatefulWidget {
  const CustomCard({super.key});

  @override
  State<CustomCard> createState() => _CustomCardState();
}

const d_colorGreen = Color.fromRGBO(43, 103, 6, 1);
const d_colorOr = Color.fromRGBO(255, 138, 0, 1);

class _CustomCardState extends State<CustomCard> {
  late Future<Map<String, dynamic>> future;
  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 3,
            children: [
      _buildAccueilCard("Conseils", "conseil.png", 1),
      _buildAccueilCard("Intrants", "intrant.png", 2),
      _buildAccueilCard("Commandes", "commande.png", 3),
      _buildAccueilCard("Magasin", "magasin.png", 4),
      _buildAccueilCard("Meteo", "meteo.png", 5),
      _buildAccueilCard("Transports", "transport.png", 6),
      // _buildAccueilCard("Statistique", "statistique_logo.png", 4)
            ],
          ),
    );
  }

  Widget _buildAccueilCard(String titre, String imgLocation, int index) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: InkWell(
          onTap: () {
            if (index == 6) {
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) =>  Transport()));
            } else if (index == 5) {
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => const WeatherScreen()));
            } else if (index == 4) {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) =>  StoreScreen()));
            } else if (index == 3) {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const CommandeScreen()));
            } else if (index == 2) {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) =>  IntrantScreen()));
            } else if (index == 1) {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const ConseilScreen()));
            }
          },
          borderRadius: BorderRadius.circular(28),
          highlightColor: d_colorOr,
          child: Card(
            color: Colors.white,
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(28),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width: MediaQuery.of(context).size.width *
                      0.20, // Set width to 80% of the screen width
                  child: Image.asset(
                    "assets/images/$imgLocation",
                    fit: BoxFit
                        .cover, // You can adjust the BoxFit based on your needs
                  ),
                ),
                const SizedBox(
                  height: 5,
                ),
                Text(
                  titre,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          )),
    );
  }
}
