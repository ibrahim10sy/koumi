import 'package:flutter/material.dart';
import 'package:koumi/constants.dart';
import 'package:http/http.dart' as http;
import 'package:koumi/models/Acteur.dart';
import 'package:koumi/providers/ActeurProvider.dart';
import 'package:koumi/widgets/PaymentPage.dart';
import 'package:koumi/widgets/Subscribe.dart';
import 'dart:convert';
import 'dart:io';
import '../service/AbonnementServices .dart';
import 'package:provider/provider.dart';

import 'package:koumi/models/TypeActeur.dart';
import 'package:koumi/widgets/LoadingOverlay.dart';

class Nextsubscriptionpage extends StatefulWidget {
  final String? selectedPlan;
  Nextsubscriptionpage({super.key, this.selectedPlan});

  @override
  State<Nextsubscriptionpage> createState() => _NextsubscriptionpageState();
}

const d_colorGreen = Color.fromRGBO(43, 103, 6, 1);
const d_colorOr = Color.fromRGBO(255, 138, 0, 1);

class _NextsubscriptionpageState extends State<Nextsubscriptionpage> {
  String? selected; // Pour stocker le plan sélectionné
  String? selectedOption;
  String? paymentMethod;
  int totalPrice = 0;
  late Future _typeList;
  bool _isLoading = false;
  Acteur? acteur;
  TextEditingController typeController = TextEditingController();
  late TextEditingController _searchController;

  // Liste des options supplémentaires
  final List<String> options = [];

  void calculatePrice() {
    int basePrice = 0;
    int optionPrice = 0;

    switch (selected) {
      case 'semestriel':
        basePrice = 10;
        break;
      case 'annuel':
        basePrice = 20;
        break;
      default:
        basePrice = 0;
    }

    // Parcourir les options sélectionnées et additionner leurs prix
    for (String p in options) {
      switch (p.toLowerCase()) {
        case 'fournisseur':
          optionPrice += 5000;
          break;
        case 'transporteur':
          optionPrice += 1000;
          break;
        case 'commerçant':
          optionPrice += 15000;
          break;
        case 'transformateur':
          optionPrice += 12000;
          break;
        case 'producteur':
          optionPrice += 13000;
          break;
        case 'prestataire':
          optionPrice += 5000;
          break;
        case 'partenaires de développement':
          optionPrice += 7000;
          break;
        default:
          optionPrice += 0;
      }
    }

    // Calculer le prix total
    setState(() {
      totalPrice = basePrice + optionPrice;
    });
  }

