import 'dart:convert';
import 'dart:developer';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:http/http.dart' as http;
import 'package:koumi/constants.dart';
import 'package:koumi/models/Acteur.dart';
import 'package:koumi/models/CategorieProduit.dart';
import 'package:koumi/models/Stock.dart';
import 'package:koumi/models/TypeActeur.dart';
import 'package:koumi/providers/ActeurProvider.dart';
import 'package:koumi/screens/AddAndUpdateProductScreen.dart';
import 'package:koumi/screens/DetailProduits.dart';
import 'package:koumi/service/StockService.dart';
import 'package:koumi/widgets/AutoComptet.dart';
import 'package:koumi/widgets/DetectorPays.dart';
import 'package:provider/provider.dart';
import 'package:search_field_autocomplete/search_field_autocomplete.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shimmer/shimmer.dart';

class ProduitTransforme extends StatefulWidget {
  ProduitTransforme({super.key});

  @override
  State<ProduitTransforme> createState() => _ProduitTransformeState();
}

const d_colorGreen = Color.fromRGBO(43, 103, 6, 1);
const d_colorOr = Color.fromRGBO(255, 138, 0, 1);

class _ProduitTransformeState extends State<ProduitTransforme> {
  late TextEditingController _searchController;
  List<Stock> stockListe = [];
  List<Stock> stockList = [];
  late Future<List<Stock>> stockListeFuture;
  late Future<List<Stock>> stockListeFuture1;
  String? detectedCountry;

  ScrollController scrollableController = ScrollController();
  ScrollController scrollableController1 = ScrollController();

  String libelle = "Produits transformés";
  bool isExist = false;
  String? email = "";
  late String type;
  late Acteur acteur = Acteur();
  late List<TypeActeur> typeActeurData = [];
  int page = 0;
  bool isLoading = false;
  int size = sized;
  bool hasMore = true;
  CategorieProduit? selectedCat;
  String? typeValue;
  late Future _catList;
  bool isSearchMode = false;
  bool isFilterMode = false;

  Future<List<Stock>> fetchStock(String pays, {bool refresh = false}) async {
    if (isLoading == true) return [];

    setState(() {
      isLoading = true;
    });

    if (refresh) {
      setState(() {
        stockListe.clear();
        page = 0;
        hasMore = true;
      });
    }

    try {
      // List<Stock> tempStockListe = [];
      // for (String libelle in libelles) {
      final response = await http.get(Uri.parse(
          '$apiOnlineUrl/Stock/listeStockByLibelleCategorie?libelle=$libelle&pays=$pays&page=$page&size=$size'));

      debugPrint(
          '$apiOnlineUrl/Stock/listeStockByLibelleCategorie?libelle=$libelle&pays=$pays&page=$page&size=$size');
      // '$apiOnlineUrl/Stock/listeStockByLibelleCategorie?libelle=$libelle&pays=$pays&page=$page&size=$size');
      if (response.statusCode == 200 || response.statusCode == 201) {
        final jsonData = jsonDecode(utf8.decode(response.bodyBytes));
        final List<dynamic> body = jsonData['content'];

        if (body.isEmpty) {
          setState(() {
            hasMore = false;
          });
        } else {
          List<Stock> newStocks = body.map((e) => Stock.fromMap(e)).toList();
          setState(() {
            stockListe.addAll(newStocks.where((newStock) => !stockListe
                .any((existStock) => existStock.idStock == newStock.idStock)));
          });
        }
        debugPrint(
            "response body all stock by categorie with pagination ${page} par défilement soit ${stockListe.length}");
      } else {
        print(
            'Échec de la requête avec le code d\'état: ${response.statusCode} |  ${response.body}');
      }
      // }
    } catch (e) {
      print(
          'Une erreur s\'est produite lors de la récupération des intrants: $e');
    } finally {
      setState(() {
        isLoading = false;
      });
    }
    return stockListe;
  }

