import 'dart:convert';
import 'dart:developer';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:http/http.dart' as http;
import 'package:koumi/constants.dart';
import 'package:koumi/models/Acteur.dart';
import 'package:koumi/models/TypeActeur.dart';
import 'package:koumi/models/TypeVoiture.dart';
import 'package:koumi/models/Vehicule.dart';
import 'package:koumi/providers/ActeurProvider.dart';
import 'package:koumi/providers/CountryProvider.dart';
import 'package:koumi/screens/AddVehicule.dart';
import 'package:koumi/screens/DetailTransport.dart';
import 'package:koumi/screens/PageTransporteur.dart';
import 'package:koumi/screens/VehiculesActeur.dart';
import 'package:koumi/service/VehiculeService.dart';
import 'package:koumi/widgets/AutoComptet.dart';
import 'package:koumi/widgets/DetectorPays.dart';
import 'package:provider/provider.dart';
import 'package:search_field_autocomplete/search_field_autocomplete.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shimmer/shimmer.dart';

class Transport extends StatefulWidget {
  Transport({super.key});

  @override
  State<Transport> createState() => _TransportState();
}

const d_colorGreen = Color.fromRGBO(43, 103, 6, 1);
const d_colorOr = Color.fromRGBO(255, 138, 0, 1);

class _TransportState extends State<Transport> {
  late Acteur acteur;
  late List<TypeActeur> typeActeurData = [];
  late String type;
  late TextEditingController _searchController;
  FocusNode _focusNode = FocusNode();
  List<Vehicule> vehiculeListe = [];
  TypeVoiture? selectedType;
  String? typeValue;
  late Future _typeList;
  bool isExist = false;
  String? email = "";
  int page = 0;
  bool isLoading = false;
  bool isSearchMode = false;
  bool isFilterMode = false;
  int size = sized;
  bool hasMore = true;
  ScrollController scrollableController = ScrollController();
  ScrollController scrollableController1 = ScrollController();
  late Future<List<Vehicule>> vehiculeListeFuture;
  late Future<List<Vehicule>> vehiculeListeFuture1;
  CountryProvider? countryProvider;
  String? detectedCountry;

  void _scrollListener() {
    if (scrollableController.position.pixels >=
            scrollableController.position.maxScrollExtent - 200 &&
        hasMore &&
        !isLoading &&
        selectedType == null) {
      if (mounted)
        setState(() {
          page++;
        });
      debugPrint("yes - fetch all by pays vehicule $page");
      fetchVehicule(detectedCountry != null ? detectedCountry! : "Mali");
    }
    debugPrint("no");
  }

  void _scrollListener1() {
    if (scrollableController1.position.pixels >=
            scrollableController1.position.maxScrollExtent - 200 &&
        hasMore &&
        !isLoading &&
        selectedType != null) {
      // if (selectedCat != null) {
      // Incrementez la page et récupérez les stocks par catégorie
      debugPrint("yes - fetch by type and pays");
      if (mounted)
        setState(() {
          // Rafraîchir les données ici
          page++;
        });

      fetchVehiculeByTypeVoitureWithPagination(selectedType!.idTypeVoiture!,
          detectedCountry != null ? detectedCountry! : "Mali");
    }
    debugPrint("no");
  }

  Future<List<Vehicule>> fetchVehiculeByTypeVoitureWithPagination(
      String idTypeVoiture, String niveau3PaysActeur,
      {bool refresh = false}) async {
    if (isLoading) return [];
    setState(() {
      isLoading = true;
    });

    if (refresh) {
      setState(() {
        vehiculeListe.clear();
        page = 0;
        hasMore = true;
      });
    }

    try {
      final response = await http.get(Uri.parse(
          '$apiOnlineUrl/vehicule/getVehiculesByPaysAndTypeVoitureWithPagination?idTypeVoiture=$idTypeVoiture&niveau3PaysActeur=$niveau3PaysActeur&page=$page&size=$size'));

      if (response.statusCode == 200) {
        // debugPrint("url: $response");
        final jsonData = jsonDecode(utf8.decode(response.bodyBytes));
        final List<dynamic> body = jsonData['content'];

        if (body.isEmpty) {
          setState(() {
            hasMore = false;
          });
        } else {
          List<Vehicule> newVehicule =
              body.map((e) => Vehicule.fromMap(e)).toList();

          setState(() {
            vehiculeListe.addAll(newVehicule.where((newVe) => !vehiculeListe
                .any((existeVe) => existeVe.idVehicule == newVe.idVehicule)));
          });
        }

        debugPrint(
            "response body vehicle by type vehicule with pagination $page par défilement soit ${vehiculeListe.length}");
        return vehiculeListe;
      } else {
        print(
            'Échec de la requête avec le code d\'état: ${response.statusCode} |  ${response.body}');
        return [];
      }
    } catch (e) {
      print(
          'Une erreur s\'est produite lors de la récupération des vehicules: $e');
    } finally {
      setState(() {
        isLoading = false;
      });
    }
    return vehiculeListe;
  }

