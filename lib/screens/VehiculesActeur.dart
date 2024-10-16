import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:koumi/constants.dart';
import 'package:koumi/models/Acteur.dart';
import 'package:koumi/models/TypeActeur.dart';
import 'package:koumi/models/Vehicule.dart';
import 'package:koumi/providers/ActeurProvider.dart';
import 'package:koumi/screens/AddVehicule.dart';
import 'package:koumi/screens/DetailTransport.dart';
import 'package:koumi/service/VehiculeService.dart';
import 'package:koumi/widgets/AutoComptet.dart';
import 'package:provider/provider.dart';
import 'package:search_field_autocomplete/search_field_autocomplete.dart';
import 'package:shimmer/shimmer.dart';

class VehiculeActeur extends StatefulWidget {
  const VehiculeActeur({super.key});

  @override
  State<VehiculeActeur> createState() => _VehiculeActeurState();
}

const d_colorGreen = Color.fromRGBO(43, 103, 6, 1);
const d_colorOr = Color.fromRGBO(255, 138, 0, 1);

class _VehiculeActeurState extends State<VehiculeActeur> {
  late Acteur acteur;
  late List<TypeActeur> typeActeurData = [];
  late String type;
  late TextEditingController _searchController;
  List<Vehicule> vehiculeListe = [];
  late Future<List<Vehicule>> _liste;

  // late Future liste;

  Future<List<Vehicule>> getVehicule(String id) async {
    final response = await VehiculeService().fetchVehiculeByActeur(id);

    return response;
  }

  ScrollController scrollableController = ScrollController();

  int page = 0;
  bool isLoading = false;
  int size = sized;
  bool hasMore = true;

  void _scrollListener() {
    // if (selectedCat != null &&  scrollableController1.position.pixels >=
    //         scrollableController1.position.maxScrollExtent - 200 &&
    //     hasMore &&
    //     !isLoading ) {
    //   // if (selectedCat != null) {
    //     // Incrementez la page et récupérez les stocks par catégorie
    //     debugPrint("yes - fetch by category");
    //     setState(() {
    //         // Rafraîchir les données ici
    //     page++;
    //    fetchStockByCategorie(selectedCat!.idCategorieProduit!);
    //       });
    //   }
    if (scrollableController.position.pixels >=
            scrollableController.position.maxScrollExtent - 200 &&
        hasMore &&
        !isLoading) {
      // Incrementez la page et récupérez les stocks généraux
      debugPrint("yes - fetch vehicule by acteur");
      setState(() {
        // Rafraîchir les données ici
        page++;
      });
      fetchVehiculeByActeur(acteur.idActeur!).then((value) {
        setState(() {
          // Rafraîchir les données ici
        });
      });
      // }
      // }
      // else {
    }
    debugPrint("no");
  }

