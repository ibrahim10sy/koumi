import 'package:flutter/material.dart';
import 'package:koumi/models/Acteur.dart';
import 'package:koumi/models/Superficie.dart';
import 'package:koumi/providers/ActeurProvider.dart';
import 'package:koumi/screens/AddSuperficie.dart';
import 'package:koumi/screens/DetailSuperficie.dart';
import 'package:koumi/service/SuperficieService.dart';
import 'package:provider/provider.dart';

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

  late Future<List<Superficie>> _liste;

  Future<List<Superficie>> getCampListe(String id) async {
    final response = await SuperficieService().fetchSuperficieByActeur(id);
    return response;
  }

  @override
  void initState() {
    _searchController = TextEditingController();
    acteur = Provider.of<ActeurProvider>(context, listen: false).acteur!;
    _liste = getCampListe(acteur.idActeur!);
    super.initState();
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
        title: const Text(
          "Superficie cultiver",
          style: TextStyle(color: d_colorGreen, fontWeight: FontWeight.bold,fontSize:20),
        ),
        actions: [
          IconButton(
              onPressed: () {
                setState(() {
                  _liste = getCampListe(acteur.idActeur!);
                });
              },
              icon: Icon(Icons.refresh)),
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
                    "Superficie cultiver",
                    style: TextStyle(
                        color: Colors.green,
                        fontWeight: FontWeight.bold,
                        overflow: TextOverflow.ellipsis),
                  ),
                  onTap: () async {
                    Navigator.of(context).pop();
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => AddSuperficie()));
                  },
                ),
              ),
            ],
          )
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
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
                            child: Center(child: Text("Aucune donné trouvé")),
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
                                                    e.localite!.toUpperCase(),
                                                    style: const TextStyle(
                                                      color: Colors.black,
                                                      fontSize: 20,
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                    )),
                                                subtitle: Text(e.superficieHa!,
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
                                              alignment: Alignment.bottomRight,
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 10),
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  _buildEtat(
                                                      e.statutSuperficie),
                                                  PopupMenuButton<String>(
                                                    padding: EdgeInsets.zero,
                                                    itemBuilder: (context) =>
                                                        <PopupMenuEntry<
                                                            String>>[
                                                      PopupMenuItem<String>(
                                                        child: ListTile(
                                                          leading:  e
                                                                  .statutSuperficie == false
                                                              ? Icon(
                                                                  Icons.check,
                                                                  color: Colors
                                                                      .green,
                                                                )
                                                              : Icon(
                                                                  Icons
                                                                      .disabled_visible,
                                                                  color: Colors
                                                                          .orange[
                                                                      400],
                                                                ),
                                                          title:  Text(
                                                             e
                                                                  .statutSuperficie == false
                                                              
                                                             ? "Activer"
                                                                        : "Desactiver",
                                                                    style:
                                                                        TextStyle(
                                                                      color: e.statutSuperficie ==
                                                                              false
                                                                          ? Colors
                                                                              .green
                                                                          : Colors
                                                                              .orange[400],
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                            ),
                                                          ),
                                                          onTap: () async {
                                                             e.statutSuperficie ==
                                                                              false
                                                                          ?
                                                            await SuperficieService()
                                                                .activerSuperficie(e
                                                                    .idSuperficie!)
                                                                .then(
                                                                    (value) => {
                                                                          Provider.of<SuperficieService>(context, listen: false)
                                                                              .applyChange(),
                                                                          Navigator.of(context)
                                                                              .pop(),
                                                                          setState(
                                                                              () {
                                                                            _liste =
                                                                                getCampListe(acteur.idActeur!);
                                                                          }),
                                                                          ScaffoldMessenger.of(context)
                                                                              .showSnackBar(
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
                                                                          ScaffoldMessenger.of(context)
                                                                              .showSnackBar(
                                                                            const SnackBar(
                                                                              content: Row(
                                                                                children: [
                                                                                  Text("Une erreur s'est produit"),
                                                                                ],
                                                                              ),
                                                                              duration: Duration(seconds: 5),
                                                                            ),
                                                                          ),
                                                                          Navigator.of(context)
                                                                              .pop(),
                                                                        }):  await SuperficieService()
                                                                    .desactiverSuperficie(e
                                                                        .idSuperficie!)
                                                                    .then(
                                                                        (value) =>
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
                                                                            });

                                                            ScaffoldMessenger
                                                                    .of(context)
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
                                                            Icons.edit,
                                                            color: Colors.green,
                                                          ),
                                                          title: const Text(
                                                            "Modifier",
                                                            style: TextStyle(
                                                              color:
                                                                  Colors.green,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                            ),
                                                          ),
                                                          onTap: () async {},
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
                                                                  FontWeight
                                                                      .bold,
                                                            ),
                                                          ),
                                                          onTap: () async {
                                                            await SuperficieService()
                                                                .deleteSuperficie(e
                                                                    .idSuperficie!)
                                                                .then(
                                                                    (value) => {
                                                                          Provider.of<SuperficieService>(context, listen: false)
                                                                              .applyChange(),
                                                                          Navigator.of(context)
                                                                              .pop(),
                                                                        })
                                                                .catchError(
                                                                    (onError) =>
                                                                        {
                                                                          ScaffoldMessenger.of(context)
                                                                              .showSnackBar(
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
