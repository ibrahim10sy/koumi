import 'package:flutter/material.dart';
import 'package:koumi/models/Abonnement.dart';
import 'package:koumi/models/Acteur.dart';
import 'package:koumi/providers/ActeurProvider.dart';
import 'package:koumi/widgets/BottomNavBarAdmin.dart';
import 'package:koumi/widgets/BottomNavigationPage.dart';
import 'package:koumi/widgets/SubscriptionPage.dart';
import 'package:koumi/widgets/historiqueAbonnement.dart';
import 'package:provider/provider.dart';
import 'dart:developer';
import '../service/AbonnementServices .dart';
import 'package:get/get.dart';

class Subscribe extends StatefulWidget {
  const Subscribe({super.key});

  @override
  State<Subscribe> createState() => _SubscribeState();
}

const d_colorGreen = Color.fromRGBO(43, 103, 6, 1);
const d_colorOr = Color.fromRGBO(255, 138, 0, 1);

class _SubscribeState extends State<Subscribe> {
  Acteur? acteur;
  Future<Abonnement?>? _liste;

  Future<Abonnement?> getAbonnement(String id) async {
    return await AbonnementServices().fetchLatestAbonnement(id);
  }

  @override
  void initState() {
    super.initState();
    acteur = Provider.of<ActeurProvider>(context, listen: false).acteur!;
    print("id : ${acteur!.idActeur}");
    _liste = getAbonnement(acteur!.idActeur!);
  }

  Future<void> _getResultFromZonePage(BuildContext context) async {
    final result = await Navigator.push(
        context, MaterialPageRoute(builder: (context) => SubscriptionPage()));
    log(result.toString());
    if (result == true) {
      _liste = getAbonnement(acteur!.idActeur!);
      print("Rafraichissement en cours");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: d_colorOr,
        toolbarHeight: 75,
        leading: IconButton(
          onPressed: () {
            final List<String> type =
                acteur!.typeActeur!.map((e) => e.libelle!).toList();
            if (type.contains('admin') || type.contains('Admin')) {
              Get.offAll(BottomNavBarAdmin(),
                 
                  transition: Transition.leftToRight);
            } else {
              Get.offAll(BottomNavigationPage(),
                  transition: Transition.leftToRight);
            }
          },
          icon: const Icon(
            Icons.arrow_back_ios,
            color: Colors.white,
          ),
        ),
        title: const Text(
          "Mon Abonnement",
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton(
                  onPressed: () {
                    // Navigator.push(
                    //     context,
                    //     MaterialPageRoute(
                    //         builder: (context) => SubscriptionPage()));
                    _getResultFromZonePage(context);
                  },
                  child: Row(
                    children: [
                      Icon(
                        Icons.add,
                        color: d_colorGreen,
                      ),
                      SizedBox(width: 8),
                      Text(
                        'Nouvel abonnement',
                        style: TextStyle(
                          color: d_colorGreen,
                          fontSize: 17,
                        ),
                      ),
                    ],
                  ),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => HistoriqueAbonnement()));
                  },
                  child: Row(
                    children: [
                      Icon(
                        Icons.remove_red_eye,
                        color: d_colorGreen,
                      ),
                      SizedBox(width: 8), // Space between icon and text
                      Text(
                        'Historique',
                        style: TextStyle(
                          color: d_colorGreen,
                          fontSize: 17,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          if (acteur != null)
            FutureBuilder<Abonnement?>(
              future: _liste,
              // future: getAbonnement(acteur!.idActeur!),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(
                      color: Colors.orange,
                    ),
                  );
                }

                if (!snapshot.hasData || snapshot.data == null) {
                  return const Padding(
                    padding: EdgeInsets.all(10),
                    child: Center(child: Text("Aucun abonnement trouvé")),
                  );
                }

                Abonnement abonnement = snapshot.data!;

                return Padding(
                  padding: const EdgeInsets.all(10),
                  child: Card(
                    elevation: 5,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(15),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.code, color: d_colorOr),
                              SizedBox(width: 8),
                              Text(
                                "Code Abonnement: ${abonnement.codeAbonnement}",
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: d_colorGreen,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 10),
                          Row(
                            children: [
                              Icon(Icons.category, color: d_colorOr),
                              SizedBox(width: 8),
                              Text(
                                "Type Abonnement: ${abonnement.typeAbonnement}",
                                style: TextStyle(fontSize: 16),
                              ),
                            ],
                          ),
                          SizedBox(height: 10),
                          Row(
                            children: [
                              Icon(Icons.date_range, color: d_colorOr),
                              SizedBox(width: 8),
                              Text(
                                "Date d'ajout: ${abonnement.dateAjout}",
                                style: TextStyle(fontSize: 16),
                              ),
                            ],
                          ),
                          SizedBox(height: 10),
                          Row(
                            children: [
                              Icon(Icons.attach_money, color: d_colorOr),
                              SizedBox(width: 8),
                              Text(
                                "Montant: ${abonnement.montant} FCFA",
                                style: TextStyle(fontSize: 16),
                              ),
                            ],
                          ),
                          SizedBox(height: 10),
                          Row(
                            children: [
                              Icon(Icons.check_circle,
                                  color: abonnement.statutAbonnement!
                                      ? Colors.green
                                      : Colors.red),
                              SizedBox(width: 8),
                              Text(
                                "Statut: ${abonnement.statutAbonnement! ? 'Actif' : 'Inactif'}",
                                style: TextStyle(
                                  fontSize: 16,
                                  color: abonnement.statutAbonnement!
                                      ? Colors.green
                                      : Colors.red,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 10),
                          Row(
                            children: [
                              Icon(Icons.calendar_today, color: d_colorOr),
                              SizedBox(width: 8),
                              Text(
                                "Date Fin: ${abonnement.dateFin}",
                                style: TextStyle(fontSize: 16),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            )
          else
            const Padding(
              padding: EdgeInsets.all(10),
              child: Center(child: Text("Acteur non trouvé")),
            ),
        ],
      ),
    );
  }
}
