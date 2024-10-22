import 'dart:async';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:koumi/models/Acteur.dart';
import 'package:koumi/models/Superficie.dart';
import 'package:koumi/providers/ActeurProvider.dart';
import 'package:koumi/screens/AddSuperficie.dart';
import 'package:koumi/screens/DetailSuperficie.dart';
import 'package:koumi/screens/UpdateSuperficie.dart';
import 'package:koumi/service/SuperficieService.dart';
import 'package:provider/provider.dart';
import 'package:geolocator/geolocator.dart';

class SuperficiePage extends StatefulWidget {
  const SuperficiePage({super.key});

  @override
  State<SuperficiePage> createState() => _SuperficiePageState();
}

const d_colorGreen = Color.fromRGBO(43, 103, 6, 1);
const d_colorOr = Color.fromRGBO(255, 138, 0, 1);

class _SuperficiePageState extends State<SuperficiePage> {
  TextEditingController descriptionController = TextEditingController();
  late TextEditingController _searchController;
  late Acteur acteur;
  List<Superficie> superficieList = [];
  bool isSearchMode = false;
  late ScrollController _scrollController;
  Position? _startPosition;
  double _totalDistance = 0;
  String distanceP = "0 mètres";
  String _positionP = "";
  StreamSubscription<Position>? _positionStream;
  late Future<List<Superficie>> _liste;

  Future<List<Superficie>> getCampListe(String id) async {
    final response = await SuperficieService().fetchSuperficieByActeur(id);
    return response;
  }

  @override
  void initState() {
    _scrollController = ScrollController();
    _searchController = TextEditingController();
    acteur = Provider.of<ActeurProvider>(context, listen: false).acteur!;
    _liste = getCampListe(acteur.idActeur!);
    _getPermissions();
    super.initState();
  }

