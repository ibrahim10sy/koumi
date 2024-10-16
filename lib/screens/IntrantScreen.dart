import 'dart:async';
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
import 'package:provider/provider.dart';
import 'package:search_field_autocomplete/search_field_autocomplete.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shimmer/shimmer.dart';

class IntrantScreen extends StatefulWidget {
  String? detectedCountry;
  IntrantScreen({super.key, this.detectedCountry});

  @override
  State<IntrantScreen> createState() => _IntrantScreenState();
}

const d_colorGreen = Color.fromRGBO(43, 103, 6, 1);
const d_colorOr = Color.fromRGBO(255, 138, 0, 1);

class _IntrantScreenState extends State<IntrantScreen> {
  bool isExist = false;
  late Acteur acteur = Acteur();
  String? email = "";
  late List<TypeActeur> typeActeurData = [];
  late String type;
  late TextEditingController _searchController;

  List<Intrant> intrantListe = [];
  // late FocusNode _focusNode;
  // List<ParametreGeneraux> paraList = [];
  // late ParametreGeneraux para = ParametreGeneraux();
  String? catValue;
  late Future _typeList;
  CategorieProduit? selectedType;
  ScrollController scrollableController = ScrollController();
  ScrollController scrollableController1 = ScrollController();

  bool isSearchMode = false;
  bool isFilterMode = false;
  int page = 0;
  bool isLoading = false;
  int size = sized;
  bool hasMore = true;
  late Future<List<Intrant>> intrantListeFuture;
  late Future<List<Intrant>> intrantListeFuture1;

  bool isLoadingLibelle = true;

  void _scrollListener() {
    if (scrollableController.position.pixels >=
            scrollableController.position.maxScrollExtent - 200 &&
        hasMore &&
        !isLoading &&
        selectedType == null) {
      if (mounted)
        setState(() {
          // Rafraîchir les données ici
          page++;
        });
      debugPrint("yes - fetch all by pays intrants");
      isExist
          ? fetchIntrantByPays(
              widget.detectedCountry != null ? widget.detectedCountry! : "mali")
          : fetchIntrantByPays(acteur.niveau3PaysActeur!);
    }
    debugPrint("no");
  }

  void _scrollListener1() {
    if (scrollableController1.position.pixels >=
            scrollableController1.position.maxScrollExtent - 200 &&
        hasMore &&
        !isLoading &&
        selectedType != null) {
      debugPrint("yes - fetch by category");
      if (mounted)
        setState(() {
          // Rafraîchir les données ici
          page++;
        });

      isExist
          ? fetchIntrantByCategorie(
              widget.detectedCountry != null ? widget.detectedCountry! : "Mali",
              selectedType!.idCategorieProduit!)
          : fetchIntrantByCategorie(
              acteur.niveau3PaysActeur!, selectedType!.idCategorieProduit!);
    }
    debugPrint("no");
  }