  Future<List<Stock>> getAllStock() async {
    if (selectedCat != null) {
      stockListe = await StockService().fetchStockByCategorieAndFiliere(
          selectedCat!.idCategorieProduit!,
          libelle,
          detectedCountry != null ? detectedCountry! : "mali");
    }

    return stockListe;
  }

  Future<List<Stock>> fetchStockByCategorie(String niveau3PaysActeur,
      {bool refresh = false}) async {
    if (isLoading == true) return [];

    setState(() {
      isLoading = true;
    });

    if (refresh) {
      setState(() {
        stockListe.clear();
        page = 0;
        hasMore = true;
      });
    }

    try {
      final response = await http.get(Uri.parse(
          '$apiOnlineUrl/Stock/getAllStocksByCategorieAndFiliere?idCategorie=${selectedCat!.idCategorieProduit}&libelleFiliere=$libelle&niveau3PaysActeur=$niveau3PaysActeur&page=$page&size=$size'));

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(utf8.decode(response.bodyBytes));
        final List<dynamic> body = jsonData['content'];

        if (body.isEmpty) {
          setState(() {
            hasMore = false;
          });
        } else {
          List<Stock> newStocks = body.map((e) => Stock.fromMap(e)).toList();
          setState(() {
            stockListe.addAll(newStocks.where((newStock) => !stockListe
                .any((existStock) => existStock.idStock == newStock.idStock)));
          });
        }

        debugPrint(
            "response body all stock by categorie and pays with pagination ${page} par défilement soit ${stockListe.length}");
      } else {
        print(
            'Échec de la requête avec le code d\'état: ${response.statusCode} |  ${response.body}');
      }
    } catch (e) {
      print(
          'Une erreur s\'est produite lors de la récupération des stocks: $e');
    } finally {
      setState(() {
        isLoading = false;
      });
    }
    return stockListe;
  }

  void _scrollListener() {
    if (scrollableController.position.pixels >=
            scrollableController.position.maxScrollExtent - 200 &&
        hasMore &&
        !isLoading) {
      // if (selectedCat != null) {
      // Incrementez la page et récupérez les stocks par catégorie
      debugPrint("yes - fetch by category");
      setState(() {
        // Rafraîchir les données ici
        page++;
      });

      fetchStock(detectedCountry != null ? detectedCountry! : "Mali")
          .then((value) {
        setState(() {
          // Rafraîchir les données ici
          debugPrint("page inc all ${page}");
        });
      });
    }
    debugPrint("no");
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

      fetchStockByCategorie(detectedCountry != null ? detectedCountry! : "Mali")
          .then((value) {
        setState(() {
          // Rafraîchir les données ici
          debugPrint("page inc all ${page}");
        });
      });
    }
    debugPrint("no");
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
        // stockListeFuture = fetchAllStock();
      });
    } else {
      setState(() {
        isExist = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    final paysProvider = Provider.of<DetectorPays>(context, listen: false);
    paysProvider.hasLocation
        ? detectedCountry =
            Provider.of<DetectorPays>(context, listen: false).detectedCountry!
        : detectedCountry = "Mali";

    _searchController = TextEditingController();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      scrollableController.addListener(_scrollListener);
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      scrollableController1.addListener(_scrollListener1);
    });

    _catList = http.get(Uri.parse(
        '$apiOnlineUrl/Categorie/allCategorieByLibelleFiliere/$libelle'));
    stockListeFuture1 = getAllStock();
    stockListeFuture =
        fetchStock(detectedCountry != null ? detectedCountry! : "Mali");
    verify();
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
  void dispose() {
    _searchController.dispose();

    scrollableController.dispose();
    scrollableController1.dispose();
    super.dispose();
  }

  Future<void> _getResultFromNextScreen1(BuildContext context) async {
    final result = await Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => AddAndUpdateProductScreen(
                  isEditable: false,
                )));
    log(result.toString());
    if (result == true) {
      print("Rafraichissement en cours");
      setState(() {
        stockListeFuture =
            fetchStock(detectedCountry != null ? detectedCountry! : "Mali");
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: const Color.fromARGB(255, 255, 255, 255),
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
            "Produits transformés",
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          actions: !isExist
              ? [
                  IconButton(
                      onPressed: () {
                        stockListeFuture = fetchStock(detectedCountry != null
                            ? detectedCountry!
                            : "Mali");
                      },
                      icon: const Icon(Icons.refresh, color: Colors.white)),
                ]
              : [
                  IconButton(
                      onPressed: () {
                        stockListeFuture = fetchStock(detectedCountry != null
                            ? detectedCountry!
                            : "Mali");
                      },
                      icon: const Icon(Icons.refresh, color: Colors.white)),
                  (typeActeurData
                              .map((e) => e.libelle!.toLowerCase())
                              .contains("commercant") ||
                          typeActeurData
                              .map((e) => e.libelle!.toLowerCase())
                              .contains("commerçant") ||
                          typeActeurData
                              .map((e) => e.libelle!.toLowerCase())
                              .contains("admin") ||
                          typeActeurData
                              .map((e) => e.libelle!.toLowerCase())
                              .contains("producteur"))
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
                                    "Ajouter produit",
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
                            ];
                          },
                        )
                      : Container()
                ],
        ),
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
                                style: TextStyle(
                                    color: d_colorGreen, fontSize: 17),
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
                                  style: TextStyle(
                                      color: Colors.red, fontSize: 17),
                                ),
                              )),
                        Visibility(
                          visible: isSearchMode,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                                vertical: 3, horizontal: 10),
                            child: FutureBuilder(
                              future: _catList,
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
                                    final response = responseData;
                                    final typeList = response
                                        .map((e) => CategorieProduit.fromMap(e))
                                        .where((con) =>
                                            con.statutCategorie == true)
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
                              suggestions: AutoComplet.getAgriculturalProducts,
                              suggestionsDecoration: SuggestionDecoration(
                                marginSuggestions: const EdgeInsets.all(8.0),
                                color: const Color.fromARGB(255, 236, 234, 234),
                                borderRadius: BorderRadius.circular(16.0),
                              ),
                              onSuggestionSelected: (selectedItem) {
                                if (mounted) {
                                  _searchController.text =
                                      selectedItem.searchKey;
                                }
                              },
                              suggestionItemBuilder:
                                  (context, searchFieldItem) {
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
                                stockListeFuture1 = StockService()
                                    .fetchStockByCategorieAndFiliere(
                                        selectedCat!.idCategorieProduit!,
                                        libelle,
                                        detectedCountry != null
                                            ? detectedCountry!
                                            : "Mali");
                              })
                            : setState(() {
                                stockListeFuture = fetchStock(
                                    detectedCountry != null
                                        ? detectedCountry!
                                        : "Mali");
                              });
                        debugPrint("refresh page ${page}");
                      },
                      child: selectedCat == null
                          ? SingleChildScrollView(
                              controller: scrollableController,
                              child: Consumer<StockService>(
                                  builder: (context, intrantService, child) {
                                return FutureBuilder(
                                    future: stockListeFuture,
                                    builder: (context, snapshot) {
                                      if (snapshot.connectionState ==
                                          ConnectionState.waiting) {
                                        return _buildShimmerEffect();
                                      }

                                      if (!snapshot.hasData) {
                                        return const Padding(
                                          padding: EdgeInsets.all(10),
                                          child: Center(
                                              child:
                                                  Text("Aucun donné trouvé")),
                                        );
                                      } else {
                                        stockList = snapshot.data!;
                                        String searchText = "";

                                        List<Stock> produitsLocaux = stockList
                                            .where((stock) =>
                                                stock.acteur!
                                                    .niveau3PaysActeur! ==
                                                detectedCountry)
                                            .where((cate) {
                                          String nomCat =
                                              cate.nomProduit!.toLowerCase();
                                          searchText = _searchController.text
                                              .toLowerCase();
                                          return nomCat.contains(searchText);
                                        }).toList();

                                        List<Stock> produitsEtrangers =
                                            stockList
                                                .where((stock) =>
                                                    stock.acteur!
                                                        .niveau3PaysActeur! !=
                                                    detectedCountry)
                                                .where((cate) {
                                          String nomCat =
                                              cate.nomProduit!.toLowerCase();
                                          searchText = _searchController.text
                                              .toLowerCase();
                                          return nomCat.contains(searchText);
                                        }).toList();

                                        List<Stock> filteredSearch =
                                            stockList.where((cate) {
                                          String nomCat =
                                              cate.nomProduit!.toLowerCase();
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
                                                            overflow:
                                                                TextOverflow
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
                                                        mainAxisSpacing: 5,
                                                        crossAxisSpacing: 5,
                                                        childAspectRatio: 0.8,
                                                      ),
                                                      itemCount:
                                                          produitsLocaux.length,
                                                      // itemCount: stockListe.length + (isLoading ? 1 : 0),
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
                                                                    builder:
                                                                        (context) =>
                                                                            DetailProduits(
                                                                      stock: produitsLocaux[
                                                                          index],
                                                                    ),
                                                                  ),
                                                                );
                                                              },
                                                              child: Card(
                                                                margin:
                                                                    EdgeInsets
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
                                                                          Container(
                                                                        height:
                                                                            85,
                                                                        child: produitsLocaux[index].photo == null ||
                                                                                produitsLocaux[index].photo!.isEmpty
                                                                            ? Image.asset(
                                                                                "assets/images/default_image.png",
                                                                                fit: BoxFit.cover,
                                                                              )
                                                                            : CachedNetworkImage(
                                                                                imageUrl: "https://koumi.ml/api-koumi/Stock/${produitsLocaux[index].idStock}/image",
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
                                                                      title:
                                                                          Text(
                                                                        produitsLocaux[index]
                                                                            .nomProduit!,
                                                                        style:
                                                                            TextStyle(
                                                                          fontSize:
                                                                              16,
                                                                          fontWeight:
                                                                              FontWeight.bold,
                                                                          color:
                                                                              Colors.black87,
                                                                        ),
                                                                        maxLines:
                                                                            2,
                                                                        overflow:
                                                                            TextOverflow.ellipsis,
                                                                      ),
                                                                      subtitle:
                                                                          Text(
                                                                        overflow:
                                                                            TextOverflow.ellipsis,
                                                                        "${produitsLocaux[index].quantiteStock!.toString()} ${produitsLocaux[index].unite!.nomUnite} ",
                                                                        style:
                                                                            TextStyle(
                                                                          overflow:
                                                                              TextOverflow.ellipsis,
                                                                          fontSize:
                                                                              15,
                                                                          fontWeight:
                                                                              FontWeight.bold,
                                                                          color:
                                                                              Colors.black87,
                                                                        ),
                                                                      ),
                                                                    ),
                                                                    Padding(
                                                                      padding: const EdgeInsets
                                                                          .symmetric(
                                                                          horizontal:
                                                                              15),
                                                                      child:
                                                                          Text(
                                                                        produitsLocaux[index].monnaie !=
                                                                                null
                                                                            ? "${produitsLocaux[index].prix.toString()} ${produitsLocaux[index].monnaie!.libelle}"
                                                                            : "${produitsLocaux[index].prix.toString()} FCFA",
                                                                        style:
                                                                            TextStyle(
                                                                          fontSize:
                                                                              15,
                                                                          color:
                                                                              Colors.black87,
                                                                        ),
                                                                      ),
                                                                    ),
                                                                  ],
                                                                ),
                                                              ));
                                                        } else {
                                                          return isLoading ==
                                                                  true
                                                              ? Padding(
                                                                  padding: const EdgeInsets
                                                                      .symmetric(
                                                                      vertical:
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
                                                        mainAxisSpacing: 5,
                                                        crossAxisSpacing: 5,
                                                        childAspectRatio: 0.8,
                                                      ),
                                                      itemCount:
                                                          produitsEtrangers
                                                              .length,
                                                      // itemCount: stockListe.length + (isLoading ? 1 : 0),
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
                                                                    builder:
                                                                        (context) =>
                                                                            DetailProduits(
                                                                      stock: produitsEtrangers[
                                                                          index],
                                                                    ),
                                                                  ),
                                                                );
                                                              },
                                                              child: Card(
                                                                margin:
                                                                    EdgeInsets
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
                                                                          Container(
                                                                        height:
                                                                            85,
                                                                        child: produitsEtrangers[index].photo == null ||
                                                                                produitsEtrangers[index].photo!.isEmpty
                                                                            ? Image.asset(
                                                                                "assets/images/default_image.png",
                                                                                fit: BoxFit.cover,
                                                                              )
                                                                            : CachedNetworkImage(
                                                                                imageUrl: "https://koumi.ml/api-koumi/Stock/${produitsEtrangers[index].idStock}/image",
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
                                                                      title:
                                                                          Text(
                                                                        produitsEtrangers[index]
                                                                            .nomProduit!,
                                                                        style:
                                                                            TextStyle(
                                                                          fontSize:
                                                                              16,
                                                                          fontWeight:
                                                                              FontWeight.bold,
                                                                          color:
                                                                              Colors.black87,
                                                                        ),
                                                                        maxLines:
                                                                            2,
                                                                        overflow:
                                                                            TextOverflow.ellipsis,
                                                                      ),
                                                                      subtitle:
                                                                          Text(
                                                                        overflow:
                                                                            TextOverflow.ellipsis,
                                                                        "${produitsEtrangers[index].quantiteStock!.toString()} ${produitsEtrangers[index].unite!.nomUnite} ",
                                                                        style:
                                                                            TextStyle(
                                                                          overflow:
                                                                              TextOverflow.ellipsis,
                                                                          fontSize:
                                                                              15,
                                                                          fontWeight:
                                                                              FontWeight.bold,
                                                                          color:
                                                                              Colors.black87,
                                                                        ),
                                                                      ),
                                                                    ),
                                                                    Padding(
                                                                      padding: const EdgeInsets
                                                                          .symmetric(
                                                                          horizontal:
                                                                              15),
                                                                      child:
                                                                          Text(
                                                                        produitsEtrangers[index].monnaie !=
                                                                                null
                                                                            ? "${produitsEtrangers[index].prix.toString()} ${produitsEtrangers[index].monnaie!.libelle}"
                                                                            : "${produitsEtrangers[index].prix.toString()} FCFA",
                                                                        style:
                                                                            TextStyle(
                                                                          fontSize:
                                                                              15,
                                                                          color:
                                                                              Colors.black87,
                                                                        ),
                                                                      ),
                                                                    ),
                                                                  ],
                                                                ),
                                                              ));
                                                        } else {
                                                          return isLoading ==
                                                                  true
                                                              ? Padding(
                                                                  padding: const EdgeInsets
                                                                      .symmetric(
                                                                      vertical:
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
                                                  ]
                                                ],
                                              );
                                      }
                                    });
                              }),
                            )
                          : SingleChildScrollView(
                              controller: scrollableController1,
                              child: Consumer<StockService>(
                                  builder: (context, intrantService, child) {
                                return FutureBuilder(
                                    future: stockListeFuture1,
                                    builder: (context, snapshot) {
                                      if (snapshot.connectionState ==
                                          ConnectionState.waiting) {
                                        return _buildShimmerEffect();
                                      }

                                      if (!snapshot.hasData) {
                                        return const Padding(
                                          padding: EdgeInsets.all(10),
                                          child: Center(
                                              child:
                                                  Text("Aucun donné trouvé")),
                                        );
                                      } else {
                                        stockList = snapshot.data!;
                                        String searchText = "";

                                        List<Stock> produitsLocaux = stockList
                                            .where((stock) =>
                                                stock.acteur!
                                                    .niveau3PaysActeur! ==
                                                detectedCountry)
                                            .where((cate) {
                                          String nomCat =
                                              cate.nomProduit!.toLowerCase();
                                          searchText = _searchController.text
                                              .toLowerCase();
                                          return nomCat.contains(searchText);
                                        }).toList();

                                        List<Stock> produitsEtrangers =
                                            stockList
                                                .where((stock) =>
                                                    stock.acteur!
                                                        .niveau3PaysActeur! !=
                                                    detectedCountry)
                                                .where((cate) {
                                          String nomCat =
                                              cate.nomProduit!.toLowerCase();
                                          searchText = _searchController.text
                                              .toLowerCase();
                                          return nomCat.contains(searchText);
                                        }).toList();

                                        List<Stock> filteredSearch =
                                            stockList.where((cate) {
                                          String nomCat =
                                              cate.nomProduit!.toLowerCase();
                                          searchText = _searchController.text
                                              .toLowerCase();
                                          return nomCat.contains(searchText);
                                        }).toList();

                                        return filteredSearch.isEmpty &&
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
                                                            overflow:
                                                                TextOverflow
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
                                                        mainAxisSpacing: 5,
                                                        crossAxisSpacing: 5,
                                                        childAspectRatio: 0.8,
                                                      ),
                                                      itemCount:
                                                          produitsLocaux.length,
                                                      // itemCount: stockListe.length + (isLoading ? 1 : 0),
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
                                                                    builder:
                                                                        (context) =>
                                                                            DetailProduits(
                                                                      stock: produitsLocaux[
                                                                          index],
                                                                    ),
                                                                  ),
                                                                );
                                                              },
                                                              child: Card(
                                                                margin:
                                                                    EdgeInsets
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
                                                                          Container(
                                                                        height:
                                                                            85,
                                                                        child: produitsLocaux[index].photo == null ||
                                                                                produitsLocaux[index].photo!.isEmpty
                                                                            ? Image.asset(
                                                                                "assets/images/default_image.png",
                                                                                fit: BoxFit.cover,
                                                                              )
                                                                            : CachedNetworkImage(
                                                                                imageUrl: "https://koumi.ml/api-koumi/Stock/${produitsLocaux[index].idStock}/image",
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
                                                                      title:
                                                                          Text(
                                                                        produitsLocaux[index]
                                                                            .nomProduit!,
                                                                        style:
                                                                            TextStyle(
                                                                          fontSize:
                                                                              16,
                                                                          fontWeight:
                                                                              FontWeight.bold,
                                                                          color:
                                                                              Colors.black87,
                                                                        ),
                                                                        maxLines:
                                                                            2,
                                                                        overflow:
                                                                            TextOverflow.ellipsis,
                                                                      ),
                                                                      subtitle:
                                                                          Text(
                                                                        overflow:
                                                                            TextOverflow.ellipsis,
                                                                        "${produitsLocaux[index].quantiteStock!.toString()} ${produitsLocaux[index].unite!.nomUnite} ",
                                                                        style:
                                                                            TextStyle(
                                                                          overflow:
                                                                              TextOverflow.ellipsis,
                                                                          fontSize:
                                                                              15,
                                                                          fontWeight:
                                                                              FontWeight.bold,
                                                                          color:
                                                                              Colors.black87,
                                                                        ),
                                                                      ),
                                                                    ),
                                                                    Padding(
                                                                      padding: const EdgeInsets
                                                                          .symmetric(
                                                                          horizontal:
                                                                              15),
                                                                      child:
                                                                          Text(
                                                                        produitsLocaux[index].monnaie !=
                                                                                null
                                                                            ? "${produitsLocaux[index].prix.toString()} ${produitsLocaux[index].monnaie!.libelle}"
                                                                            : "${produitsLocaux[index].prix.toString()} FCFA",
                                                                        style:
                                                                            TextStyle(
                                                                          fontSize:
                                                                              15,
                                                                          color:
                                                                              Colors.black87,
                                                                        ),
                                                                      ),
                                                                    ),
                                                                  ],
                                                                ),
                                                              ));
                                                        } else {
                                                          return isLoading ==
                                                                  true
                                                              ? Padding(
                                                                  padding: const EdgeInsets
                                                                      .symmetric(
                                                                      vertical:
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
                                                        mainAxisSpacing: 5,
                                                        crossAxisSpacing: 5,
                                                        childAspectRatio: 0.8,
                                                      ),
                                                      itemCount:
                                                          produitsEtrangers
                                                              .length,
                                                      // itemCount: stockListe.length + (isLoading ? 1 : 0),
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
                                                                    builder:
                                                                        (context) =>
                                                                            DetailProduits(
                                                                      stock: produitsEtrangers[
                                                                          index],
                                                                    ),
                                                                  ),
                                                                );
                                                              },
                                                              child: Card(
                                                                margin:
                                                                    EdgeInsets
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
                                                                          Container(
                                                                        height:
                                                                            85,
                                                                        child: produitsEtrangers[index].photo == null ||
                                                                                produitsEtrangers[index].photo!.isEmpty
                                                                            ? Image.asset(
                                                                                "assets/images/default_image.png",
                                                                                fit: BoxFit.cover,
                                                                              )
                                                                            : CachedNetworkImage(
                                                                                imageUrl: "https://koumi.ml/api-koumi/Stock/${produitsEtrangers[index].idStock}/image",
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
                                                                      title:
                                                                          Text(
                                                                        produitsEtrangers[index]
                                                                            .nomProduit!,
                                                                        style:
                                                                            TextStyle(
                                                                          fontSize:
                                                                              16,
                                                                          fontWeight:
                                                                              FontWeight.bold,
                                                                          color:
                                                                              Colors.black87,
                                                                        ),
                                                                        maxLines:
                                                                            2,
                                                                        overflow:
                                                                            TextOverflow.ellipsis,
                                                                      ),
                                                                      subtitle:
                                                                          Text(
                                                                        overflow:
                                                                            TextOverflow.ellipsis,
                                                                        "${produitsEtrangers[index].quantiteStock!.toString()} ${produitsEtrangers[index].unite!.nomUnite} ",
                                                                        style:
                                                                            TextStyle(
                                                                          overflow:
                                                                              TextOverflow.ellipsis,
                                                                          fontSize:
                                                                              15,
                                                                          fontWeight:
                                                                              FontWeight.bold,
                                                                          color:
                                                                              Colors.black87,
                                                                        ),
                                                                      ),
                                                                    ),
                                                                    Padding(
                                                                      padding: const EdgeInsets
                                                                          .symmetric(
                                                                          horizontal:
                                                                              15),
                                                                      child:
                                                                          Text(
                                                                        produitsEtrangers[index].monnaie !=
                                                                                null
                                                                            ? "${produitsEtrangers[index].prix.toString()} ${produitsEtrangers[index].monnaie!.libelle}"
                                                                            : "${produitsEtrangers[index].prix.toString()} FCFA",
                                                                        style:
                                                                            TextStyle(
                                                                          fontSize:
                                                                              15,
                                                                          color:
                                                                              Colors.black87,
                                                                        ),
                                                                      ),
                                                                    ),
                                                                  ],
                                                                ),
                                                              ));
                                                        } else {
                                                          return isLoading ==
                                                                  true
                                                              ? Padding(
                                                                  padding: const EdgeInsets
                                                                      .symmetric(
                                                                      vertical:
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
      value: typeValue,
      onChanged: (newValue) {
        setState(() {
          typeValue = newValue;
          if (newValue != null) {
            selectedCat = typeList.firstWhere(
              (element) => element.idCategorieProduit == newValue,
            );
          }
          page = 0;
          hasMore = true;
          fetchStockByCategorie(
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
        labelText: '-- Aucun catégorie trouvé --',
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
