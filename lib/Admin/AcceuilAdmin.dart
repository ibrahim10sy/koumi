import 'dart:async';

import 'package:koumi/widgets/ProductSearchPage.dart';
import 'package:koumi/widgets/SearchProductButton.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:koumi/Admin/ActeurScreen.dart';
import 'package:koumi/Admin/AlerteScreen.dart';
import 'package:koumi/Admin/CategoriePage.dart';
import 'package:koumi/Admin/FiliereScreen.dart';
import 'package:koumi/Admin/ProfilA.dart';
import 'package:koumi/models/Acteur.dart';
import 'package:koumi/providers/ActeurProvider.dart';
import 'package:koumi/providers/CountryProvider.dart';
import 'package:koumi/screens/ComplementAlimentaire.dart';
import 'package:koumi/screens/ConseilScreen.dart';
import 'package:koumi/screens/EngraisAndApport.dart';
import 'package:koumi/screens/FruitsAndLegumes.dart';
import 'package:koumi/screens/IntrantPage.dart';
import 'package:koumi/screens/MatereilAndEquipement.dart';
import 'package:koumi/screens/MesCommande.dart';
import 'package:koumi/screens/MyProduct.dart';
import 'package:koumi/screens/Panier.dart';
import 'package:koumi/screens/Location.dart' as l;
import 'package:koumi/screens/Products.dart';
import 'package:koumi/screens/ProduitElevage.dart';
import 'package:koumi/screens/ProduitPhytosanitaire.dart';
import 'package:koumi/screens/ProduitTransforme.dart';
import 'package:koumi/screens/SemenceAndPlant.dart';
import 'package:koumi/screens/Store.dart';
import 'package:koumi/screens/Transport.dart';
import 'package:koumi/screens/Weather.dart';
import 'package:koumi/widgets/Carrousel.dart';
import 'package:koumi/widgets/CustomAppBar.dart';
import 'package:koumi/widgets/DetectorPays.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AcceuilAdmin extends StatefulWidget {
  const AcceuilAdmin({super.key});

  @override
  State<AcceuilAdmin> createState() => _AcceuilAdminState();
}

const d_colorGreen = Color.fromRGBO(43, 103, 6, 1);
const d_colorOr = Color.fromRGBO(255, 138, 0, 1);

class _AcceuilAdminState extends State<AcceuilAdmin> {
  late Acteur acteur = Acteur();

  String? email = "";
  bool isExist = false;

  String? detectedC;
  String? isoCountryCode;
  String? country;
  String? detectedCountryCode;
  String? detectedCountry;
  CountryProvider? countryProvider;
  late BuildContext _currentContext;