  Future<List<Vehicule>> fetchVehicule(String niveau3PaysActeur,
      {bool refresh = false}) async {
    if (isLoading) return [];

    setState(() {
      isLoading = true;
    });

    if (refresh) {
      setState(() {
        vehiculeListe.clear();
        page = 0;
        hasMore = true;
      });
    }

    try {
      final response = await http.get(Uri.parse(
          '$apiOnlineUrl/vehicule/getVehiculesByPaysWithPagination?niveau3PaysActeur=$niveau3PaysActeur&page=$page&size=$size'));

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(utf8.decode(response.bodyBytes));
        final List<dynamic> body = jsonData['content'];

        if (body.isEmpty) {
          setState(() {
            hasMore = false;
          });
        } else {
          List<Vehicule> newVehicule =
              body.map((e) => Vehicule.fromMap(e)).toList();

          setState(() {
            vehiculeListe.addAll(newVehicule.where((newVe) => !vehiculeListe
                .any((existeVe) => existeVe.idVehicule == newVe.idVehicule)));
          });
        }

        debugPrint(
            "response body all vehicle with pagination $page dans la page par défilement soit ${vehiculeListe.length}");
        return vehiculeListe;
      } else {
        print(
            'Échec de la requête avec le code d\'état: ${response.statusCode} |  ${response.body}');
        return [];
      }
    } catch (e) {
      print(
          'Une erreur s\'est produite lors de la récupération des vehicules: $e');
    } finally {
      setState(() {
        isLoading = false;
      });
    }
    return vehiculeListe;
  }

  Future<List<Vehicule>> getAllVehicule() async {
    if (selectedType != null) {
      vehiculeListe = await VehiculeService()
          .fetchVehiculeByTypeVoitureWithPagination(
              selectedType!.idTypeVoiture!,
              detectedCountry != null ? detectedCountry! : "Mali");
    }

    return vehiculeListe;
  }

  void verify() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    email = prefs.getString('whatsAppActeur');
    if (email != null) {
      // Si l'email de l'acteur est présent, exécute checkLoggedIn
      acteur = Provider.of<ActeurProvider>(context, listen: false).acteur!;
      typeActeurData = acteur.typeActeur!;
      type = typeActeurData.map((data) => data.libelle).join(', ');
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
    verify();
    final paysProvider = Provider.of<DetectorPays>(context, listen: false);
    paysProvider.hasLocation
        ? detectedCountry =
            Provider.of<DetectorPays>(context, listen: false).detectedCountry!
        : detectedCountry = "Mali";
    detectedCountry != null
        ? debugPrint("pays fetch transport page ${detectedCountry!} ")
        : debugPrint("null pays non fetch transport page");
    _searchController = TextEditingController();
    _typeList = http.get(Uri.parse('$apiOnlineUrl/TypeVoiture/read'));
    WidgetsBinding.instance.addPostFrameCallback((_) {
      scrollableController.addListener(_scrollListener);
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      scrollableController1.addListener(_scrollListener1);
    });
    isExist == false
        ? vehiculeListeFuture = VehiculeService()
            .fetchVehicule(detectedCountry != null ? detectedCountry! : "Mali")
        : vehiculeListeFuture = VehiculeService()
            .fetchVehicule(detectedCountry != null ? detectedCountry! : "Mali");
    vehiculeListeFuture1 = getAllVehicule();

    super.initState();
  }

  Future<void> _getResultFromNextScreen1(BuildContext context) async {
    final result = await Navigator.push(
        context, MaterialPageRoute(builder: (context) => AddVehicule()));
    log(result.toString());
    if (result == true) {
      print("Rafraichissement en cours");
      selectedType == null
          ? setState(() {
              vehiculeListeFuture = VehiculeService().fetchVehicule(
                  detectedCountry != null ? detectedCountry! : "Mali");
            })
          : setState(() {
              vehiculeListeFuture1 = VehiculeService()
                  .fetchVehiculeByTypeVoitureWithPagination(
                      selectedType!.idTypeVoiture!,
                      detectedCountry != null ? detectedCountry! : "Mali");
            });
    }
  }

  Future<void> _getResultFromNextScreen2(BuildContext context) async {
    final result = await Navigator.push(
        context, MaterialPageRoute(builder: (context) => VehiculeActeur()));
    log(result.toString());
    if (result == true) {
      print("Rafraichissement en cours");
      selectedType == null
          ? setState(() {
              vehiculeListeFuture = VehiculeService().fetchVehicule(
                  detectedCountry != null ? detectedCountry! : "Mali");
            })
          : setState(() {
              vehiculeListeFuture1 = VehiculeService()
                  .fetchVehiculeByTypeVoitureWithPagination(
                      selectedType!.idTypeVoiture!,
                      detectedCountry != null ? detectedCountry! : "Mali");
            });
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    scrollableController.dispose();
    scrollableController1.dispose();
    super.dispose();
  }

  void _updateMode(int index) {
    if (mounted) {
      setState(() {
        isSearchMode = index == 0;
        if (!isSearchMode) {
          _searchController.clear();
          _searchController.dispose();
          _searchController = TextEditingController();
        }
      });
    }
  }

  void _selectMode(String mode) {
    setState(() {
      if (mode == 'Rechercher') {
        isSearchMode = true;
        isFilterMode = false;
      } else if (mode == 'Filtrer') {
        isSearchMode = false;
        isFilterMode = true;
      } else if (mode == 'Fermer') {
        isSearchMode = false;
        isFilterMode = false;
      }
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: const Color.fromARGB(255, 250, 250, 250),
        appBar: AppBar(
            centerTitle: true,
            toolbarHeight: 100,
            leading: IconButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                icon: const Icon(Icons.arrow_back_ios, color: d_colorGreen)),
            title: Text(
              'Transport',
              style: const TextStyle(
                  color: d_colorGreen,
                  fontWeight: FontWeight.bold,
                  fontSize: 20),
            ),
            actions: !isExist
                ? [
                    IconButton(
                        onPressed: () {
                          selectedType == null
                              ? setState(() {
                                  vehiculeListeFuture = VehiculeService()
                                      .fetchVehicule(detectedCountry != null
                                          ? detectedCountry!
                                          : "Mali");
                                })
                              : setState(() {
                                  vehiculeListeFuture1 = VehiculeService()
                                      .fetchVehiculeByTypeVoitureWithPagination(
                                          selectedType!.idTypeVoiture!,
                                          detectedCountry != null
                                              ? detectedCountry!
                                              : "Mali");
                                });
                        },
                        icon: const Icon(Icons.refresh, color: d_colorGreen)),
                  ]
                : [
                    IconButton(
                        onPressed: () {
                          selectedType == null
                              ? setState(() {
                                  vehiculeListeFuture = VehiculeService()
                                      .fetchVehicule(detectedCountry != null
                                          ? detectedCountry!
                                          : "Mali");
                                })
                              : setState(() {
                                  vehiculeListeFuture1 = VehiculeService()
                                      .fetchVehiculeByTypeVoitureWithPagination(
                                          selectedType!.idTypeVoiture!,
                                          detectedCountry != null
                                              ? detectedCountry!
                                              : "Mali");
                                });
                        },
                        icon: const Icon(Icons.refresh, color: d_colorGreen)),
                    (typeActeurData
                                .map((e) => e.libelle!.toLowerCase())
                                .contains("transporteur") ||
                            typeActeurData
                                .map((e) => e.libelle!.toLowerCase())
                                .contains("admin"))
                        // (type.toLowerCase() == 'admin' ||
                        //         type.toLowerCase() == 'transporteur')
                        ? PopupMenuButton<String>(
                            padding: EdgeInsets.zero,
                            itemBuilder: (context) {
                              return <PopupMenuEntry<String>>[
                                PopupMenuItem<String>(
                                  child: ListTile(
                                    leading: const Icon(
                                      Icons.add,
                                      color: Colors.green,
                                    ),
                                    title: const Text(
                                      "Ajouter un vehicule",
                                      style: TextStyle(
                                        color: Colors.green,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    onTap: () async {
                                      Navigator.of(context).pop();
                                      _getResultFromNextScreen1(context);
                                    },
                                  ),
                                ),
                                PopupMenuItem<String>(
                                  child: ListTile(
                                    leading: const Icon(
                                      Icons.remove_red_eye,
                                      color: Colors.green,
                                    ),
                                    title: const Text(
                                      "Mes véhicules",
                                      style: TextStyle(
                                        color: Colors.green,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    onTap: () async {
                                      Navigator.of(context).pop();
                                      _getResultFromNextScreen2(context);
                                    },
                                  ),
                                ),
                                PopupMenuItem<String>(
                                  child: ListTile(
                                    leading: const Icon(
                                      Icons.remove_red_eye,
                                      color: Colors.green,
                                    ),
                                    title: const Text(
                                      "Transporteurs",
                                      style: TextStyle(
                                        color: Colors.green,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    onTap: () async {
                                      Navigator.of(context).pop();
                                      Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  PageTransporteur()));
                                    },
                                  ),
                                ),
                              ];
                            },
                          )
                        : PopupMenuButton<String>(
                            padding: EdgeInsets.zero,
                            itemBuilder: (context) {
                              return <PopupMenuEntry<String>>[
                                PopupMenuItem<String>(
                                  child: ListTile(
                                    leading: const Icon(
                                      Icons.remove_red_eye,
                                      color: Colors.green,
                                    ),
                                    title: const Text(
                                      "Transporteurs",
                                      style: TextStyle(
                                        color: Colors.green,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    onTap: () async {
                                      Navigator.of(context).pop();
                                      Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  PageTransporteur()));
                                    },
                                  ),
                                ),
                              ];
                            },
                          )
                  ]),
        body: GestureDetector(
          onTap: () {
            FocusScope.of(context).unfocus();
          },
          child: RefreshIndicator(
              onRefresh: () async {
                setState(() {
                  page = 0;
                });
                selectedType == null
                    ? setState(() {
                        vehiculeListeFuture = VehiculeService().fetchVehicule(
                            detectedCountry != null
                                ? detectedCountry!
                                : "Mali");
                      })
                    : setState(() {
                        vehiculeListeFuture1 = VehiculeService()
                            .fetchVehiculeByTypeVoitureWithPagination(
                                selectedType!.idTypeVoiture!,
                                detectedCountry != null
                                    ? detectedCountry!
                                    : "Mali");
                      });
              },
              child: Container(
                  child: NestedScrollView(
                headerSliverBuilder:
                    (BuildContext context, bool innerBoxIsScrolled) {
                  return <Widget>[
                    SliverToBoxAdapter(
                        child: Column(children: [
                      const SizedBox(height: 10),
                      if (!isSearchMode)
                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton.icon(
                            onPressed: () {
                              setState(() {
                                isSearchMode = true;
                                isFilterMode = true;
                              });
                            },
                            icon: Icon(
                              Icons.search,
                              color: d_colorGreen,
                            ),
                            label: Text(
                              'Rechercher...',
                              style:
                                  TextStyle(color: d_colorGreen, fontSize: 17),
                            ),
                          ),
                        ),
                      if (isSearchMode)
                        Align(
                            alignment: Alignment.centerRight,
                            child: TextButton.icon(
                              onPressed: () {
                                if (mounted) {
                                  setState(() {
                                    isSearchMode = false;
                                    isFilterMode = false;
                                    _searchController.clear();
                                    _searchController = TextEditingController();
                                  });
                                  debugPrint(
                                      "Rechercher mode désactivé : $isSearchMode");
                                }
                              },
                              icon: Icon(
                                Icons.close,
                                color: Colors.red,
                              ),
                              label: Text(
                                'Fermer',
                                style:
                                    TextStyle(color: Colors.red, fontSize: 17),
                              ),
                            )),
                      Visibility(
                          visible: isSearchMode,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                                vertical: 3, horizontal: 10),
                            child: FutureBuilder(
                              future: _typeList,
                              builder: (_, snapshot) {
                                if (snapshot.connectionState ==
                                    ConnectionState.waiting) {
                                  return buildLoadingDropdown();
                                }

                                if (snapshot.hasData) {
                                  dynamic jsonString =
                                      utf8.decode(snapshot.data.bodyBytes);
                                  dynamic responseData =
                                      json.decode(jsonString);

                                  if (responseData is List) {
                                    final reponse = responseData;
                                    final typeList = reponse
                                        .map((e) => TypeVoiture.fromMap(e))
                                        .where((con) => con.statutType == true)
                                        .toList();

                                    if (typeList.isEmpty) {
                                      return buildEmptyDropdown();
                                    }

                                    return buildDropdown(typeList);
                                  } else {
                                    return buildEmptyDropdown();
                                  }
                                }

                                return buildEmptyDropdown();
                              },
                            ),
                          )),
                      Visibility(
                        visible: isSearchMode,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              vertical: 3, horizontal: 10),
                          child: SearchFieldAutoComplete<String>(
                            controller: _searchController,
                            placeholder: 'Rechercher...',
                            placeholderStyle:
                                TextStyle(fontStyle: FontStyle.italic),
                            suggestions: AutoComplet.getTransportVehicles,
                            suggestionsDecoration: SuggestionDecoration(
                              marginSuggestions: const EdgeInsets.all(8.0),
                              color: const Color.fromARGB(255, 236, 234, 234),
                              borderRadius: BorderRadius.circular(16.0),
                            ),
                            onSuggestionSelected: (selectedItem) {
                              if (mounted) {
                                _searchController.text = selectedItem.searchKey;
                              }
                            },
                            suggestionItemBuilder: (context, searchFieldItem) {
                              return Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(
                                  searchFieldItem.searchKey,
                                  style: TextStyle(color: Colors.black),
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                    ])),
                  ];
                },
                body: RefreshIndicator(
                  onRefresh: () async {
                    setState(() {
                      page = 0;
                    });
                    selectedType == null
                        ? setState(() {
                            vehiculeListeFuture = VehiculeService()
                                .fetchVehicule(detectedCountry != null
                                    ? detectedCountry!
                                    : "Mali");
                          })
                        : setState(() {
                            vehiculeListeFuture1 = VehiculeService()
                                .fetchVehiculeByTypeVoitureWithPagination(
                                    selectedType!.idTypeVoiture!,
                                    detectedCountry != null
                                        ? detectedCountry!
                                        : "Mali");
                          });
                  },
                  child: selectedType == null
                      ? SingleChildScrollView(
                          controller: scrollableController,
                          child: Consumer<VehiculeService>(
                              builder: (context, vehiculeService, child) {
                            return FutureBuilder<List<Vehicule>>(
                                future: vehiculeListeFuture,
                                builder: (context, snapshot) {
                                  if (snapshot.connectionState ==
                                      ConnectionState.waiting) {
                                    return _buildShimmerEffect();
                                  }

                                  if (!snapshot.hasData) {
                                    return const Padding(
                                      padding: EdgeInsets.all(10),
                                      child: Center(
                                          child: Text("Aucun donné trouvé")),
                                    );
                                  } else {
                                    vehiculeListe = snapshot.data!;
                                    String searchText = "";

                                    List<Vehicule> produitsLocaux =
                                        vehiculeListe
                                            .where((stock) =>
                                                stock.acteur!
                                                    .niveau3PaysActeur! ==
                                                detectedCountry)
                                            .where((search) {
                                      String libelle =
                                          search.nomVehicule.toLowerCase();
                                      searchText =
                                          _searchController.text.toLowerCase();
                                      return libelle.contains(searchText);
                                    }).toList();

                                    List<Vehicule> produitsEtrangers =
                                        vehiculeListe
                                            .where((stock) =>
                                                stock.acteur!
                                                    .niveau3PaysActeur! !=
                                                detectedCountry)
                                            .where((search) {
                                      String libelle =
                                          search.nomVehicule.toLowerCase();
                                      searchText =
                                          _searchController.text.toLowerCase();
                                      return libelle.contains(searchText);
                                    }).toList();

                                    List<Vehicule> filtereSearch =
                                        vehiculeListe.where((search) {
                                      String libelle =
                                          search.nomVehicule.toLowerCase();
                                      searchText =
                                          _searchController.text.toLowerCase();
                                      return libelle.contains(searchText);
                                    }).toList();
                                    return filtereSearch.isEmpty
                                        ? SingleChildScrollView(
                                            child: Padding(
                                              padding: EdgeInsets.all(10),
                                              child: Center(
                                                child: Column(
                                                  children: [
                                                    Image.asset(
                                                        'assets/images/notif.jpg'),
                                                    SizedBox(
                                                      height: 10,
                                                    ),
                                                    Text(
                                                      'Aucune vehiucle de transport trouvé',
                                                      style: TextStyle(
                                                        color: Colors.black,
                                                        fontSize: 17,
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          )
                                        : Column(
                                            children: [
                                              if (produitsLocaux
                                                  .isNotEmpty) ...[
                                                Padding(
                                                  padding:
                                                      const EdgeInsets.all(8.0),
                                                  child: Text(
                                                    "Transport locaux",
                                                    style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        fontSize: 18),
                                                  ),
                                                ),
                                                GridView.builder(
                                                  shrinkWrap: true,
                                                  physics:
                                                      NeverScrollableScrollPhysics(),
                                                  gridDelegate:
                                                      SliverGridDelegateWithFixedCrossAxisCount(
                                                    crossAxisCount: 2,
                                                    mainAxisSpacing: 10,
                                                    crossAxisSpacing: 10,
                                                    childAspectRatio: 0.8,
                                                  ),
                                                  itemCount:
                                                      produitsLocaux.length,
                                                  itemBuilder:
                                                      (context, index) {
                                                    if (index <
                                                        produitsLocaux.length) {
                                                      return GestureDetector(
                                                        onTap: () {
                                                          Navigator.push(
                                                              context,
                                                              MaterialPageRoute(
                                                                  builder: (context) =>
                                                                      DetailTransport(
                                                                          vehicule:
                                                                              produitsLocaux[index])));
                                                        },
                                                        child: Card(
                                                          margin:
                                                              EdgeInsets.all(8),
                                                          child: Column(
                                                            crossAxisAlignment:
                                                                CrossAxisAlignment
                                                                    .stretch,
                                                            children: [
                                                              ClipRRect(
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            8.0),
                                                                child: SizedBox(
                                                                  height: 85,
                                                                  child: produitsLocaux[index].photoVehicule ==
                                                                              null ||
                                                                          produitsLocaux[index]
                                                                              .photoVehicule!
                                                                              .isEmpty
                                                                      ? Image
                                                                          .asset(
                                                                          "assets/images/default_image.png",
                                                                          fit: BoxFit
                                                                              .cover,
                                                                        )
                                                                      : CachedNetworkImage(
                                                                          imageUrl:
                                                                              "https://koumi.ml/api-koumi/vehicule/${produitsLocaux[index].idVehicule}/image",
                                                                          fit: BoxFit
                                                                              .cover,
                                                                          placeholder: (context, url) =>
                                                                              const Center(child: CircularProgressIndicator()),
                                                                          errorWidget: (context, url, error) =>
                                                                              Image.asset(
                                                                            'assets/images/default_image.png',
                                                                            fit:
                                                                                BoxFit.cover,
                                                                          ),
                                                                        ),
                                                                ),
                                                              ),
                                                              // SizedBox(height: 8),
                                                              ListTile(
                                                                title: Text(
                                                                  produitsLocaux[
                                                                          index]
                                                                      .nomVehicule,
                                                                  style:
                                                                      TextStyle(
                                                                    fontSize:
                                                                        16,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .bold,
                                                                    color: Colors
                                                                        .black87,
                                                                  ),
                                                                  maxLines: 2,
                                                                  overflow:
                                                                      TextOverflow
                                                                          .ellipsis,
                                                                ),
                                                                subtitle: Text(
                                                                  "${produitsLocaux[index].nbKilometrage.toString()} Km",
                                                                  style:
                                                                      TextStyle(
                                                                    fontSize:
                                                                        15,
                                                                    color: Colors
                                                                        .black87,
                                                                  ),
                                                                ),
                                                              ),
                                                              Padding(
                                                                padding: const EdgeInsets
                                                                    .symmetric(
                                                                    horizontal:
                                                                        15),
                                                                child: Text(
                                                                  produitsLocaux[
                                                                          index]
                                                                      .localisation,
                                                                  style:
                                                                      TextStyle(
                                                                    fontSize:
                                                                        15,
                                                                    color: Colors
                                                                        .black87,
                                                                  ),
                                                                ),
                                                              )
                                                            ],
                                                          ),
                                                        ),
                                                      );
                                                    } else {
                                                      return isLoading == true
                                                          ? Padding(
                                                              padding:
                                                                  const EdgeInsets
                                                                      .symmetric(
                                                                      horizontal:
                                                                          32),
                                                              child: Center(
                                                                  child:
                                                                      const Center(
                                                                child:
                                                                    CircularProgressIndicator(
                                                                  color: Colors
                                                                      .orange,
                                                                ),
                                                              )),
                                                            )
                                                          : Container();
                                                    }
                                                  },
                                                ),
                                              ],
                                              if (produitsEtrangers
                                                  .isNotEmpty) ...[
                                                Padding(
                                                  padding:
                                                      const EdgeInsets.all(8.0),
                                                  child: Text(
                                                    "Transport etrangère",
                                                    style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        fontSize: 18),
                                                  ),
                                                ),
                                                GridView.builder(
                                                  shrinkWrap: true,
                                                  physics:
                                                      NeverScrollableScrollPhysics(),
                                                  gridDelegate:
                                                      SliverGridDelegateWithFixedCrossAxisCount(
                                                    crossAxisCount: 2,
                                                    mainAxisSpacing: 10,
                                                    crossAxisSpacing: 10,
                                                    childAspectRatio: 0.8,
                                                  ),
                                                  itemCount:
                                                      produitsEtrangers.length,
                                                  itemBuilder:
                                                      (context, index) {
                                                    if (index <
                                                        produitsEtrangers
                                                            .length) {
                                                      return GestureDetector(
                                                        onTap: () {
                                                          Navigator.push(
                                                              context,
                                                              MaterialPageRoute(
                                                                  builder: (context) =>
                                                                      DetailTransport(
                                                                          vehicule:
                                                                              produitsEtrangers[index])));
                                                        },
                                                        child: Card(
                                                          margin:
                                                              EdgeInsets.all(8),
                                                          child: Column(
                                                            crossAxisAlignment:
                                                                CrossAxisAlignment
                                                                    .stretch,
                                                            children: [
                                                              ClipRRect(
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            8.0),
                                                                child: SizedBox(
                                                                  height: 85,
                                                                  child: produitsEtrangers[index].photoVehicule ==
                                                                              null ||
                                                                          produitsEtrangers[index]
                                                                              .photoVehicule!
                                                                              .isEmpty
                                                                      ? Image
                                                                          .asset(
                                                                          "assets/images/default_image.png",
                                                                          fit: BoxFit
                                                                              .cover,
                                                                        )
                                                                      : CachedNetworkImage(
                                                                          imageUrl:
                                                                              "https://koumi.ml/api-koumi/vehicule/${produitsEtrangers[index].idVehicule}/image",
                                                                          fit: BoxFit
                                                                              .cover,
                                                                          placeholder: (context, url) =>
                                                                              const Center(child: CircularProgressIndicator()),
                                                                          errorWidget: (context, url, error) =>
                                                                              Image.asset(
                                                                            'assets/images/default_image.png',
                                                                            fit:
                                                                                BoxFit.cover,
                                                                          ),
                                                                        ),
                                                                ),
                                                              ),
                                                              // SizedBox(height: 8),
                                                              ListTile(
                                                                title: Text(
                                                                  produitsEtrangers[
                                                                          index]
                                                                      .nomVehicule,
                                                                  style:
                                                                      TextStyle(
                                                                    fontSize:
                                                                        16,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .bold,
                                                                    color: Colors
                                                                        .black87,
                                                                  ),
                                                                  maxLines: 2,
                                                                  overflow:
                                                                      TextOverflow
                                                                          .ellipsis,
                                                                ),
                                                                subtitle: Text(
                                                                  "${produitsEtrangers[index].nbKilometrage.toString()} Km",
                                                                  style:
                                                                      TextStyle(
                                                                    fontSize:
                                                                        15,
                                                                    color: Colors
                                                                        .black87,
                                                                  ),
                                                                ),
                                                              ),
                                                              Padding(
                                                                padding: const EdgeInsets
                                                                    .symmetric(
                                                                    horizontal:
                                                                        15),
                                                                child: Text(
                                                                  produitsEtrangers[
                                                                          index]
                                                                      .localisation,
                                                                  style:
                                                                      TextStyle(
                                                                    fontSize:
                                                                        15,
                                                                    color: Colors
                                                                        .black87,
                                                                  ),
                                                                ),
                                                              )
                                                            ],
                                                          ),
                                                        ),
                                                      );
                                                    } else {
                                                      return isLoading == true
                                                          ? Padding(
                                                              padding:
                                                                  const EdgeInsets
                                                                      .symmetric(
                                                                      horizontal:
                                                                          32),
                                                              child: Center(
                                                                  child:
                                                                      const Center(
                                                                child:
                                                                    CircularProgressIndicator(
                                                                  color: Colors
                                                                      .orange,
                                                                ),
                                                              )),
                                                            )
                                                          : Container();
                                                    }
                                                  },
                                                ),
                                              ],
                                            ],
                                          );
                                  }
                                });
                          }),
                        )
                      : SingleChildScrollView(
                          controller: scrollableController1,
                          child: Consumer<VehiculeService>(
                              builder: (context, vehiculeService, child) {
                            return FutureBuilder<List<Vehicule>>(
                                future: vehiculeListeFuture1,
                                builder: (context, snapshot) {
                                  if (snapshot.connectionState ==
                                      ConnectionState.waiting) {
                                    return _buildShimmerEffect();
                                  }

                                  if (!snapshot.hasData) {
                                    return const Padding(
                                      padding: EdgeInsets.all(10),
                                      child: Center(
                                          child: Text("Aucun donné trouvé")),
                                    );
                                  } else {
                                    vehiculeListe = snapshot.data!;
                                    String searchText = "";

                                    List<Vehicule> produitsLocaux =
                                        vehiculeListe
                                            .where((stock) =>
                                                stock.acteur!
                                                    .niveau3PaysActeur! ==
                                                detectedCountry)
                                            .where((search) {
                                      String libelle =
                                          search.nomVehicule.toLowerCase();
                                      searchText =
                                          _searchController.text.toLowerCase();
                                      return libelle.contains(searchText);
                                    }).toList();

                                    List<Vehicule> produitsEtrangers =
                                        vehiculeListe
                                            .where((stock) =>
                                                stock.acteur!
                                                    .niveau3PaysActeur! !=
                                                detectedCountry)
                                            .where((search) {
                                      String libelle =
                                          search.nomVehicule.toLowerCase();
                                      searchText =
                                          _searchController.text.toLowerCase();
                                      return libelle.contains(searchText);
                                    }).toList();

                                    List<Vehicule> filtereSearch =
                                        vehiculeListe.where((search) {
                                      String libelle =
                                          search.nomVehicule.toLowerCase();
                                      searchText =
                                          _searchController.text.toLowerCase();
                                      return libelle.contains(searchText);
                                    }).toList();
                                    return filtereSearch.isEmpty &&
                                            isLoading == false
                                        ? SingleChildScrollView(
                                            child: Padding(
                                              padding: EdgeInsets.all(10),
                                              child: Center(
                                                child: Column(
                                                  children: [
                                                    Image.asset(
                                                        'assets/images/notif.jpg'),
                                                    SizedBox(
                                                      height: 10,
                                                    ),
                                                    Text(
                                                      'Aucune vehiucle de transport trouvé',
                                                      style: TextStyle(
                                                        color: Colors.black,
                                                        fontSize: 17,
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          )
                                        : filtereSearch.isEmpty &&
                                                isLoading == true
                                            ? _buildShimmerEffect()
                                            : Column(
                                                children: [
                                                  if (produitsLocaux
                                                      .isNotEmpty) ...[
                                                    Padding(
                                                      padding:
                                                          const EdgeInsets.all(
                                                              8.0),
                                                      child: Text(
                                                        "Transport locaux",
                                                        style: TextStyle(
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            fontSize: 18),
                                                      ),
                                                    ),
                                                    GridView.builder(
                                                      shrinkWrap: true,
                                                      physics:
                                                          NeverScrollableScrollPhysics(),
                                                      gridDelegate:
                                                          SliverGridDelegateWithFixedCrossAxisCount(
                                                        crossAxisCount: 2,
                                                        mainAxisSpacing: 10,
                                                        crossAxisSpacing: 10,
                                                        childAspectRatio: 0.8,
                                                      ),
                                                      itemCount:
                                                          produitsLocaux.length,
                                                      itemBuilder:
                                                          (context, index) {
                                                        if (index <
                                                            produitsLocaux
                                                                .length) {
                                                          return GestureDetector(
                                                            onTap: () {
                                                              Navigator.push(
                                                                  context,
                                                                  MaterialPageRoute(
                                                                      builder: (context) =>
                                                                          DetailTransport(
                                                                              vehicule: produitsLocaux[index])));
                                                            },
                                                            child: Card(
                                                              margin: EdgeInsets
                                                                  .all(8),
                                                              child: Column(
                                                                crossAxisAlignment:
                                                                    CrossAxisAlignment
                                                                        .stretch,
                                                                children: [
                                                                  ClipRRect(
                                                                    borderRadius:
                                                                        BorderRadius.circular(
                                                                            8.0),
                                                                    child:
                                                                        SizedBox(
                                                                      height:
                                                                          85,
                                                                      child: produitsLocaux[index].photoVehicule == null ||
                                                                              produitsLocaux[index].photoVehicule!.isEmpty
                                                                          ? Image.asset(
                                                                              "assets/images/default_image.png",
                                                                              fit: BoxFit.cover,
                                                                            )
                                                                          : CachedNetworkImage(
                                                                              imageUrl: "https://koumi.ml/api-koumi/vehicule/${produitsLocaux[index].idVehicule}/image",
                                                                              fit: BoxFit.cover,
                                                                              placeholder: (context, url) => const Center(child: CircularProgressIndicator()),
                                                                              errorWidget: (context, url, error) => Image.asset(
                                                                                'assets/images/default_image.png',
                                                                                fit: BoxFit.cover,
                                                                              ),
                                                                            ),
                                                                    ),
                                                                  ),
                                                                  // SizedBox(height: 8),
                                                                  ListTile(
                                                                    title: Text(
                                                                      produitsLocaux[
                                                                              index]
                                                                          .nomVehicule,
                                                                      style:
                                                                          TextStyle(
                                                                        fontSize:
                                                                            16,
                                                                        fontWeight:
                                                                            FontWeight.bold,
                                                                        color: Colors
                                                                            .black87,
                                                                      ),
                                                                      maxLines:
                                                                          2,
                                                                      overflow:
                                                                          TextOverflow
                                                                              .ellipsis,
                                                                    ),
                                                                    subtitle:
                                                                        Text(
                                                                      "${produitsLocaux[index].nbKilometrage.toString()} Km",
                                                                      style:
                                                                          TextStyle(
                                                                        fontSize:
                                                                            15,
                                                                        color: Colors
                                                                            .black87,
                                                                      ),
                                                                    ),
                                                                  ),
                                                                  Padding(
                                                                    padding: const EdgeInsets
                                                                        .symmetric(
                                                                        horizontal:
                                                                            15),
                                                                    child: Text(
                                                                      produitsLocaux[
                                                                              index]
                                                                          .localisation,
                                                                      style:
                                                                          TextStyle(
                                                                        fontSize:
                                                                            15,
                                                                        color: Colors
                                                                            .black87,
                                                                      ),
                                                                    ),
                                                                  )
                                                                ],
                                                              ),
                                                            ),
                                                          );
                                                        } else {
                                                          return isLoading ==
                                                                  true
                                                              ? Padding(
                                                                  padding: const EdgeInsets
                                                                      .symmetric(
                                                                      horizontal:
                                                                          32),
                                                                  child: Center(
                                                                      child:
                                                                          const Center(
                                                                    child:
                                                                        CircularProgressIndicator(
                                                                      color: Colors
                                                                          .orange,
                                                                    ),
                                                                  )),
                                                                )
                                                              : Container();
                                                        }
                                                      },
                                                    ),
                                                  ],
                                                  if (produitsEtrangers
                                                      .isNotEmpty) ...[
                                                    Padding(
                                                      padding:
                                                          const EdgeInsets.all(
                                                              8.0),
                                                      child: Text(
                                                        "Transport etrangère",
                                                        style: TextStyle(
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            fontSize: 18),
                                                      ),
                                                    ),
                                                    GridView.builder(
                                                      shrinkWrap: true,
                                                      physics:
                                                          NeverScrollableScrollPhysics(),
                                                      gridDelegate:
                                                          SliverGridDelegateWithFixedCrossAxisCount(
                                                        crossAxisCount: 2,
                                                        mainAxisSpacing: 10,
                                                        crossAxisSpacing: 10,
                                                        childAspectRatio: 0.8,
                                                      ),
                                                      itemCount:
                                                          produitsEtrangers
                                                              .length,
                                                      itemBuilder:
                                                          (context, index) {
                                                        if (index <
                                                            produitsEtrangers
                                                                .length) {
                                                          return GestureDetector(
                                                            onTap: () {
                                                              Navigator.push(
                                                                  context,
                                                                  MaterialPageRoute(
                                                                      builder: (context) =>
                                                                          DetailTransport(
                                                                              vehicule: produitsEtrangers[index])));
                                                            },
                                                            child: Card(
                                                              margin: EdgeInsets
                                                                  .all(8),
                                                              child: Column(
                                                                crossAxisAlignment:
                                                                    CrossAxisAlignment
                                                                        .stretch,
                                                                children: [
                                                                  ClipRRect(
                                                                    borderRadius:
                                                                        BorderRadius.circular(
                                                                            8.0),
                                                                    child:
                                                                        SizedBox(
                                                                      height:
                                                                          85,
                                                                      child: produitsEtrangers[index].photoVehicule == null ||
                                                                              produitsEtrangers[index].photoVehicule!.isEmpty
                                                                          ? Image.asset(
                                                                              "assets/images/default_image.png",
                                                                              fit: BoxFit.cover,
                                                                            )
                                                                          : CachedNetworkImage(
                                                                              imageUrl: "https://koumi.ml/api-koumi/vehicule/${produitsEtrangers[index].idVehicule}/image",
                                                                              fit: BoxFit.cover,
                                                                              placeholder: (context, url) => const Center(child: CircularProgressIndicator()),
                                                                              errorWidget: (context, url, error) => Image.asset(
                                                                                'assets/images/default_image.png',
                                                                                fit: BoxFit.cover,
                                                                              ),
                                                                            ),
                                                                    ),
                                                                  ),
                                                                  // SizedBox(height: 8),
                                                                  ListTile(
                                                                    title: Text(
                                                                      produitsEtrangers[
                                                                              index]
                                                                          .nomVehicule,
                                                                      style:
                                                                          TextStyle(
                                                                        fontSize:
                                                                            16,
                                                                        fontWeight:
                                                                            FontWeight.bold,
                                                                        color: Colors
                                                                            .black87,
                                                                      ),
                                                                      maxLines:
                                                                          2,
                                                                      overflow:
                                                                          TextOverflow
                                                                              .ellipsis,
                                                                    ),
                                                                    subtitle:
                                                                        Text(
                                                                      "${produitsEtrangers[index].nbKilometrage.toString()} Km",
                                                                      style:
                                                                          TextStyle(
                                                                        fontSize:
                                                                            15,
                                                                        color: Colors
                                                                            .black87,
                                                                      ),
                                                                    ),
                                                                  ),
                                                                  Padding(
                                                                    padding: const EdgeInsets
                                                                        .symmetric(
                                                                        horizontal:
                                                                            15),
                                                                    child: Text(
                                                                      produitsEtrangers[
                                                                              index]
                                                                          .localisation,
                                                                      style:
                                                                          TextStyle(
                                                                        fontSize:
                                                                            15,
                                                                        color: Colors
                                                                            .black87,
                                                                      ),
                                                                    ),
                                                                  )
                                                                ],
                                                              ),
                                                            ),
                                                          );
                                                        } else {
                                                          return isLoading ==
                                                                  true
                                                              ? Padding(
                                                                  padding: const EdgeInsets
                                                                      .symmetric(
                                                                      horizontal:
                                                                          32),
                                                                  child: Center(
                                                                      child:
                                                                          const Center(
                                                                    child:
                                                                        CircularProgressIndicator(
                                                                      color: Colors
                                                                          .orange,
                                                                    ),
                                                                  )),
                                                                )
                                                              : Container();
                                                        }
                                                      },
                                                    ),
                                                  ],
                                                ],
                                              );
                                  }
                                });
                          }),
                        ),
                ),
              ))),
        ));
  }

  Widget _buildShimmerEffect() {
    return Center(
      child: GridView.builder(
        shrinkWrap: true,
        physics: NeverScrollableScrollPhysics(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 10,
          crossAxisSpacing: 10,
          childAspectRatio: 0.8,
        ),
        itemCount: 6, // Number of shimmer items to display
        itemBuilder: (context, index) {
          return Card(
            margin: EdgeInsets.all(8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8.0),
                  child: Shimmer.fromColors(
                    baseColor: Colors.grey[300]!,
                    highlightColor: Colors.grey[100]!,
                    child: Container(
                      height: 85,
                      color: Colors.grey,
                    ),
                  ),
                ),
                ListTile(
                  title: Shimmer.fromColors(
                    baseColor: Colors.grey[300]!,
                    highlightColor: Colors.grey[100]!,
                    child: Container(
                      height: 16,
                      color: Colors.grey,
                    ),
                  ),
                  subtitle: Shimmer.fromColors(
                    baseColor: Colors.grey[300]!,
                    highlightColor: Colors.grey[100]!,
                    child: Container(
                      height: 15,
                      color: Colors.grey,
                      margin: EdgeInsets.only(top: 4),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 15),
                  child: Shimmer.fromColors(
                    baseColor: Colors.grey[300]!,
                    highlightColor: Colors.grey[100]!,
                    child: Container(
                      height: 15,
                      color: Colors.grey,
                      margin: EdgeInsets.only(top: 4),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildItem(String title, String value) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(
                color: Colors.black87,
                fontWeight: FontWeight.w500,
                fontStyle: FontStyle.italic,
                overflow: TextOverflow.ellipsis,
                fontSize: 16),
          ),
          Text(
            value,
            style: const TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.w800,
                overflow: TextOverflow.ellipsis,
                fontSize: 16),
          )
        ],
      ),
    );
  }

  DropdownButtonFormField<String> buildDropdown(List<TypeVoiture> typeList) {
    return DropdownButtonFormField<String>(
      isExpanded: true,
      items: typeList
          .map((e) => DropdownMenuItem(
                value: e.idTypeVoiture,
                child: Text(e.nom!),
              ))
          .toList(),
      hint: Text("-- Filtre par categorie --"),
      value: typeValue,
      onChanged: (newValue) {
        setState(() {
          typeValue = newValue;
          if (newValue != null) {
            selectedType = typeList.firstWhere(
              (element) => element.idTypeVoiture == newValue,
            );
          }
          page = 0;
          hasMore = true;
          fetchVehiculeByTypeVoitureWithPagination(selectedType!.idTypeVoiture!,
              detectedCountry != null ? detectedCountry! : "Mali",
              refresh: true);
          if (page == 0 && isLoading == true) {
            SchedulerBinding.instance.addPostFrameCallback((_) {
              scrollableController1.jumpTo(0.0);
            });
          }
        });
      },
      decoration: InputDecoration(
        contentPadding: const EdgeInsets.symmetric(vertical: 5, horizontal: 22),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(22),
        ),
      ),
    );
  }

  DropdownButtonFormField buildEmptyDropdown() {
    return DropdownButtonFormField(
      items: [],
      onChanged: null,
      decoration: InputDecoration(
        labelText: '-- Aucun type trouvé --',
        contentPadding: const EdgeInsets.symmetric(vertical: 5, horizontal: 22),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(22),
        ),
      ),
    );
  }

  DropdownButtonFormField buildLoadingDropdown() {
    return DropdownButtonFormField(
      items: [],
      onChanged: null,
      decoration: InputDecoration(
        labelText: 'Chargement...',
        contentPadding: const EdgeInsets.symmetric(vertical: 5, horizontal: 22),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(22),
        ),
      ),
    );
  }
}
