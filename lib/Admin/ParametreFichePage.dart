import 'package:flutter/material.dart';
import 'package:koumi/Admin/AddParametre.dart';
import 'package:koumi/Admin/DetailParametre.dart';
import 'package:koumi/models/ParametreFiche.dart';
import 'package:koumi/service/ParametreFicheService.dart';
import 'package:provider/provider.dart';

class ParametreFichePage extends StatefulWidget {
  const ParametreFichePage({super.key});

  @override
  State<ParametreFichePage> createState() => _ParametreFichePageState();
}

const d_colorGreen = Color.fromRGBO(43, 103, 6, 1);
const d_colorOr = Color.fromRGBO(255, 138, 0, 1);

class _ParametreFichePageState extends State<ParametreFichePage> {
  late TextEditingController _searchController;
  List<ParametreFiche> paramList = [];
  late Future<List<ParametreFiche>> _listeFuture;

  Future<List<ParametreFiche>> getParamListe() async {
    return await ParametreFicheService().fetchParametre();
  }

  @override
  void initState() {
    super.initState();
    _actualiserListe();
    _searchController = TextEditingController();
  }

  void _actualiserListe() {
    setState(() {
      _listeFuture = getParamListe();
    });
  }

  @override
  void dispose() {
    _searchController
        .dispose(); // Disposez le TextEditingController lorsque vous n'en avez plus besoin
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
              Navigator.of(context).pop();
            },
            icon: const Icon(Icons.arrow_back_ios, color: d_colorGreen)),
        title: Text(
          "Parametre fiche donné",
          style: TextStyle(
              color: d_colorGreen,
              fontWeight: FontWeight.bold,
              overflow: TextOverflow.ellipsis),
        ),
        actions: [
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
                    "Ajouter Paramètre",
                    style: TextStyle(
                      color: Colors.green,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  onTap: () async {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => AddParametre()));
                  },
                ),
              ),
            ],
          )
        ],
      ),
      body: SingleChildScrollView(
        child: Column(children: [
          const SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 10),
              decoration: BoxDecoration(
                color: Colors.blueGrey[50], // Couleur d'arrière-plan
                borderRadius: BorderRadius.circular(25),
              ),
              child: Row(
                children: [
                  Icon(Icons.search,
                      color: Colors.blueGrey[400]), // Couleur de l'icône
                  SizedBox(
                      width:
                          10), // Espacement entre l'icône et le champ de recherche
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      onChanged: (value) {
                        setState(() {});
                      },
                      decoration: InputDecoration(
                        hintText: 'Rechercher',
                        border: InputBorder.none,
                        hintStyle: TextStyle(
                            color: Colors
                                .blueGrey[400]), // Couleur du texte d'aide
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 10),
          Consumer<ParametreFicheService>(
            builder: (context, parServcie, child) {
              return FutureBuilder(
                  future: _listeFuture,
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
                      paramList = snapshot.data!;
                      String searchText = "";
                      List<ParametreFiche> filtereSearch =
                          paramList.where((search) {
                        String libelle = search.libelleParametre.toLowerCase();
                        searchText = _searchController.text.toLowerCase();
                        return libelle.contains(searchText);
                      }).toList();
                      return Column(
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
                                                  DetailParametre(
                                                      parametreFiche: e)));
                                    },
                                    child: Container(
                                      width: MediaQuery.of(context).size.width *
                                          0.9,
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(15),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.grey.withOpacity(0.2),
                                            offset: const Offset(0, 2),
                                            blurRadius: 5,
                                            spreadRadius: 2,
                                          ),
                                        ],
                                      ),
                                      child: Column(
                                        children: [
                                          ListTile(
                                            contentPadding: EdgeInsets.all(16),
                                            title: Text(
                                              e.libelleParametre.toUpperCase(),
                                              style: TextStyle(
                                                color: Colors.black,
                                                fontSize: 18,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            subtitle: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceBetween,
                                                  children: [
                                                    Text('Type de donnée ',
                                                        style: TextStyle(
                                                          color: Colors.black87,
                                                          fontSize: 17,
                                                          fontWeight:
                                                              FontWeight.w500,
                                                          fontStyle:
                                                              FontStyle.italic,
                                                        )),
                                                    Text(
                                                      e.typeDonneeParametre
                                                          .toString(),
                                                      style: TextStyle(
                                                        color: Colors.black,
                                                        fontSize: 18,
                                                      ),
                                                    )
                                                  ],
                                                ),
                                                SizedBox(height: 4),
                                                Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceBetween,
                                                  children: [
                                                    Text('Valeur max: ',
                                                        style: TextStyle(
                                                          color: Colors.black87,
                                                          fontSize: 17,
                                                          fontWeight:
                                                              FontWeight.w500,
                                                          fontStyle:
                                                              FontStyle.italic,
                                                        )),
                                                    Text(
                                                      e.valeurMax.toString(),
                                                      style: TextStyle(
                                                        color: Colors.black,
                                                        fontSize: 18,
                                                      ),
                                                    )
                                                  ],
                                                ),
                                                // if (e.valeurObligatoire == 1)
                                                Row(
                                                  children: [
                                                    Icon(
                                                      Icons.warning,
                                                      color: Colors.red,
                                                      size: 20,
                                                    ),
                                                    SizedBox(width: 5),
                                                    Text(
                                                      'Paramètre obligatoire',
                                                      style: TextStyle(
                                                          color: Colors.red,
                                                          fontSize: 17,
                                                          overflow: TextOverflow
                                                              .ellipsis),
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          ),
                                          Container(
                                            alignment: Alignment.bottomRight,
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 15),
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                _buildEtat(e.statutParametre),
                                                PopupMenuButton<String>(
                                                  padding: EdgeInsets.zero,
                                                  itemBuilder: (context) =>
                                                      <PopupMenuEntry<String>>[
                                                    PopupMenuItem<String>(
                                                      child: ListTile(
                                                        leading: const Icon(
                                                          Icons.check,
                                                          color: Colors.green,
                                                        ),
                                                        title: const Text(
                                                          "Activer",
                                                          style: TextStyle(
                                                            color: Colors.green,
                                                            fontWeight:
                                                                FontWeight.bold,
                                                          ),
                                                        ),
                                                        onTap: () async {
                                                          await ParametreFicheService()
                                                              .activerParametre(e
                                                                  .idParametreFiche)
                                                              .then((value) => {
                                                                    Provider.of<ParametreFicheService>(
                                                                            context,
                                                                            listen:
                                                                                false)
                                                                        .applyChange(),
                                                                    Navigator.of(
                                                                            context)
                                                                        .pop(),
                                                                    setState(
                                                                        () {
                                                                      _listeFuture =
                                                                          getParamListe();
                                                                    }),
                                                                    ScaffoldMessenger.of(
                                                                            context)
                                                                        .showSnackBar(
                                                                      const SnackBar(
                                                                        content:
                                                                            Row(
                                                                          children: [
                                                                            Text("Activer avec succèss "),
                                                                          ],
                                                                        ),
                                                                        duration:
                                                                            Duration(seconds: 2),
                                                                      ),
                                                                    )
                                                                  })
                                                              .catchError(
                                                                  (onError) => {
                                                                        ScaffoldMessenger.of(context)
                                                                            .showSnackBar(
                                                                          const SnackBar(
                                                                            content:
                                                                                Row(
                                                                              children: [
                                                                                Text("Une erreur s'est produit"),
                                                                              ],
                                                                            ),
                                                                            duration:
                                                                                Duration(seconds: 5),
                                                                          ),
                                                                        ),
                                                                        Navigator.of(context)
                                                                            .pop(),
                                                                      });
                                                        },
                                                      ),
                                                    ),
                                                    PopupMenuItem<String>(
                                                      child: ListTile(
                                                        leading: Icon(
                                                          Icons
                                                              .disabled_visible,
                                                          color: Colors
                                                              .orange[400],
                                                        ),
                                                        title: Text(
                                                          "Désactiver",
                                                          style: TextStyle(
                                                            color: Colors
                                                                .orange[400],
                                                            fontWeight:
                                                                FontWeight.bold,
                                                          ),
                                                        ),
                                                        onTap: () async {
                                                          await ParametreFicheService()
                                                              .desactiverParametre(e
                                                                  .idParametreFiche)
                                                              .then((value) => {
                                                                    Provider.of<ParametreFicheService>(
                                                                            context,
                                                                            listen:
                                                                                false)
                                                                        .applyChange(),
                                                                    setState(
                                                                        () {
                                                                      _listeFuture =
                                                                          getParamListe();
                                                                    }),
                                                                    Navigator.of(
                                                                            context)
                                                                        .pop(),
                                                                  })
                                                              .catchError(
                                                                  (onError) => {
                                                                        ScaffoldMessenger.of(context)
                                                                            .showSnackBar(
                                                                          const SnackBar(
                                                                            content:
                                                                                Row(
                                                                              children: [
                                                                                Text("Une erreur s'est produit"),
                                                                              ],
                                                                            ),
                                                                            duration:
                                                                                Duration(seconds: 5),
                                                                          ),
                                                                        ),
                                                                        Navigator.of(context)
                                                                            .pop(),
                                                                      });

                                                          ScaffoldMessenger.of(
                                                                  context)
                                                              .showSnackBar(
                                                            const SnackBar(
                                                              content: Row(
                                                                children: [
                                                                  Text(
                                                                      "Désactiver avec succèss "),
                                                                ],
                                                              ),
                                                              duration:
                                                                  Duration(
                                                                      seconds:
                                                                          2),
                                                            ),
                                                          );
                                                        },
                                                      ),
                                                    ),
                                                    PopupMenuItem<String>(
                                                      child: ListTile(
                                                        leading: const Icon(
                                                          Icons.delete,
                                                          color: Colors.red,
                                                        ),
                                                        title: const Text(
                                                          "Supprimer",
                                                          style: TextStyle(
                                                            color: Colors.red,
                                                            fontWeight:
                                                                FontWeight.bold,
                                                          ),
                                                        ),
                                                        onTap: () async {
                                                          await ParametreFicheService()
                                                              .deleteParametre(e
                                                                  .idParametreFiche)
                                                              .then((value) => {
                                                                    Provider.of<ParametreFicheService>(
                                                                            context,
                                                                            listen:
                                                                                false)
                                                                        .applyChange(),
                                                                    setState(
                                                                        () {
                                                                      _listeFuture =
                                                                          getParamListe();
                                                                    }),
                                                                    ScaffoldMessenger.of(
                                                                            context)
                                                                        .showSnackBar(
                                                                      const SnackBar(
                                                                        content:
                                                                            Row(
                                                                          children: [
                                                                            Text("Supprimer avec sussèss"),
                                                                          ],
                                                                        ),
                                                                        duration:
                                                                            Duration(seconds: 2),
                                                                      ),
                                                                    ),
                                                                    Navigator.of(
                                                                            context)
                                                                        .pop(),
                                                                  })
                                                              .catchError(
                                                                  (onError) => {
                                                                        ScaffoldMessenger.of(context)
                                                                            .showSnackBar(
                                                                          const SnackBar(
                                                                            content:
                                                                                Row(
                                                                              children: [
                                                                                Text("Impossible de supprimer"),
                                                                              ],
                                                                            ),
                                                                            duration:
                                                                                Duration(seconds: 2),
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
                                  ),
                                ))
                            .toList(),
                      );
                    }
                  });
            },
          )
        ]),
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

  void _showDialog() {}
}