  void verify() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    email = prefs.getString('whatsAppActeur');
    if (email != null) {
      // Si l'email de l'acteur est présent, exécute checkLoggedIn
      acteur = Provider.of<ActeurProvider>(context, listen: false).acteur!;
      setState(() {
        isExist = true;
      });
    } else {
      setState(() {
        isExist = false;
      });
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    verify();
    // getLocation();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromRGBO(255, 255, 255, 1),
      appBar: const CustomAppBar(),
      body: ListView(
        children: [
          SizedBox(height: 180, child: Carrousel(pays: acteur.niveau3PaysActeur,)),
          const SizedBox(
            height: 10,
          ),
          Center(
            child: SearchProductButton(
              onTap: () {
                // Naviguer vers l'écran de recherche
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ProductSearchPage()),
                );
              },
            ),
          ),
          const SizedBox(
            height: 10,
          ),
          SizedBox(
            child: GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              crossAxisSpacing: 4,
              childAspectRatio: 2,
              children: _buildCards(),
            ),
          ),
          const SizedBox(
            height: 20,
          )
        ],
      ),
    );
  }

  List<Widget> _buildCards() {
    List<Widget> cards = [
      _buildAccueilCard("Conseils", "cons1.png", 2, 40.0, 40.0),
      _buildAccueilCard("Alertes", "alt21.png", 8, 50.0, 50.0),
      // _buildAccueilCard("Commandes", "cm.png", 3),
      _buildAccueilCard(
          "Produits agricoles & élevages", "fruit&legume.png", 9, 40.0, 40.0),
      _buildAccueilCard("Intrants agricoles", "engrais.png", 1, 35.0, 35.0),
      _buildAccueilCard("Materiels de Locations", "loc.png", 7, 40.0, 40.0),
      _buildAccueilCard("Moyens de Transports", "transp.png", 6, 40.0, 40.0),
      _buildAccueilCard("Filières", "fi.jpg", 10, 33.0, 33.0),
      _buildAccueilCard("Catégories", "c.jpg", 11, 33.0, 33.0),
      _buildAccueilCard("Magasins", "shop1.png", 4, 50.0, 50.0),
      _buildAccueilCard("Acteurs", "ac1.png", 12, 43.0, 43.0),
      _buildAccueilCard("Météo", "met1.png", 5, 45.0, 45.0),
    ];

    return cards;
  }

  Widget _buildAccueilCard(
      String titre, String imgLocation, int index, double w, double h) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 7),
      child: InkWell(
        onTap: () {
          if (index == 20) {
            Navigator.push(context,
                MaterialPageRoute(builder: (context) => ProduitTransforme()));
          } else if (index == 19) {
            Navigator.push(context,
                MaterialPageRoute(builder: (context) => ProduitElevage()));
          } else if (index == 18) {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => ComplementAlimentaire()));
          } else if (index == 17) {
            Navigator.push(context,
                MaterialPageRoute(builder: (context) => EngraisAndApport()));
          } else if (index == 16) {
            Navigator.push(context,
                MaterialPageRoute(builder: (context) => FruitAndLegumes()));
          } else if (index == 15) {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => ProduitPhytosanitaire()));
          } else if (index == 14) {
            Navigator.push(context,
                MaterialPageRoute(builder: (context) => SemenceAndPlant()));
          } else if (index == 13) {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => MaterielAndEquipement()));
          } else if (index == 12) {
            Navigator.push(context,
                MaterialPageRoute(builder: (context) => const ActeurScreen()));
          } else if (index == 11) {
            Navigator.push(context,
                MaterialPageRoute(builder: (context) => const CategoriPage()));
          } else if (index == 10) {
            Navigator.push(context,
                MaterialPageRoute(builder: (context) => const FiliereScreen()));
          } else if (index == 9) {
            Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ProductsScreen(),
                ));
          } else if (index == 8) {
            Navigator.push(
                context,
                MaterialPageRoute(
                    // builder: (context) => const AlertesOffLineScreen()));
                    builder: (context) => const AlerteScreen()));
          } else if (index == 7) {
            Navigator.push(
                context, MaterialPageRoute(builder: (context) => l.Location()));
          } else if (index == 6) {
            Navigator.push(
                context, MaterialPageRoute(builder: (context) => Transport()));
          } else if (index == 5) {
            Navigator.push(context,
                MaterialPageRoute(builder: (context) => const WeatherScreen()));
          } else if (index == 4) {
            Navigator.push(context,
                MaterialPageRoute(builder: (context) => StoreScreen()));
          }
          //  else if (index == 3) {
          //   Navigator.push(context,
          //       MaterialPageRoute(builder: (context) => const MesCommande()));
          // }
          else if (index == 2) {
            Navigator.push(context,
                MaterialPageRoute(builder: (context) => const ConseilScreen()));
          } else if (index == 1) {
            Navigator.push(context,
                MaterialPageRoute(builder: (context) => IntrantPage()));
          }
        },
        borderRadius: BorderRadius.circular(10),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: Colors.white,
            boxShadow: const [
              BoxShadow(
                blurRadius: 4.0,
                offset: Offset(0, 1),
                color: Color.fromRGBO(0, 0, 0, 0.20), // Opacité de 10%
              ),
            ],
          ),
          child: Row(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Image.asset("assets/images/$imgLocation",
                    width: w, height: h),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(5.0),
                  child: Text(
                    titre,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.left,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildPageView() {
    return SizedBox(
      // height:MediaQuery.of(context).size.height,
      height: MediaQuery.of(context).size.height * 0.90,
      child: PageView(
        children: [
          const AcceuilAdmin(),
          MyProductScreen(),
          // Panier(),
          const ProfilA()
        ],
      ),
    );
  }
}