  @override
  void initState() {
    selected = widget.selectedPlan;
    _typeList = http.get(Uri.parse('$apiOnlineUrl/typeActeur/read'));
    _searchController = TextEditingController();
    acteur = Provider.of<ActeurProvider>(context, listen: false).acteur!;
    super.initState();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LoadingOverlay(
      isLoading: _isLoading,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: d_colorOr,
          toolbarHeight: 75,
          leading: IconButton(
            onPressed: () {
              Navigator.pop(context, true);
            },
            icon: const Icon(
              Icons.arrow_back_ios,
              color: Colors.white,
            ),
          ),
          title: const Text(
            "Confirmation d'abonnement",
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(10.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // SizedBox(height: 20),
                Text(
                  'Vous avez choisi le plan :',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 10),
                Text(
                  selected ?? 'Aucun plan sélectionné',
                  style: TextStyle(fontSize: 16, color: Colors.green),
                ),
                SizedBox(height: 10),

                Text(
                  'Sélectionnez une option supplémentaire :',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 10),
                GestureDetector(
                  onTap: _showMultiSelectDialogt,
                  child: TextFormField(
                    onTap: _showMultiSelectDialogt,
                    controller: typeController,
                    decoration: InputDecoration(
                      suffixIcon: Icon(Icons.arrow_drop_down,
                          color: Colors.blueGrey[400]),
                      hintText: "Sélectionner un type acteur",
                      contentPadding: const EdgeInsets.symmetric(
                          vertical: 10, horizontal: 20),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 15),
                Text(
                  'Méthode de paiement :',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 10),

                // Boutons radio pour les méthodes de paiement
                ListTile(
                  title: const Text('Orange Money'),
                  leading: Radio<String>(
                    value: 'Orange Money',
                    groupValue: paymentMethod,
                    onChanged: (String? value) {
                      setState(() {
                        paymentMethod = value;
                      });
                    },
                  ),
                ),
                ListTile(
                  title: const Text('Mobi Cash'),
                  leading: Radio<String>(
                    value: 'Mobi Cash',
                    groupValue: paymentMethod,
                    onChanged: (String? value) {
                      setState(() {
                        paymentMethod = value;
                      });
                    },
                  ),
                ),

                SizedBox(height: 20),
                Center(
                  child: Text(
                    'Prix total : ${totalPrice.toStringAsFixed(2)} FCFA',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
                  ),
                ),

                SizedBox(height: 10),
                SizedBox(
                  height: 300,
                  child: Center(
                    child: ElevatedButton(
                      onPressed: () async {
                        final option = options;
                        final payment = paymentMethod;
                        final type = selected;
                        final price = totalPrice;
                        if (selected == null || paymentMethod == null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                  'Veuillez sélectionner une option et une méthode de paiement'),
                            ),
                          );
                        } else {
                          try {
                            setState(() {
                              _isLoading = true;
                            });
                            await AbonnementServices()
                                .addAbonnements(
                                    modePaiement: payment!,
                                    typeAbonnement: type!,
                                    acteur: acteur!,
                                    montant: price,
                                    options: option)
                                .then((onValue) {
                              setState(() {
                                _isLoading = false;
                              });
                              showSuccessDialog(context,
                                  "Votre abonnement sera activé une fois le paiement effectuer. Merci");
                              Navigator.pop(context, true);
                            }).catchError((onError) {
                              print("Catch error : ${onError.message}");
                              setState(() {
                                _isLoading = false;
                              });
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(
                                        child: Text(
                                          "Une erreur s'est produite",
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
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  behavior: SnackBarBehavior
                                      .floating, // Flottant pour un style moderne
                                  margin: EdgeInsets.all(
                                      10), // Espace autour du SnackBar
                                ),
                              );
                            });
                          } catch (e) {
                            print("Catch  : ${e.toString()}");
                            setState(() {
                              _isLoading = false;
                            });
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Text(
                                        "Une erreur s'est produite",
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
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                behavior: SnackBarBehavior
                                    .floating, // Flottant pour un style moderne
                                margin: EdgeInsets.all(
                                    10), // Espace autour du SnackBar
                              ),
                            );
                          }
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: d_colorOr,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        minimumSize: const Size(250, 40),
                      ),
                      child: Text(
                        'Confirmer',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
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
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => Subscribe()));
                // Navigator.pop(context, true);
              },
              child: const Text('Annuler'),
            ),
            TextButton(
              onPressed: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => PaymentPage()));
                // Navigator.pop(context, true);
              },
              child: const Text('Payer'),
            ),
          ],
        );
      },
    );
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
                    hintText: 'Rechercher un type',
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
                      List<TypeActeur> typeListe = responseData
                          .map((e) => TypeActeur.fromMap(e))
                          .where((con) => con.statutTypeActeur == true)
                          .toList();

                      if (typeListe.isEmpty) {
                        return const Padding(
                          padding: EdgeInsets.all(10),
                          child: Center(child: Text("Aucun type trouvé")),
                        );
                      }

                      String searchText = _searchController.text.toLowerCase();
                      List<TypeActeur> filteredSearch = typeListe
                          .where((typeActeur) =>
                              typeActeur.libelle!
                                  .toLowerCase()
                                  .contains(searchText) &&
                              typeActeur.libelle!.toLowerCase() != 'admin')
                          .toList();

                      return filteredSearch.isEmpty
                          ? const Text(
                              'Aucun type trouvé',
                              style:
                                  TextStyle(color: Colors.black, fontSize: 17),
                            )
                          : SizedBox(
                              width: double.maxFinite,
                              child: ListView.builder(
                                itemCount: filteredSearch.length,
                                itemBuilder: (context, index) {
                                  final typeActeur =
                                      filteredSearch[index].libelle;
                                  final isSelected =
                                      options.contains(typeActeur);

                                  return Column(
                                    children: [
                                      ListTile(
                                        title: Text(
                                          typeActeur!,
                                          style: TextStyle(
                                            color: Colors.black,
                                            fontWeight: isSelected
                                                ? FontWeight.bold
                                                : FontWeight.normal,
                                            fontSize: 16,
                                          ),
                                        ),
                                        trailing: isSelected
                                            ? const Icon(
                                                Icons.check_box_outlined,
                                                color: d_colorOr,
                                              )
                                            : null,
                                        onTap: () {
                                          setState(() {
                                            isSelected
                                                ? options.remove(typeActeur)
                                                : options.add(typeActeur);
                                            calculatePrice();
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
                    style: TextStyle(color: d_colorOr, fontSize: 16),
                  ),
                  onPressed: () {
                    _searchController.clear();
                    Navigator.of(context).pop();
                  },
                ),
                TextButton(
                  child: const Text(
                    'Valider',
                    style: TextStyle(color: d_colorOr, fontSize: 16),
                  ),
                  onPressed: () {
                    List<String> typeLibelle = options.map((e) => e).toList();
                    typeController.text = typeLibelle.join(', ');
                    _searchController.clear();
                    calculatePrice();
                    print('Options sélectionnées : $options');
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
}
