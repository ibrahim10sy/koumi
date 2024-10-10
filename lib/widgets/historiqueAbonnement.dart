import 'package:flutter/material.dart';
import 'package:koumi/models/Abonnement.dart';
import 'package:koumi/models/Acteur.dart';
import 'package:koumi/providers/ActeurProvider.dart';
import 'package:koumi/widgets/SubscriptionPage.dart';
import 'package:provider/provider.dart';

import '../service/AbonnementServices .dart';

class HistoriqueAbonnement extends StatefulWidget {
  const HistoriqueAbonnement({super.key});

  @override
  State<HistoriqueAbonnement> createState() => _HistoriqueAbonnementState();
}

const d_colorGreen = Color.fromRGBO(43, 103, 6, 1);
const d_colorOr = Color.fromRGBO(255, 138, 0, 1);

class _HistoriqueAbonnementState extends State<HistoriqueAbonnement> {
  Acteur? acteur;
  late List<Abonnement> abonnement = [];
  Future<List<Abonnement>>? _liste;

  Future<List<Abonnement>> getAbonnement(String id) async {
    return await AbonnementServices().fetchAbonnement(id);
  }

  @override
  void initState() {
    super.initState();
    acteur = Provider.of<ActeurProvider>(context, listen: false).acteur!;
    print("id : ${acteur!.idActeur}");
    _liste = getAbonnement(acteur!.idActeur!);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: d_colorOr,
        toolbarHeight: 75,
        leading: IconButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          icon: const Icon(
            Icons.arrow_back_ios,
            color: Colors.white,
          ),
        ),
        title: const Text(
          "Mes Abonnements",
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => SubscriptionPage()));
                    },
                    child: Row(
                      children: [
                        Icon(
                          Icons.add,
                          color: d_colorGreen,
                        ),
                        SizedBox(width: 8), // Space between icon and text
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
                              builder: (context) => SubscriptionPage()));
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
              FutureBuilder(
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

                  abonnement = snapshot.data!;

                  return Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: abonnement
                          .map((Abonnement ab) => Card(
                                elevation: 5,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(15),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(12.0),
                                  child: Column(
                                    children: [
                                      Row(
                                        children: [
                                          Icon(Icons.code, color: d_colorOr),
                                          SizedBox(width: 8),
                                          Text(
                                            "Code Abonnement: ${ab.codeAbonnement}",
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
                                          Icon(Icons.category,
                                              color: d_colorOr),
                                          SizedBox(width: 8),
                                          Text(
                                            "Type Abonnement: ${ab.typeAbonnement}",
                                            style: TextStyle(fontSize: 16),
                                          ),
                                        ],
                                      ),
                                      SizedBox(height: 10),
                                      Row(
                                        children: [
                                          Icon(Icons.date_range,
                                              color: d_colorOr),
                                          SizedBox(width: 8),
                                          Text(
                                            "Date d'ajout: ${ab.dateAjout}",
                                            style: TextStyle(fontSize: 16),
                                          ),
                                        ],
                                      ),
                                      SizedBox(height: 10),
                                      Row(
                                        children: [
                                          Icon(Icons.attach_money,
                                              color: d_colorOr),
                                          SizedBox(width: 8),
                                          Text(
                                            "Montant: ${ab.montant} FCFA",
                                            style: TextStyle(fontSize: 16),
                                          ),
                                        ],
                                      ),
                                      SizedBox(height: 10),
                                      Row(
                                        children: [
                                          Icon(Icons.check_circle,
                                              color: ab.statutAbonnement!
                                                  ? Colors.green
                                                  : Colors.red),
                                          SizedBox(width: 8),
                                          Text(
                                            "Statut: ${ab.statutAbonnement! ? 'Actif' : 'Inactif'}",
                                            style: TextStyle(
                                              fontSize: 16,
                                              color: ab.statutAbonnement!
                                                  ? Colors.green
                                                  : Colors.red,
                                            ),
                                          ),
                                        ],
                                      ),
                                      SizedBox(height: 10),
                                      Row(
                                        children: [
                                          Icon(Icons.calendar_today,
                                              color: d_colorOr),
                                          SizedBox(width: 8),
                                          Text(
                                            "Date Fin: ${ab.dateFin}",
                                            style: TextStyle(fontSize: 16),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ))
                          .toList(),
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
      ),
    );
  }
}
