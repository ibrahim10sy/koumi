import 'dart:convert';
import 'dart:developer';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:http/http.dart' as http;
import 'package:koumi/constants.dart';
import 'package:koumi/models/Acteur.dart';
import 'package:koumi/models/CategorieProduit.dart';
import 'package:koumi/models/Intrant.dart';
import 'package:koumi/models/TypeActeur.dart';
import 'package:koumi/providers/ActeurProvider.dart';
import 'package:koumi/screens/AddIntrant.dart';
import 'package:koumi/screens/DetailIntrant.dart';
import 'package:koumi/screens/ListeIntrantByActeur.dart';
import 'package:koumi/service/IntrantService.dart';
import 'package:koumi/widgets/AutoComptet.dart';
import 'package:koumi/widgets/DetectorPays.dart';
import 'package:provider/provider.dart';
import 'package:search_field_autocomplete/search_field_autocomplete.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shimmer/shimmer.dart';

class SemenceAndPlant extends StatefulWidget {
  SemenceAndPlant({super.key});

  @override
  State<SemenceAndPlant> createState() => _SemenceAndPlantState();
}

const d_colorGreen = Color.fromRGBO(43, 103, 6, 1);
const d_colorOr = Color.fromRGBO(255, 138, 0, 1);

class _SemenceAndPlantState extends State<SemenceAndPlant> {
  int page = 0;
  bool isLoading = false;
  late TextEditingController _searchController;
  ScrollController scrollableController = ScrollController();
  int size = sized;
  String? detectedCountry;
  bool isExist = false;
  late Acteur acteur = Acteur();
  String? email = "";
  late List<TypeActeur> typeActeurData = [];
  late String type;
  bool hasMore = true;
  late Future<List<Intrant>> intrantListeFuture;
  late Future<List<Intrant>> intrantListeFuture1;
  List<Intrant> intrantListe = [];
  List<Intrant> intrantList = [];
  String? catValue;
  late Future _typeList;
  bool isSearchMode = false;
  bool isFilterMode = false;
  CategorieProduit? selectedCat;
  // CategorieProduit? selectedType;
  ScrollController scrollableController1 = ScrollController();

  String libelle = "Semences et plants";

  void _scrollListener() {
    debugPrint("Scroll position: ${scrollableController.position.pixels}");
    if (scrollableController.position.pixels >=
            scrollableController.position.maxScrollExtent - 200 &&
        hasMore &&
        !isLoading) {
      setState(() {
        page++;
      });

      fetchIntrantByCategorie(
              detectedCountry != null ? detectedCountry! : "Mali")
          .then((value) {
        setState(() {
          debugPrint("page inc all $page");
        });
      });
    }
    debugPrint("no");
  }

  Future<List<Intrant>> fetchIntrantByCategorie(String pays,
      {bool refresh = false}) async {
    if (isLoading == true) return [];

    setState(() {
      isLoading = true;
    });

    if (refresh) {
      setState(() {
        intrantListe.clear();
        page = 0;
        hasMore = true;
      });
    }

    try {
      // for (String libelle in libelles) {
      final response = await http.get(Uri.parse(
          '$apiOnlineUrl/intrant/listeIntrantByLibelleCategorie?libelle=$libelle&pays=$pays&page=$page&size=$size'));
      debugPrint(
          '$apiOnlineUrl/intrant/listeIntrantByLibelleCategorie?libelle=$libelle&pays=$pays&page=$page&size=$size');
      if (response.statusCode == 200) {
        final jsonData = jsonDecode(utf8.decode(response.bodyBytes));
        final List<dynamic> body = jsonData['content'];

        if (body.isEmpty) {
          setState(() {
            hasMore = false;
          });
        } else {
          List<Intrant> newIntrants =
              body.map((e) => Intrant.fromMap(e)).toList();

          setState(() {
            // Ajouter uniquement les nouveaux intrants qui ne sont pas déjà dans la liste
            intrantListe.addAll(newIntrants.where((newIntrant) =>
                !intrantListe.any((existingIntrant) =>
                    existingIntrant.idIntrant == newIntrant.idIntrant)));
          });
        }

        debugPrint(
            "response body all intrants by categorie with pagination ${page} par défilement soit ${intrantListe.length}");
      } else {
        print(
            'Échec de la requête avec le code d\'état: ${response.statusCode} |  ${response.body}');
      }
    } catch (e) {
      print(
          'Une erreur s\'est produite lors de la récupération des intrants: $e');
    } finally {
      setState(() {
        isLoading = false;
      });
    }
    return intrantListe;
  }