  Future<List<Intrant>> fetchIntrantByPays(String niveau3PaysActeur,
      {bool refresh = false}) async {
    if (isLoading) return [];

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
      final response = await http.get(Uri.parse(
          '$apiOnlineUrl/intrant/getIntrantsByPaysWithPagination?niveau3PaysActeur=$niveau3PaysActeur&page=$page&size=$size'));
      debugPrint(
          '$apiOnlineUrl/intrant/getIntrantsByPaysWithPagination?niveau3PaysActeur=$niveau3PaysActeur&page=$page&size=$size');
      if (response.statusCode == 200) {
        print("pays end point $niveau3PaysActeur");
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
            "response body all intrant by pays with pagination $page par défilement soit ${intrantListe.length}");
        return intrantListe;
      } else {
        print(
            'Échec de la requête avec le code d\'état: ${response.statusCode} |  ${response.body}');
        return [];
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

  Future<List<Intrant>> fetchIntrantByCategorie(
      String niveau3PaysActeur, String idCategorieProduit,
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
      final response = await http.get(Uri.parse(
          '$apiOnlineUrl/intrant/getIntrantsByPaysAndCategorieWithPagination?idCategorieProduit=${selectedType!.idCategorieProduit}&niveau3PaysActeur=$niveau3PaysActeur&page=$page&size=$size'));

      if (response.statusCode == 200) {
        print("pays end point by cat $niveau3PaysActeur");
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
        intrantListeFuture = IntrantService().fetchIntrantByPays(
            widget.detectedCountry != null ? widget.detectedCountry! : "mali");
      });
    }
  }

  Future<List<Intrant>> getAllIntrant() async {
    if (selectedType != null) {
      isExist
          ? intrantListe = await IntrantService().fetchIntrantByCategorie(
              selectedType!.idCategorieProduit!,
              widget.detectedCountry != null ? widget.detectedCountry! : "mali")
          : intrantListe = await IntrantService().fetchIntrantByCategorie(
              selectedType!.idCategorieProduit!, acteur.niveau3PaysActeur!);
    }

    return intrantListe;
  }

  @override
  void initState() {
    super.initState();
    verify();
    // _focusNode = FocusNode();
    _searchController = TextEditingController();
    _typeList = http.get(Uri.parse('$apiOnlineUrl/Categorie/allCategorie'));
    WidgetsBinding.instance.addPostFrameCallback((_) {
      //write or call your logic
      //code will run when widget rendering complete
      scrollableController.addListener(_scrollListener);
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      //write or call your logic
      //code will run when widget rendering complete
      scrollableController1.addListener(_scrollListener1);
    });
    isExist == true
        ? intrantListeFuture =
            IntrantService().fetchIntrantByPays(acteur.niveau3PaysActeur!)
        : intrantListeFuture = IntrantService().fetchIntrantByPays(
            widget.detectedCountry != null ? widget.detectedCountry! : "mali");

    intrantListeFuture1 = getAllIntrant();
    // final countryProvider = Provider.of<CountryProvider>(context , listen: false);

    // debugPrint("pays ${countryName!}");

    _searchController = TextEditingController();
    _typeList = http.get(Uri.parse('$apiOnlineUrl/Categorie/allCategorie'));
    WidgetsBinding.instance.addPostFrameCallback((_) {
      //write or call your logic
      //code will run when widget rendering complete
      scrollableController.addListener(_scrollListener);
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      //write or call your logic
      //code will run when widget rendering complete
      scrollableController1.addListener(_scrollListener1);
    });
    intrantListeFuture = IntrantService().fetchIntrantByPays(
        widget.detectedCountry != null ? widget.detectedCountry! : "Mali");
    intrantListeFuture1 = getAllIntrant();
    // final countryProvider = Provider.of<CountryProvider>(context , listen: false);

    debugPrint(
        "pays detecter dans intrant  ${widget.detectedCountry != null ? widget.detectedCountry : "mali"}");
  }

  Future<void> _getResultFromNextScreen1(BuildContext context) async {
    final result = await Navigator.push(
        context, MaterialPageRoute(builder: (context) => AddIntrant()));
    log(result.toString());
    if (result == true) {
      print("Rafraichissement en cours");
      setState(() {
        intrantListeFuture = IntrantService().fetchIntrantByPays(
            widget.detectedCountry != null ? widget.detectedCountry! : "Mali");
      });
    }
  }

  Future<void> _getResultFromNextScreen2(BuildContext context) async {
    final result = await Navigator.push(context,
        MaterialPageRoute(builder: (context) => ListeIntrantByActeur()));
    log(result.toString());
    if (result == true) {
      print("Rafraichissement en cours");
      setState(() {
        intrantListeFuture = IntrantService().fetchIntrantByPays(
            widget.detectedCountry != null ? widget.detectedCountry! : "Mali");
      });
    }
  }

  Future<void> _getResultFromNextScreen3(
      BuildContext context, Intrant? intrant) async {
    final result = await Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => DetailIntrant(
                  intrant: intrant!,
                )));
    log(result.toString());
    if (result == true) {
      print("Rafraichissement en cours");
      setState(() {
        intrantListeFuture = IntrantService().fetchIntrantByPays(
            widget.detectedCountry != null ? widget.detectedCountry! : "Mali");
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
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  String? _searchingWithQuery;

  // The most recent options received from the API.
  late Iterable<String> _lastOptions = <String>[];

  // Searches the options, but injects a fake "network" delay.

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
              "Intrants agricoles ",
              style: TextStyle(
                color: d_colorGreen,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            actions: !isExist
                ? null
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
                              intrantListeFuture = IntrantService()
                                  .fetchIntrantByPays(
                                      widget.detectedCountry! != null
                                          ? widget.detectedCountry!
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
                              intrantListeFuture = IntrantService()
                                  .fetchIntrantByPays(
                                      widget.detectedCountry! != null
                                          ? widget.detectedCountry!
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
                                'Rechercher...',
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
                                  //
                                  // }
                                  if (responseData is List) {
                                    final reponse = responseData;
                                    final typeList = reponse
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
                              itemHeight: 25,
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
                          // Rafraîchir les donnée& a
                          //-+s ici
                        });
                        debugPrint("refresh page ${page}");
                        selectedType == null
                            ? setState(() {
                                isExist
                                    ? intrantListeFuture = IntrantService()
                                        .fetchIntrantByPays(
                                            widget.detectedCountry!)
                                    : intrantListeFuture = IntrantService()
                                        .fetchIntrantByPays(
                                            acteur.niveau3PaysActeur!);
                              })
                            : setState(() {
                                isExist
                                    ? intrantListeFuture1 = IntrantService()
                                        .fetchIntrantByCategorie(
                                            selectedType!.idCategorieProduit!,
                                            widget.detectedCountry!)
                                    : intrantListeFuture1 = IntrantService()
                                        .fetchIntrantByCategorie(
                                            selectedType!.idCategorieProduit!,
                                            acteur.niveau3PaysActeur!);
                              });
                      },
                      child: selectedType == null
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
                                              child:
                                                  Text("Aucun donné trouvé")),
                                        );
                                      } else {
                                        intrantListe = snapshot.data!;
                                        String searchText = "";
                                        List<Intrant> filteredSearch =
                                            intrantListe.where((cate) {
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
                                            : GridView.builder(
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
                                                    filteredSearch.length + 1,
                                                itemBuilder: (context, index) {
                                                  if (index <
                                                      filteredSearch.length) {
                                                    return GestureDetector(
                                                      onTap: () {
                                                        // Navigator.push(
                                                        //   context,
                                                        //   MaterialPageRoute(
                                                        //     builder: (context) =>
                                                        //         DetailIntrant(
                                                        //       intrant:
                                                        //           filteredSearch[
                                                        //               index],
                                                        //     ),
                                                        //   ),
                                                        // );
                                                        _getResultFromNextScreen3(
                                                          context,
                                                          filteredSearch[index],
                                                        );
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
                                                                child: filteredSearch[index].photoIntrant ==
                                                                            null ||
                                                                        filteredSearch[index]
                                                                            .photoIntrant!
                                                                            .isEmpty
                                                                    ? Image
                                                                        .asset(
                                                                        "assets/images/default_image.png",
                                                                        fit: BoxFit
                                                                            .cover,
                                                                      )
                                                                    : CachedNetworkImage(
                                                                        imageUrl:
                                                                            "https://koumi.ml/api-koumi/intrant/${intrantListe[index].idIntrant}/image",
                                                                        fit: BoxFit
                                                                            .cover,
                                                                        placeholder:
                                                                            (context, url) =>
                                                                                const Center(child: CircularProgressIndicator()),
                                                                        errorWidget: (context,
                                                                                url,
                                                                                error) =>
                                                                            Image.asset(
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
                                                                filteredSearch[
                                                                        index]
                                                                    .nomIntrant!,
                                                                style:
                                                                    TextStyle(
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
                                                                "${filteredSearch[index].quantiteIntrant.toString()} ${filteredSearch[index].unite}",
                                                                style:
                                                                    TextStyle(
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
                                                                filteredSearch[index]
                                                                            .monnaie !=
                                                                        null
                                                                    ? "${filteredSearch[index].prixIntrant.toString()} ${filteredSearch[index].monnaie!.libelle}"
                                                                    : "${filteredSearch[index].prixIntrant.toString()} FCFA ",
                                                                style:
                                                                    TextStyle(
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
                                                                color: Colors
                                                                    .orange,
                                                              ),
                                                            )),
                                                          )
                                                        : Container();
                                                  }
                                                },
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
                                        return SingleChildScrollView(
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
                                                          TextOverflow.ellipsis,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        );
                                      } else {
                                        intrantListe = snapshot.data!;
                                        String searchText = "";
                                        List<Intrant> filteredSearch =
                                            intrantListe.where((cate) {
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
                                            : filteredSearch
                                                        .where((element) =>
                                                            element
                                                                .statutIntrant ==
                                                            true)
                                                        .isEmpty &&
                                                    isLoading == true
                                                ? _buildShimmerEffect()
                                                : GridView.builder(
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
                                                    itemCount: filteredSearch
                                                            .where((element) =>
                                                                element
                                                                    .statutIntrant ==
                                                                true)
                                                            .length +
                                                        1,
                                                    itemBuilder:
                                                        (context, index) {
                                                      if (index <
                                                          filteredSearch
                                                              .length) {
                                                        var e = filteredSearch
                                                            .where((element) =>
                                                                element
                                                                    .statutIntrant ==
                                                                true)
                                                            .elementAt(index);
                                                        return GestureDetector(
                                                          onTap: () {
                                                            // Navigator.push(
                                                            //   context,
                                                            //   MaterialPageRoute(
                                                            //     builder: (context) =>
                                                            //         DetailIntrant(
                                                            //       intrant: e,
                                                            //     ),
                                                            //   ),
                                                            // );
                                                            _getResultFromNextScreen3(
                                                              context,
                                                              filteredSearch[
                                                                  index],
                                                            );
                                                          },
                                                          child: Card(
                                                            margin:
                                                                EdgeInsets.all(
                                                                    8),
                                                            // decoration: BoxDecoration(
                                                            //   color: Color.fromARGB(250, 250, 250, 250),
                                                            //   borderRadius: BorderRadius.circular(15),
                                                            //   boxShadow: [
                                                            //     BoxShadow(
                                                            //       color: Colors.grey.withOpacity(0.3),
                                                            //       offset: Offset(0, 2),
                                                            //       blurRadius: 8,
                                                            //       spreadRadius: 2,
                                                            //     ),
                                                            //   ],
                                                            // ),
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
                                                                  child:
                                                                      SizedBox(
                                                                    height: 85,
                                                                    child: e.photoIntrant ==
                                                                                null ||
                                                                            e.photoIntrant!
                                                                                .isEmpty
                                                                        ? Image
                                                                            .asset(
                                                                            "assets/images/default_image.png",
                                                                            fit:
                                                                                BoxFit.cover,
                                                                          )
                                                                        : CachedNetworkImage(
                                                                            imageUrl:
                                                                                "https://koumi.ml/api-koumi/intrant/${e.idIntrant}/image",
                                                                            fit:
                                                                                BoxFit.cover,
                                                                            placeholder: (context, url) =>
                                                                                const Center(child: CircularProgressIndicator()),
                                                                            errorWidget: (context, url, error) =>
                                                                                Image.asset(
                                                                              'assets/images/default_image.png',
                                                                              fit: BoxFit.cover,
                                                                            ),
                                                                          ),
                                                                  ),
                                                                ),
                                                                // SizedBox(height: 8),
                                                                ListTile(
                                                                  title: Text(
                                                                    e.nomIntrant!,
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
                                                                  subtitle:
                                                                      Text(
                                                                    "${e.quantiteIntrant.toString()} ${e.unite}",
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
                                                                    e.monnaie !=
                                                                            null
                                                                        ? "${e.prixIntrant.toString()} ${e.monnaie!.libelle}"
                                                                        : "${e.prixIntrant.toString()} FCFA",
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
      hint: Text("-- Filtre par categorie --"),
      value: catValue,
      onChanged: (newValue) {
        setState(() {
          catValue = newValue;
          if (newValue != null) {
            selectedType = typeList.firstWhere(
              (element) => element.idCategorieProduit == newValue,
            );
          }

          page = 0;
          hasMore = true;
          isExist
              ? fetchIntrantByCategorie(
                  selectedType!.idCategorieProduit!, widget.detectedCountry!,
                  refresh: true)
              : fetchIntrantByCategorie(
                  selectedType!.idCategorieProduit!, acteur.niveau3PaysActeur!,
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
        labelText: '-- Aucun categorie trouvé --',
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