  Future<List<Vehicule>> fetchVehiculeByActeur(String idActeur,
      {bool refresh = false}) async {
    // if (_stockService.isLoading == true) return [];

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
          '$apiOnlineUrl/vehicule/getAllVehiculesByActeurWithPagination?idActeur=$idActeur&page=${page}&size=${size}'));

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
            "response body all vehicule by acteur with pagination ${page} par défilement soit ${vehiculeListe.length}");
      } else {
        print(
            'Échec de la requête avec le code d\'état: ${response.statusCode} |  ${response.body}');
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

  @override
  void initState() {
    acteur = Provider.of<ActeurProvider>(context, listen: false).acteur!;
    typeActeurData = acteur.typeActeur!;
    type = typeActeurData.map((data) => data.libelle).join(', ');
    _searchController = TextEditingController();
    _liste = VehiculeService().fetchVehiculeByActeur(acteur.idActeur!);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      //write or call your logic
      //code will run when widget rendering complete
      scrollableController.addListener(_scrollListener);
    });
    super.initState();
  }

  bool isSearchMode = false;
  void _selectMode(String mode) {
    setState(() {
      if (mode == 'Rechercher') {
        isSearchMode = true;
      } else if (mode == 'Fermer') {
        isSearchMode = false;
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    scrollableController.dispose();
    super.dispose();
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
                  Navigator.pop(context, true);
                },
                icon: const Icon(Icons.arrow_back_ios, color: d_colorGreen)),
            title: Text(
              'Mes véhicules',
              style: const TextStyle(
                  color: d_colorGreen,
                  fontWeight: FontWeight.bold,
                  fontSize: 20),
            ),
            actions: [
              IconButton(
                  onPressed: () {
                    setState(() {
                      page = 0;
                      // Rafraîchir les données ici
                      _liste = VehiculeService()
                          .fetchVehiculeByActeur(acteur.idActeur!);
                    });
                  },
                  icon: const Icon(Icons.refresh, color: d_colorGreen)),
              PopupMenuButton<String>(
                padding: EdgeInsets.zero,
                itemBuilder: (context) => <PopupMenuEntry<String>>[
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
                            fontSize: 18),
                      ),
                      onTap: () async {
                        Navigator.of(context).pop();
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => AddVehicule()));
                      },
                    ),
                  ),
                ],
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
                  // Rafraîchir les données ici
                  _liste =
                      VehiculeService().fetchVehiculeByActeur(acteur.idActeur!);
                });
                debugPrint("refresh page ${page}");
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
                                      setState(() {
                                        isSearchMode = false;
                                        _searchController.clear();
                                      });
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
                                padding: const EdgeInsets.all(10.0),
                                child: SearchFieldAutoComplete<String>(
                                  controller: _searchController,
                                  itemHeight: 25,
                                  placeholder: 'Rechercher...',
                                  placeholderStyle:
                                      TextStyle(fontStyle: FontStyle.italic),
                                  suggestions: AutoComplet.getTransportVehicles,
                                  suggestionsDecoration: SuggestionDecoration(
                                    marginSuggestions: const EdgeInsets.all(8.0),
                                    color:
                                        const Color.fromARGB(255, 236, 234, 234),
                                    borderRadius: BorderRadius.circular(16.0),
                                  ),
                                  onSuggestionSelected: (selectedItem) {
                                    _searchController.text =
                                        selectedItem.searchKey;
                                    // setState(() {});
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
                          ])),
                        ];
                      },
                      body: RefreshIndicator(
                          onRefresh: () async {
                            setState(() {
                              page = 0;
                              // Rafraîchir les données ici
                              _liste = VehiculeService()
                                  .fetchVehiculeByActeur(acteur.idActeur!);
                            });
                            debugPrint("refresh page ${page}");
                          },
                          child: SingleChildScrollView(
                              controller: scrollableController,
                              child: Consumer<VehiculeService>(
                                  builder: (context, vehiculeService, child) {
                                return FutureBuilder(
                                    future: _liste,
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
                                        List<Vehicule> filtereSearch =
                                            vehiculeListe.where((search) {
                                          String libelle =
                                              search.nomVehicule.toLowerCase();
                                          searchText = _searchController.text
                                              .toLowerCase();
                                          return libelle.contains(searchText);
                                        }).toList();
                                        return vehiculeListe.isEmpty
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
                                                          'Aucune vehiucle trouvé',
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
                                                    filtereSearch.length + 1,
                                                itemBuilder: (context, index) {
                                                  if (index <
                                                      filtereSearch.length) {
                                                    return GestureDetector(
                                                      onTap: () {
                                                        Navigator.push(
                                                            context,
                                                            MaterialPageRoute(
                                                                builder: (context) =>
                                                                    DetailTransport(
                                                                        vehicule:
                                                                            filtereSearch[
                                                                                index])));
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
                                                                height: 72,
                                                                child: filtereSearch[index]
                                                                                .photoVehicule ==
                                                                            null ||
                                                                        filtereSearch[
                                                                                index]
                                                                            .photoVehicule!
                                                                            .isEmpty
                                                                    ? Image.asset(
                                                                        "assets/images/default_image.png",
                                                                        fit: BoxFit
                                                                            .cover,
                                                                      )
                                                                    : CachedNetworkImage(
                                                                        imageUrl:
                                                                            "https://koumi.ml/api-koumi/vehicule/${filtereSearch[index].idVehicule}/image",
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
                                                                filtereSearch[
                                                                        index]
                                                                    .nomVehicule,
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
                                                                filtereSearch[
                                                                        index]
                                                                    .localisation,
                                                                style: TextStyle(
                                                                  overflow:
                                                                      TextOverflow
                                                                          .ellipsis,
                                                                  fontSize: 15,
                                                                  color: Colors
                                                                      .black87,
                                                                ),
                                                              ),
                                                            ),
                                                            Container(
                                                              alignment: Alignment
                                                                  .bottomRight,
                                                              padding:
                                                                  const EdgeInsets
                                                                      .symmetric(
                                                                      horizontal:
                                                                          10),
                                                              child: Row(
                                                                mainAxisAlignment:
                                                                    MainAxisAlignment
                                                                        .spaceBetween,
                                                                children: [
                                                                  _buildEtat(
                                                                      filtereSearch[
                                                                              index]
                                                                          .statutVehicule),
                                                                  PopupMenuButton<
                                                                      String>(
                                                                    padding:
                                                                        EdgeInsets
                                                                            .zero,
                                                                    itemBuilder:
                                                                        (context) =>
                                                                            <PopupMenuEntry<
                                                                                String>>[
                                                                      PopupMenuItem<
                                                                          String>(
                                                                        child:
                                                                            ListTile(
                                                                          leading: filtereSearch[index].statutVehicule ==
                                                                                  false
                                                                              ? Icon(
                                                                                  Icons.check,
                                                                                  color: Colors.green,
                                                                                )
                                                                              : Icon(
                                                                                  Icons.disabled_visible,
                                                                                  color: Colors.orange[400],
                                                                                ),
                                                                          title:
                                                                              Text(
                                                                            filtereSearch[index].statutVehicule == false
                                                                                ? "Activer"
                                                                                : "Desactiver",
                                                                            style:
                                                                                TextStyle(
                                                                              color: filtereSearch[index].statutVehicule == false
                                                                                  ? Colors.green
                                                                                  : Colors.orange[400],
                                                                              fontWeight:
                                                                                  FontWeight.bold,
                                                                            ),
                                                                          ),
                                                                          onTap:
                                                                              () async {
                                                                            filtereSearch[index].statutVehicule == false
                                                                                ? await VehiculeService()
                                                                                    .activerVehicules(filtereSearch[index].idVehicule)
                                                                                    .then((value) => {
                                                                                          Provider.of<VehiculeService>(context, listen: false).applyChange(),
                                                                                          setState(() {
                                                                                            page++;
                                                                                            _liste = VehiculeService().fetchVehiculeByActeur(acteur.idActeur!);
                                                                                          }),
                                                                                          Navigator.of(context).pop(),
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
                                                                                    .catchError((onError) => {
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
                                                                                : await VehiculeService()
                                                                                    .desactiverVehicules(filtereSearch[index].idVehicule)
                                                                                    .then((value) => {
                                                                                          Provider.of<VehiculeService>(context, listen: false).applyChange(),
                                                                                          setState(() {
                                                                                            page++;
                                                                                            _liste = VehiculeService().fetchVehiculeByActeur(acteur.idActeur!);
                                                                                          }),
                                                                                          ScaffoldMessenger.of(context).showSnackBar(
                                                                                            const SnackBar(
                                                                                              content: Row(
                                                                                                children: [
                                                                                                  Text("Désactiver avec succèss "),
                                                                                                ],
                                                                                              ),
                                                                                              duration: Duration(seconds: 2),
                                                                                            ),
                                                                                          ),
                                                                                          Navigator.of(context).pop(),
                                                                                        })
                                                                                    .catchError((onError) => {
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
                                                                          },
                                                                        ),
                                                                      ),
                                                                      PopupMenuItem<
                                                                          String>(
                                                                        child:
                                                                            ListTile(
                                                                          leading:
                                                                              const Icon(
                                                                            Icons
                                                                                .delete,
                                                                            color:
                                                                                Colors.red,
                                                                          ),
                                                                          title:
                                                                              const Text(
                                                                            "Supprimer",
                                                                            style:
                                                                                TextStyle(
                                                                              color:
                                                                                  Colors.red,
                                                                              fontWeight:
                                                                                  FontWeight.bold,
                                                                            ),
                                                                          ),
                                                                          onTap:
                                                                              () async {
                                                                            await VehiculeService()
                                                                                .deleteVehicule(filtereSearch[index].idVehicule)
                                                                                .then((value) => {
                                                                                      Provider.of<VehiculeService>(context, listen: false).applyChange(),
                                                                                      setState(() {
                                                                                        page++;
                                                                                        _liste = VehiculeService().fetchVehiculeByActeur(acteur.idActeur!);
                                                                                      }),
                                                                                      Navigator.of(context).pop(),
                                                                                    })
                                                                                .catchError((onError) => {
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
                                              );
                                      }
                                    });
                              })))))),
        ));
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
                fontSize: 18),
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
}

/*


*/