  void _scrollListener1() {
    if (scrollableController1.position.pixels >=
            scrollableController1.position.maxScrollExtent - 200 &&
        hasMore &&
        !isLoading &&
        selectedCat != null) {
      // if (selectedCat != null) {
      // Incrementez la page et récupérez les stocks par catégorie
      debugPrint("yes - fetch by category and pays");
      if (mounted)
        setState(() {
          // Rafraîchir les données ici
          page++;
        });

      fetchIntrantByCategorieAndFiliere(
              detectedCountry != null ? detectedCountry! : "Mali")
          .then((value) {
        setState(() {
          // Rafraîchir les données ici
          debugPrint("page inc all ${page}");
        });
      });
    }
    debugPrint("no");
  }

  Future<List<Intrant>> fetchIntrantByCategorieAndFiliere(String pays,
      {bool refresh = false}) async {
    if (isLoading == true) return [];

    setState(() {
      isLoading = true;
    });

    if (refresh) {
      setState(() {
        intrantListe.clear();
        page = 0;
        hasMore = true;
      });
    }

    try {
      // for (String libelle in libelles) {
      final response = await http.get(Uri.parse(
          '$apiOnlineUrl/intrant/listeIntrantByLibelleFiliereAndIcategorie?idCategorie=${selectedCat!.idCategorieProduit}&libelle=$libelle&pays=$pays&page=$page&size=$size'));
      debugPrint(
          '$apiOnlineUrl/intrant/listeIntrantByLibelleFiliereAndIcategorie?idCategorie=${selectedCat!.idCategorieProduit}&libelle=$libelle&pays=$pays&page=$page&size=$size');
      if (response.statusCode == 200) {
        final jsonData = jsonDecode(utf8.decode(response.bodyBytes));
        final List<dynamic> body = jsonData['content'];

        if (body.isEmpty) {
          setState(() {
            hasMore = false;
          });
        } else {
          List<Intrant> newIntrants =
              body.map((e) => Intrant.fromMap(e)).toList();

          setState(() {
            // Ajouter uniquement les nouveaux intrants qui ne sont pas déjà dans la liste
            intrantListe.addAll(newIntrants.where((newIntrant) =>
                !intrantListe.any((existingIntrant) =>
                    existingIntrant.idIntrant == newIntrant.idIntrant)));
          });
        }

        debugPrint(
            "response body all intrants by categorie with pagination ${page} par défilement soit ${intrantListe.length}");
      } else {
        print(
            'Échec de la requête avec le code d\'état: ${response.statusCode} |  ${response.body}');
      }
    } catch (e) {
      print(
          'Une erreur s\'est produite lors de la récupération des intrants: $e');
    } finally {
      setState(() {
        isLoading = false;
      });
    }
    return intrantListe;
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

  Future<List<Intrant>> getAllIntrant() async {
    if (selectedCat != null) {
      intrantListe = await IntrantService().fetchIntrantByCategorieAndFilieres(
          selectedCat!.idCategorieProduit!,
          libelle,
          detectedCountry != null ? detectedCountry! : "Mali");
    }

    return intrantListe;
  }

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      scrollableController.addListener(_scrollListener);
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      scrollableController1.addListener(_scrollListener1);
    });
    final paysProvider = Provider.of<DetectorPays>(context, listen: false);
    paysProvider.hasLocation
        ? detectedCountry =
            Provider.of<DetectorPays>(context, listen: false).detectedCountry!
        : detectedCountry = "Mali";
    verify();
    _typeList = http.get(Uri.parse(
        '$apiOnlineUrl/Categorie/allCategorieByLibelleFiliere/$libelle'));
    intrantListeFuture1 = getAllIntrant();
    intrantListeFuture = fetchIntrantByCategorie(
        detectedCountry != null ? detectedCountry! : "Mali");
  }

  Future<void> _getResultFromNextScreen1(BuildContext context) async {
    final result = await Navigator.push(
        context, MaterialPageRoute(builder: (context) => AddIntrant()));
    log(result.toString());
    if (result == true) {
      print("Rafraichissement en cours");
      setState(() {
        intrantListeFuture = IntrantService().fetchIntrantByPays(
            detectedCountry != null ? detectedCountry! : "Mali");
      });
    }
  }

  Future<void> _getResultFromNextScreen2(BuildContext context) async {
    final result = await Navigator.push(
        context, MaterialPageRoute(builder: (context) => ListeIntrantByActeur()));
    log(result.toString());
    if (result == true) {
      print("Rafraichissement en cours");
      setState(() {
        intrantListeFuture = IntrantService().fetchIntrantByPays(
            detectedCountry != null ? detectedCountry! : "Mali");
      });
    }
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

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  @override
  void dispose() {
   
      _searchController.dispose();
    scrollableController.dispose();
    scrollableController1.dispose();
    super.dispose();
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
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
            backgroundColor: const Color.fromARGB(255, 255, 255, 255),
            centerTitle: true,
            toolbarHeight: 100,
            leading: IconButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                icon: const Icon(Icons.arrow_back_ios)),
            title: const Text(
              "Semences et plants ",
              style: TextStyle(
                color: d_colorGreen,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            actions: !isExist
                ? [
                    IconButton(
                        onPressed: () {
                          intrantListeFuture = fetchIntrantByCategorie(
                              detectedCountry != null
                                  ? detectedCountry!
                                  : "Mali");
                        },
                        icon: const Icon(Icons.refresh, color: d_colorGreen)),
                  ]
                : (typeActeurData
                            .map((e) => e.libelle!.toLowerCase())
                            .contains("fournisseur") ||
                        typeActeurData
                            .map((e) => e.libelle!.toLowerCase())
                            .contains("admin") ||
                        typeActeurData
                            .map((e) => e.libelle!.toLowerCase())
                            .contains("fournisseurs"))
                    ? [
                        IconButton(
                            onPressed: () {
                              intrantListeFuture = fetchIntrantByCategorie(
                                  detectedCountry != null
                                      ? detectedCountry!
                                      : "Mali");
                            },
                            icon:
                                const Icon(Icons.refresh, color: d_colorGreen)),
                        PopupMenuButton<String>(
                          padding: EdgeInsets.zero,
                          itemBuilder: (context) {
                            return <PopupMenuEntry<String>>[
                              PopupMenuItem<String>(
                                child: ListTile(
                                  leading: const Icon(
                                    Icons.add,
                                    color: d_colorGreen,
                                  ),
                                  title: const Text(
                                    "Ajouter intrant ",
                                    style: TextStyle(
                                      color: d_colorGreen,
                                      fontSize: 18,
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
                                    color: d_colorGreen,
                                  ),
                                  title: const Text(
                                    "Mes intrants ",
                                    style: TextStyle(
                                      color: d_colorGreen,
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  onTap: () async {
                                    Navigator.of(context).pop();
                                    _getResultFromNextScreen2(context);
                                  },
                                ),
                              )
                            ];
                          },
                        )
                      ]
                    : [
                        IconButton(
                            onPressed: () {
                              intrantListeFuture = fetchIntrantByCategorie(
                                  detectedCountry != null
                                      ? detectedCountry!
                                      : "Mali");
                            },
                            icon:
                                const Icon(Icons.refresh, color: d_colorGreen)),
                      ]),
        body: GestureDetector(
          onTap: () {
            FocusScope.of(context).unfocus();
          },
          child: Container(
              child: NestedScrollView(
                  headerSliverBuilder:
                      (BuildContext context, bool innerBoxIsScrolled) {
                    return <Widget>[
                      SliverToBoxAdapter(
                          child: Column(children: [
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
                          'Rechercher',
                          style: TextStyle(color: d_colorGreen, fontSize: 17),
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
                                      _searchController =
                                          TextEditingController();
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
                                  dynamic responseData = json.decode(jsonString);
                                  //
                                  // }
                                  if (responseData is List) {
                                    final reponse = responseData;
                                    final typeList = reponse
                                        .map((e) => CategorieProduit.fromMap(e))
                                        .where(
                                            (con) => con.statutCategorie == true)
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
                          ),
                        ),
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
                              suggestions: AutoComplet.getAgriculturalInputs,
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
                          // Rafraîchir les données ici
                        });
                        debugPrint("refresh page ${page}");
                        selectedCat != null
                            ? setState(() {
                                intrantListeFuture = IntrantService()
                                    .fetchIntrantByCategorieAndFilieres(
                                        selectedCat!.idCategorieProduit!,
                                        libelle,
                                        detectedCountry != null
                                            ? detectedCountry!
                                            : "Mali");
                              })
                            : setState(() {
                                intrantListeFuture = fetchIntrantByCategorie(
                                    detectedCountry != null
                                        ? detectedCountry!
                                        : "Mali");
                              });
                      },
                      child: selectedCat == null
                          ? SingleChildScrollView(
                              controller: scrollableController,
                              child: Consumer<IntrantService>(
                                  builder: (context, intrantService, child) {
                                return FutureBuilder(
                                    future: intrantListeFuture,
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
                                        intrantList = snapshot.data!;
                                        String searchText = "";
                                         
                                          List<Intrant> produitsLocaux = intrantList.where((element) =>  element
                                                    .acteur!.niveau3PaysActeur! == detectedCountry!,)
                                          .where((cate) {
                                          String nomCat =
                                              cate.nomIntrant!.toLowerCase();
                                          searchText = _searchController.text
                                              .toLowerCase();
                                          return nomCat.contains(searchText);
                                        }).toList();
          
                                        List<Intrant> produitsEtrangers = intrantList.where((element) =>  element
                                                    .acteur!.niveau3PaysActeur! !=
                                                detectedCountry,).where((cate) {
                                          String nomCat =
                                              cate.nomIntrant!.toLowerCase();
                                          searchText = _searchController.text
                                              .toLowerCase();
                                          return nomCat.contains(searchText);
                                        }).toList();
          
                                        List<Intrant> filteredSearch =
                                            intrantList.where((cate) {
                                          String nomCat =
                                              cate.nomIntrant!.toLowerCase();
                                          searchText = _searchController.text
                                              .toLowerCase();
                                          return nomCat.contains(searchText);
                                        }).toList();
                                        return filteredSearch
                                                    // .where((element) => element.statutIntrant == true)
                                                    .isEmpty &&
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
                                                          'Aucun produit trouvé',
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
                                            :  Column(
                                              children: [
                                                 if (produitsLocaux
                                                      .isNotEmpty) ...[
                                                    Padding(
                                                      padding:
                                                          const EdgeInsets.all(
                                                              8.0),
                                                      child: Text(
                                                        "Produits locaux",
                                                        style: TextStyle(
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            color: d_colorGreen,
                                                            fontSize: 16),
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
                                                    itemBuilder: (context, index) {
                                                      if (index <
                                                          produitsLocaux.length) {
                                                        return GestureDetector(
                                                          onTap: () {
                                                            Navigator.push(
                                                              context,
                                                              MaterialPageRoute(
                                                                builder: (context) =>
                                                                    DetailIntrant(
                                                                  intrant:
                                                                      produitsLocaux[
                                                                          index],
                                                                ),
                                                              ),
                                                            );
                                                          },
                                                          child: Card(
                                                            margin: EdgeInsets.all(8),
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
                                                                    child: produitsLocaux[index]
                                                                                    .photoIntrant ==
                                                                                null ||
                                                                            produitsLocaux[
                                                                                    index]
                                                                                .photoIntrant!
                                                                                .isEmpty
                                                                        ? Image.asset(
                                                                            "assets/images/default_image.png",
                                                                            fit: BoxFit
                                                                                .cover,
                                                                          )
                                                                        : CachedNetworkImage(
                                                                            imageUrl:
                                                                                "https://koumi.ml/api-koumi/intrant/${produitsLocaux[index].idIntrant}/image",
                                                                            fit: BoxFit
                                                                                .cover,
                                                                            placeholder: (context,
                                                                                    url) =>
                                                                                const Center(
                                                                                    child: CircularProgressIndicator()),
                                                                            errorWidget: (context,
                                                                                    url,
                                                                                    error) =>
                                                                                Image
                                                                                    .asset(
                                                                              'assets/images/default_image.png',
                                                                              fit: BoxFit
                                                                                  .cover,
                                                                            ),
                                                                          ),
                                                                  ),
                                                                ),
                                                                // SizedBox(height: 8),
                                                                ListTile(
                                                                  title: Text(
                                                                    produitsLocaux[
                                                                            index]
                                                                        .nomIntrant!,
                                                                    style: TextStyle(
                                                                      fontSize: 16,
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
                                                                    "${produitsLocaux[index].quantiteIntrant.toString()} ${produitsLocaux[index].unite}",
                                                                    style: TextStyle(
                                                                      fontSize: 15,
                                                                      color: Colors
                                                                          .black87,
                                                                    ),
                                                                  ),
                                                                ),
                                                                Padding(
                                                                  padding:
                                                                      const EdgeInsets
                                                                          .symmetric(
                                                                          horizontal:
                                                                              15),
                                                                  child: Text(
                                                                    produitsLocaux[index]
                                                                                .monnaie !=
                                                                            null
                                                                        ? "${produitsLocaux[index].prixIntrant.toString()} ${produitsLocaux[index].monnaie!.libelle}"
                                                                        : "${produitsLocaux[index].prixIntrant.toString()} FCFA ",
                                                                    style: TextStyle(
                                                                      fontSize: 15,
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
                                                                    color:
                                                                        Colors.orange,
                                                                  ),
                                                                )),
                                                              )
                                                            : Container();
                                                      }
                                                    },
                                                  ),
                                                    ],
                                                   // Section des produits étrangers
                                                  if (produitsEtrangers
                                                      .isNotEmpty) ...[
                                                    Padding(
                                                      padding:
                                                          const EdgeInsets.all(
                                                              8.0),
                                                      child: Text(
                                                        "Produits etrangère",
                                                        style: TextStyle(
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            color: d_colorGreen,
                                                            fontSize: 16),
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
                                                    itemBuilder: (context, index) {
                                                      if (index <
                                                          produitsEtrangers.length) {
                                                        return GestureDetector(
                                                          onTap: () {
                                                            Navigator.push(
                                                              context,
                                                              MaterialPageRoute(
                                                                builder: (context) =>
                                                                    DetailIntrant(
                                                                  intrant:
                                                                      produitsEtrangers[
                                                                          index],
                                                                ),
                                                              ),
                                                            );
                                                          },
                                                          child: Card(
                                                            margin: EdgeInsets.all(8),
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
                                                                    child: produitsEtrangers[index]
                                                                                    .photoIntrant ==
                                                                                null ||
                                                                            produitsEtrangers[
                                                                                    index]
                                                                                .photoIntrant!
                                                                                .isEmpty
                                                                        ? Image.asset(
                                                                            "assets/images/default_image.png",
                                                                            fit: BoxFit
                                                                                .cover,
                                                                          )
                                                                        : CachedNetworkImage(
                                                                            imageUrl:
                                                                                "https://koumi.ml/api-koumi/intrant/${produitsEtrangers[index].idIntrant}/image",
                                                                            fit: BoxFit
                                                                                .cover,
                                                                            placeholder: (context,
                                                                                    url) =>
                                                                                const Center(
                                                                                    child: CircularProgressIndicator()),
                                                                            errorWidget: (context,
                                                                                    url,
                                                                                    error) =>
                                                                                Image
                                                                                    .asset(
                                                                              'assets/images/default_image.png',
                                                                              fit: BoxFit
                                                                                  .cover,
                                                                            ),
                                                                          ),
                                                                  ),
                                                                ),
                                                                // SizedBox(height: 8),
                                                                ListTile(
                                                                  title: Text(
                                                                    produitsEtrangers[
                                                                            index]
                                                                        .nomIntrant!,
                                                                    style: TextStyle(
                                                                      fontSize: 16,
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
                                                                    "${produitsEtrangers[index].quantiteIntrant.toString()} ${produitsEtrangers[index].unite}",
                                                                    style: TextStyle(
                                                                      fontSize: 15,
                                                                      color: Colors
                                                                          .black87,
                                                                    ),
                                                                  ),
                                                                ),
                                                                Padding(
                                                                  padding:
                                                                      const EdgeInsets
                                                                          .symmetric(
                                                                          horizontal:
                                                                              15),
                                                                  child: Text(
                                                                    produitsEtrangers[index]
                                                                                .monnaie !=
                                                                            null
                                                                        ? "${produitsEtrangers[index].prixIntrant.toString()} ${produitsEtrangers[index].monnaie!.libelle}"
                                                                        : "${produitsEtrangers[index].prixIntrant.toString()} FCFA ",
                                                                    style: TextStyle(
                                                                      fontSize: 15,
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
                                                                    color:
                                                                        Colors.orange,
                                                                  ),
                                                                )),
                                                              )
                                                            : Container();
                                                      }
                                                    },
                                                  ),
                                                    ]
                                              ],
                                            );
                                      }
                                    });
                              }),
                            )
                          : SingleChildScrollView(
                              controller: scrollableController1,
                              child: Consumer<IntrantService>(
                                  builder: (context, intrantService, child) {
                                return FutureBuilder(
                                    future: intrantListeFuture1,
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
                                        intrantList = snapshot.data!;
                                        String searchText = "";
                                         
                                          List<Intrant> produitsLocaux = intrantList.where((element) =>  element
                                                    .acteur!.niveau3PaysActeur! == detectedCountry!,)
                                          .where((cate) {
                                          String nomCat =
                                              cate.nomIntrant!.toLowerCase();
                                          searchText = _searchController.text
                                              .toLowerCase();
                                          return nomCat.contains(searchText);
                                        }).toList();
          
                                        List<Intrant> produitsEtrangers = intrantList.where((element) =>  element
                                                    .acteur!.niveau3PaysActeur! !=
                                                detectedCountry,).where((cate) {
                                          String nomCat =
                                              cate.nomIntrant!.toLowerCase();
                                          searchText = _searchController.text
                                              .toLowerCase();
                                          return nomCat.contains(searchText);
                                        }).toList();
          
                                        List<Intrant> filteredSearch =
                                            intrantList.where((cate) {
                                          String nomCat =
                                              cate.nomIntrant!.toLowerCase();
                                          searchText = _searchController.text
                                              .toLowerCase();
                                          return nomCat.contains(searchText);
                                        }).toList();
                                        return filteredSearch
                                                    // .where((element) => element.statutIntrant == true)
                                                    .isEmpty &&
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
                                                          'Aucun produit trouvé',
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
                                            :  Column(
                                              children: [
                                                 if (produitsLocaux
                                                      .isNotEmpty) ...[
                                                    Padding(
                                                      padding:
                                                          const EdgeInsets.all(
                                                              8.0),
                                                      child: Text(
                                                        "Produits locaux",
                                                        style: TextStyle(
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            color: d_colorGreen,
                                                            fontSize: 16),
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
                                                    itemBuilder: (context, index) {
                                                      if (index <
                                                          produitsLocaux.length) {
                                                        return GestureDetector(
                                                          onTap: () {
                                                            Navigator.push(
                                                              context,
                                                              MaterialPageRoute(
                                                                builder: (context) =>
                                                                    DetailIntrant(
                                                                  intrant:
                                                                      produitsLocaux[
                                                                          index],
                                                                ),
                                                              ),
                                                            );
                                                          },
                                                          child: Card(
                                                            margin: EdgeInsets.all(8),
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
                                                                    child: produitsLocaux[index]
                                                                                    .photoIntrant ==
                                                                                null ||
                                                                            produitsLocaux[
                                                                                    index]
                                                                                .photoIntrant!
                                                                                .isEmpty
                                                                        ? Image.asset(
                                                                            "assets/images/default_image.png",
                                                                            fit: BoxFit
                                                                                .cover,
                                                                          )
                                                                        : CachedNetworkImage(
                                                                            imageUrl:
                                                                                "https://koumi.ml/api-koumi/intrant/${produitsLocaux[index].idIntrant}/image",
                                                                            fit: BoxFit
                                                                                .cover,
                                                                            placeholder: (context,
                                                                                    url) =>
                                                                                const Center(
                                                                                    child: CircularProgressIndicator()),
                                                                            errorWidget: (context,
                                                                                    url,
                                                                                    error) =>
                                                                                Image
                                                                                    .asset(
                                                                              'assets/images/default_image.png',
                                                                              fit: BoxFit
                                                                                  .cover,
                                                                            ),
                                                                          ),
                                                                  ),
                                                                ),
                                                                // SizedBox(height: 8),
                                                                ListTile(
                                                                  title: Text(
                                                                    produitsLocaux[
                                                                            index]
                                                                        .nomIntrant!,
                                                                    style: TextStyle(
                                                                      fontSize: 16,
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
                                                                    "${produitsLocaux[index].quantiteIntrant.toString()} ${produitsLocaux[index].unite}",
                                                                    style: TextStyle(
                                                                      fontSize: 15,
                                                                      color: Colors
                                                                          .black87,
                                                                    ),
                                                                  ),
                                                                ),
                                                                Padding(
                                                                  padding:
                                                                      const EdgeInsets
                                                                          .symmetric(
                                                                          horizontal:
                                                                              15),
                                                                  child: Text(
                                                                    produitsLocaux[index]
                                                                                .monnaie !=
                                                                            null
                                                                        ? "${produitsLocaux[index].prixIntrant.toString()} ${produitsLocaux[index].monnaie!.libelle}"
                                                                        : "${produitsLocaux[index].prixIntrant.toString()} FCFA ",
                                                                    style: TextStyle(
                                                                      fontSize: 15,
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
                                                                    color:
                                                                        Colors.orange,
                                                                  ),
                                                                )),
                                                              )
                                                            : Container();
                                                      }
                                                    },
                                                  ),
                                                    ],
                                                   // Section des produits étrangers
                                                  if (produitsEtrangers
                                                      .isNotEmpty) ...[
                                                    Padding(
                                                      padding:
                                                          const EdgeInsets.all(
                                                              8.0),
                                                      child: Text(
                                                        "Produits etrangère",
                                                        style: TextStyle(
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            color: d_colorGreen,
                                                            fontSize: 16),
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
                                                    itemBuilder: (context, index) {
                                                      if (index <
                                                          produitsEtrangers.length) {
                                                        return GestureDetector(
                                                          onTap: () {
                                                            Navigator.push(
                                                              context,
                                                              MaterialPageRoute(
                                                                builder: (context) =>
                                                                    DetailIntrant(
                                                                  intrant:
                                                                      produitsEtrangers[
                                                                          index],
                                                                ),
                                                              ),
                                                            );
                                                          },
                                                          child: Card(
                                                            margin: EdgeInsets.all(8),
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
                                                                    child: produitsEtrangers[index]
                                                                                    .photoIntrant ==
                                                                                null ||
                                                                            produitsEtrangers[
                                                                                    index]
                                                                                .photoIntrant!
                                                                                .isEmpty
                                                                        ? Image.asset(
                                                                            "assets/images/default_image.png",
                                                                            fit: BoxFit
                                                                                .cover,
                                                                          )
                                                                        : CachedNetworkImage(
                                                                            imageUrl:
                                                                                "https://koumi.ml/api-koumi/intrant/${produitsEtrangers[index].idIntrant}/image",
                                                                            fit: BoxFit
                                                                                .cover,
                                                                            placeholder: (context,
                                                                                    url) =>
                                                                                const Center(
                                                                                    child: CircularProgressIndicator()),
                                                                            errorWidget: (context,
                                                                                    url,
                                                                                    error) =>
                                                                                Image
                                                                                    .asset(
                                                                              'assets/images/default_image.png',
                                                                              fit: BoxFit
                                                                                  .cover,
                                                                            ),
                                                                          ),
                                                                  ),
                                                                ),
                                                                // SizedBox(height: 8),
                                                                ListTile(
                                                                  title: Text(
                                                                    produitsEtrangers[
                                                                            index]
                                                                        .nomIntrant!,
                                                                    style: TextStyle(
                                                                      fontSize: 16,
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
                                                                    "${produitsEtrangers[index].quantiteIntrant.toString()} ${produitsEtrangers[index].unite}",
                                                                    style: TextStyle(
                                                                      fontSize: 15,
                                                                      color: Colors
                                                                          .black87,
                                                                    ),
                                                                  ),
                                                                ),
                                                                Padding(
                                                                  padding:
                                                                      const EdgeInsets
                                                                          .symmetric(
                                                                          horizontal:
                                                                              15),
                                                                  child: Text(
                                                                    produitsEtrangers[index]
                                                                                .monnaie !=
                                                                            null
                                                                        ? "${produitsEtrangers[index].prixIntrant.toString()} ${produitsEtrangers[index].monnaie!.libelle}"
                                                                        : "${produitsEtrangers[index].prixIntrant.toString()} FCFA ",
                                                                    style: TextStyle(
                                                                      fontSize: 15,
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
                                                                    color:
                                                                        Colors.orange,
                                                                  ),
                                                                )),
                                                              )
                                                            : Container();
                                                      }
                                                    },
                                                  ),
                                                    ]
                                              ],
                                            );
                                      }
                                    });
                              }),
                            )))),
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
                // overflow: TextOverflow.ellipsis,
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

  DropdownButtonFormField<String> buildDropdown(
      List<CategorieProduit> typeList) {
    return DropdownButtonFormField<String>(
      isExpanded: true,
      items: typeList
          .map((e) => DropdownMenuItem(
                value: e.idCategorieProduit,
                child: Text(e.libelleCategorie!),
              ))
          .toList(),
      hint: Text("-- Filtre par catégorie --"),
      value: catValue,
      onChanged: (newValue) {
        setState(() {
          catValue = newValue;
          if (newValue != null) {
            selectedCat = typeList.firstWhere(
              (element) => element.idCategorieProduit == newValue,
            );
          }

          page = 0;
          hasMore = true;
          fetchIntrantByCategorieAndFiliere(
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
        labelText: '-- Aucune catégorie trouvé --',
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