  Future<void> _getPermissions() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Vérifier si le service de localisation est activé
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content:
                Text('Les autorisations de localisation sont désactivées')),
      );
      return;
    }

    // Vérifier les permissions de localisation
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Les autorisations de localisation sont refusées')),
        );
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text(
                'Les autorisations de localisation sont refusées de manière permanente.')),
      );
      return;
    }
  }

  void _startTracking() {
    print("Début du parcours");
    _positionStream = Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.bestForNavigation,
        distanceFilter: 1,
      ),
    ).listen((Position position) {
      log("Nouvelle position reçue: ${position.latitude}, ${position.longitude}");

      if (_startPosition == null) {
        _startPosition = position;
        log("Position initiale: $_startPosition");
      } else {
        // Calculer la distance entre la position précédente et la nouvelle
        double distance = Geolocator.distanceBetween(
          _startPosition!.latitude,
          _startPosition!.longitude,
          position.latitude,
          position.longitude,
        );

        setState(() {
          // Incrémenter la distance totale
          _totalDistance += distance;
          distanceP = "${_totalDistance.toStringAsFixed(2)} mètres";
          _startPosition = position; // Mettre à jour la position de départ
          _positionP = "${_startPosition.toString()}";
          log("Distance incrémentée: $_totalDistance mètres");
        });
      }
    });
  }

  Future<void> _showDistancePopup() async {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, mySetStateFunc) {
            return AlertDialog(
              title: const Text("Mesure de la superficie"),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text("La distance parcourue est de :"),
                  const SizedBox(height: 20),
                  Text(
                    "${_totalDistance.toStringAsFixed(2)} mètres",
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 22,
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                      "Cliquez sur Valider pour envoyer la superficie mesurée."),
                ],
              ),
              actions: <Widget>[
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    _stopTracking();
                  },
                  child: const Text("Annuler"),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    _stopTracking();
                    _getResultFromNextScreen(context);
                  },
                  child: const Text("Valider",
                      style: TextStyle(color: d_colorGreen)),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _getResultFromNextScreen(BuildContext context) async {
    final result = await Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => AddSuperficie(
                distanceParcourue: distanceP, positionInitiale: _positionP)));
    log(result.toString());
    if (result == true) {
      print("Rafraichissement en cours");
      setState(() {
        _liste = getCampListe(acteur.idActeur!);
      });
    }
  }

  Future<void> _getResultFromNextScreen1(
      BuildContext context, Superficie s) async {
    final result = await Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => UpdateSuperficie(superficie: s)));
    log(result.toString());
    if (result == true) {
      print("Rafraichissement en cours");
      setState(() {
        _liste = getCampListe(acteur.idActeur!);
      });
    }
  }

  void _stopTracking() {
    _positionStream?.cancel();
    print(
        "total distance : ${_totalDistance.toStringAsFixed(2)} mètres et distance p : ${distanceP}");
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    _positionStream?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 250, 250, 250),
      appBar: AppBar(
        backgroundColor: d_colorOr,
        centerTitle: true,
        toolbarHeight: 75,
        leading: IconButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            icon: const Icon(Icons.arrow_back_ios, color: Colors.white)),
        title: const Text(
          "Superficie cultiver",
          style: TextStyle(
              color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20),
        ),
        actions: [
          IconButton(
              onPressed: () {
                setState(() {
                  _liste = getCampListe(acteur.idActeur!);
                });
              },
              icon: Icon(
                Icons.refresh,
                color: Colors.white,
              )),
        ],
      ),
      body: Container(
        child: NestedScrollView(
          headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
            return <Widget>[
              SliverToBoxAdapter(
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: TextButton(
                              onPressed: () {
                                showMenu<String>(
                                  context: context,
                                  position: RelativeRect.fromLTRB(
                                    0,
                                    50,
                                    MediaQuery.of(context).size.width,
                                    0,
                                  ),
                                  items: [
                                    PopupMenuItem<String>(
                                      value: 'add_fil',
                                      child: ListTile(
                                        leading: const Icon(
                                          Icons.add,
                                          color: d_colorGreen,
                                        ),
                                        title: const Text(
                                          "Demarrer",
                                          style: TextStyle(
                                            color: d_colorGreen,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                  elevation: 8.0,
                                ).then((value) async {
                                  if (value != null) {
                                    if (value == 'add_fil') {
                                      _startTracking();
                                      _showDistancePopup();
                                    }
                                  }
                                });
                              },
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.add,
                                    color: d_colorGreen,
                                  ),
                                  SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      'Mesurer votre superficie',
                                      maxLines: 2,
                                      textAlign: TextAlign.left,
                                      style: TextStyle(
                                        color: d_colorGreen,
                                        overflow: TextOverflow.ellipsis,
                                        fontSize: 16,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          TextButton.icon(
                            onPressed: () {
                              setState(() {
                                isSearchMode = !isSearchMode;
                                _searchController.clear();
                              });
                            },
                            icon: Icon(
                              isSearchMode ? Icons.close : Icons.search,
                              color: isSearchMode ? Colors.red : d_colorGreen,
                            ),
                            label: Text(
                              isSearchMode ? 'Fermer' : 'Rechercher...',
                              style: TextStyle(
                                  color:
                                      isSearchMode ? Colors.red : d_colorGreen,
                                  fontSize: 17),
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (isSearchMode)
                      Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: Container(
                          padding: EdgeInsets.symmetric(horizontal: 10),
                          decoration: BoxDecoration(
                            color: Colors.blueGrey[50],
                            borderRadius: BorderRadius.circular(25),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.search, color: Colors.blueGrey[400]),
                              SizedBox(width: 10),
                              Expanded(
                                child: TextField(
                                  controller: _searchController,
                                  onChanged: (value) {
                                    if (mounted) {
                                      setState(() {});
                                    }
                                  },
                                  decoration: InputDecoration(
                                    hintText: 'Rechercher',
                                    border: InputBorder.none,
                                    hintStyle: TextStyle(
                                      color: Colors.blueGrey[400],
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ];
          },
          body: SingleChildScrollView(
            controller: _scrollController,
            child: Column(
              children: [
                FutureBuilder(
                    future: _liste,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(
                          child: CircularProgressIndicator(
                            color: Colors.orange,
                          ),
                        );
                      }

                      if (!snapshot.hasData) {
                        return const Padding(
                          padding: EdgeInsets.all(10),
                          child: Center(child: Text("Aucun donné trouvé")),
                        );
                      } else {
                        superficieList = snapshot.data!;
                        debugPrint(superficieList.toString());
                        String searchText = "";
                        List<Superficie> filtereSearch =
                            superficieList.where((search) {
                          String libelle = search.localite!.toLowerCase();
                          searchText = _searchController.text.toLowerCase();
                          return libelle.contains(searchText);
                        }).toList();
                        return filtereSearch.isEmpty
                            ? Padding(
                                padding: EdgeInsets.all(10),
                                child:
                                    Center(child: Text("Aucune donné trouvé")),
                              )
                            : Column(
                                children: filtereSearch
                                    .map((e) => Padding(
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 10, horizontal: 15),
                                          child: GestureDetector(
                                            onTap: () {
                                              Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                      builder: (context) =>
                                                          DetailSuperficie(
                                                              suerficie: e)));
                                            },
                                            child: Container(
                                              width: MediaQuery.of(context)
                                                      .size
                                                      .width *
                                                  0.9,
                                              decoration: BoxDecoration(
                                                color: Colors.white,
                                                borderRadius:
                                                    BorderRadius.circular(15),
                                                boxShadow: [
                                                  BoxShadow(
                                                    color: Colors.grey
                                                        .withOpacity(0.2),
                                                    offset: const Offset(0, 2),
                                                    blurRadius: 5,
                                                    spreadRadius: 2,
                                                  ),
                                                ],
                                              ),
                                              child: Column(children: [
                                                ListTile(
                                                    leading: Image.asset(
                                                      "assets/images/zone.png",
                                                      width: 80,
                                                      height: 80,
                                                    ),
                                                    title: Text(
                                                        e.localite!
                                                            .toUpperCase(),
                                                        style: const TextStyle(
                                                          color: Colors.black,
                                                          fontSize: 20,
                                                          overflow: TextOverflow
                                                              .ellipsis,
                                                        )),
                                                    subtitle: Text(
                                                        e.superficieHa!,
                                                        style: const TextStyle(
                                                          color: Colors.black87,
                                                          fontSize: 17,
                                                          fontWeight:
                                                              FontWeight.w500,
                                                          fontStyle:
                                                              FontStyle.italic,
                                                        ))),
                                                SizedBox(height: 10),
                                                Container(
                                                  alignment:
                                                      Alignment.bottomRight,
                                                  padding: const EdgeInsets
                                                      .symmetric(
                                                      horizontal: 10),
                                                  child: Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceBetween,
                                                    children: [
                                                      _buildEtat(
                                                          e.statutSuperficie),
                                                      PopupMenuButton<String>(
                                                        padding:
                                                            EdgeInsets.zero,
                                                        itemBuilder:
                                                            (context) =>
                                                                <PopupMenuEntry<
                                                                    String>>[
                                                          PopupMenuItem<String>(
                                                            child: ListTile(
                                                              leading:
                                                                  e.statutSuperficie ==
                                                                          false
                                                                      ? Icon(
                                                                          Icons
                                                                              .check,
                                                                          color:
                                                                              Colors.green,
                                                                        )
                                                                      : Icon(
                                                                          Icons
                                                                              .disabled_visible,
                                                                          color:
                                                                              Colors.orange[400],
                                                                        ),
                                                              title: Text(
                                                                e.statutSuperficie ==
                                                                        false
                                                                    ? "Activer"
                                                                    : "Desactiver",
                                                                style:
                                                                    TextStyle(
                                                                  color: e.statutSuperficie ==
                                                                          false
                                                                      ? Colors
                                                                          .green
                                                                      : Colors.orange[
                                                                          400],
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold,
                                                                ),
                                                              ),
                                                              onTap: () async {
                                                                e.statutSuperficie ==
                                                                        false
                                                                    ? await SuperficieService()
                                                                        .activerSuperficie(e
                                                                            .idSuperficie!)
                                                                        .then((value) =>
                                                                            {
                                                                              Provider.of<SuperficieService>(context, listen: false).applyChange(),
                                                                              Navigator.of(context).pop(),
                                                                              setState(() {
                                                                                _liste = getCampListe(acteur.idActeur!);
                                                                              }),
                                                                              ScaffoldMessenger.of(context).showSnackBar(
                                                                                const SnackBar(
                                                                                  content: Row(
                                                                                    children: [
                                                                                      Text("Activer avec succèss "),
                                                                                    ],
                                                                                  ),
                                                                                  duration: Duration(seconds: 2),
                                                                                ),
                                                                              )
                                                                            })
                                                                        .catchError(
                                                                            (onError) =>
                                                                                {
                                                                                  ScaffoldMessenger.of(context).showSnackBar(
                                                                                    const SnackBar(
                                                                                      content: Row(
                                                                                        children: [
                                                                                          Text("Une erreur s'est produit"),
                                                                                        ],
                                                                                      ),
                                                                                      duration: Duration(seconds: 5),
                                                                                    ),
                                                                                  ),
                                                                                  Navigator.of(context).pop(),
                                                                                })
                                                                    : await SuperficieService()
                                                                        .desactiverSuperficie(e
                                                                            .idSuperficie!)
                                                                        .then((value) =>
                                                                            {
                                                                              Provider.of<SuperficieService>(context, listen: false).applyChange(),
                                                                              Navigator.of(context).pop(),
                                                                              setState(() {
                                                                                _liste = getCampListe(acteur.idActeur!);
                                                                                ScaffoldMessenger.of(context).showSnackBar(
                                                                                  const SnackBar(
                                                                                    content: Row(
                                                                                      children: [
                                                                                        Text("Desactiver avec succèss "),
                                                                                      ],
                                                                                    ),
                                                                                    duration: Duration(seconds: 2),
                                                                                  ),
                                                                                );
                                                                              })
                                                                            })
                                                                        .catchError((onError) =>
                                                                            {
                                                                              ScaffoldMessenger.of(context).showSnackBar(
                                                                                const SnackBar(
                                                                                  content: Row(
                                                                                    children: [
                                                                                      Text("Une erreur s'est produit"),
                                                                                    ],
                                                                                  ),
                                                                                  duration: Duration(seconds: 5),
                                                                                ),
                                                                              ),
                                                                              Navigator.of(context).pop(),
                                                                            });

                                                                ScaffoldMessenger.of(
                                                                        context)
                                                                    .showSnackBar(
                                                                  const SnackBar(
                                                                    content:
                                                                        Row(
                                                                      children: [
                                                                        Text(
                                                                            "Désactiver avec succèss "),
                                                                      ],
                                                                    ),
                                                                    duration: Duration(
                                                                        seconds:
                                                                            2),
                                                                  ),
                                                                );
                                                              },
                                                            ),
                                                          ),
                                                          PopupMenuItem<String>(
                                                            child: ListTile(
                                                              leading:
                                                                  const Icon(
                                                                Icons.edit,
                                                                color: Colors
                                                                    .green,
                                                              ),
                                                              title: const Text(
                                                                "Modifier",
                                                                style:
                                                                    TextStyle(
                                                                  color: Colors
                                                                      .green,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold,
                                                                ),
                                                              ),
                                                              onTap: () async {
                                                                _getResultFromNextScreen1(
                                                                    context, e);
                                                              },
                                                            ),
                                                          ),
                                                          PopupMenuItem<String>(
                                                            child: ListTile(
                                                              leading:
                                                                  const Icon(
                                                                Icons.delete,
                                                                color:
                                                                    Colors.red,
                                                              ),
                                                              title: const Text(
                                                                "Supprimer",
                                                                style:
                                                                    TextStyle(
                                                                  color: Colors
                                                                      .red,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold,
                                                                ),
                                                              ),
                                                              onTap: () async {
                                                                await SuperficieService()
                                                                    .deleteSuperficie(e
                                                                        .idSuperficie!)
                                                                    .then(
                                                                        (value) =>
                                                                            {
                                                                              Provider.of<SuperficieService>(context, listen: false).applyChange(),
                                                                              Navigator.of(context).pop(),
                                                                            })
                                                                    .catchError(
                                                                        (onError) =>
                                                                            {
                                                                              ScaffoldMessenger.of(context).showSnackBar(
                                                                                const SnackBar(
                                                                                  content: Row(
                                                                                    children: [
                                                                                      Text("Impossible de supprimer"),
                                                                                    ],
                                                                                  ),
                                                                                  duration: Duration(seconds: 2),
                                                                                ),
                                                                              )
                                                                            });
                                                              },
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ],
                                                  ),
                                                )
                                              ]),
                                            ),
                                          ),
                                        ))
                                    .toList(),
                              );
                      }
                    })
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEtat(bool isState) {
    return Container(
      width: 15,
      height: 15,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        color: isState ? Colors.green : Colors.red,
      ),
    );
  }
}
