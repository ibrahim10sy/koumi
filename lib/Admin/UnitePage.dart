import 'package:flutter/material.dart';
import 'package:koumi/Admin/UpdateUnite.dart';
import 'package:koumi/models/Acteur.dart';
import 'package:koumi/models/Unite.dart';
import 'package:koumi/providers/ActeurProvider.dart';
import 'package:koumi/service/UniteService.dart';
import 'package:provider/provider.dart';

class UnitePage extends StatefulWidget {
  const UnitePage({super.key});

  @override
  State<UnitePage> createState() => _UnitePageState();
}

const d_colorGreen = Color.fromRGBO(43, 103, 6, 1);
const d_colorOr = Color.fromRGBO(255, 138, 0, 1);

class _UnitePageState extends State<UnitePage> {
  List<Unite> uniteList = [];
  late Acteur acteur;
  final formkey = GlobalKey<FormState>();
  TextEditingController libelleController = TextEditingController();
  TextEditingController sigleController = TextEditingController();
  TextEditingController descController = TextEditingController();
  late TextEditingController _searchController;

  @override
  void initState() {
    acteur = Provider.of<ActeurProvider>(context, listen: false).acteur!;
    _searchController = TextEditingController();

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
          "Unité de mesure",
          style: TextStyle(
              color: d_colorGreen, fontWeight: FontWeight.bold, fontSize: 20),
        ),
        actions: [
          PopupMenuButton<String>(
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
                      "Unité de mesure",
                      style: TextStyle(
                        color: Colors.green,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    onTap: () async {
                      Navigator.of(context).pop();
                      _showBottomSheet();
                    },
                  ),
                ),
              ];
            },
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
            Consumer<UniteService>(
              builder: (context, typeService, child) {
                return FutureBuilder(
                    future: typeService.fetchUnite(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Center(
                          child: CircularProgressIndicator(
                            color: Colors.orange,
                          ),
                        );
                      }

                      if (!snapshot.hasData) {
                        return const Padding(
                          padding: EdgeInsets.all(10),
                          child: Center(child: Text("Aucun unité trouvé")),
                        );
                      } else {
                        uniteList = snapshot.data!;
                        String searchText = "";
                        List<Unite> filtereSearch = uniteList.where((search) {
                          String libelle = search.sigleUnite!.toLowerCase();
                          searchText = _searchController.text.toLowerCase();
                          return libelle.contains(searchText);
                        }).toList();
                        return Column(
                            children: filtereSearch
                                .map((e) => Padding(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 10, horizontal: 15),
                                      child: Container(
                                        width:
                                            MediaQuery.of(context).size.width *
                                                0.9,
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius:
                                              BorderRadius.circular(15),
                                          boxShadow: [
                                            BoxShadow(
                                              color:
                                                  Colors.grey.withOpacity(0.2),
                                              offset: const Offset(0, 2),
                                              blurRadius: 5,
                                              spreadRadius: 2,
                                            ),
                                          ],
                                        ),
                                        child: Column(
                                          children: [
                                            ListTile(
                                                title: Text(
                                                    e.sigleUnite!.toUpperCase(),
                                                    style: const TextStyle(
                                                      color: Colors.black,
                                                      fontSize: 20,
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                    )),
                                                subtitle:
                                                    Text(e.description!.trim(),
                                                        style: const TextStyle(
                                                          color: Colors.black87,
                                                          fontSize: 17,
                                                          fontWeight:
                                                              FontWeight.w500,
                                                          fontStyle:
                                                              FontStyle.italic,
                                                        ))),
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
                                                  _buildEtat(e.statutUnite!),
                                                  PopupMenuButton<String>(
                                                    padding: EdgeInsets.zero,
                                                    itemBuilder: (context) =>
                                                        <PopupMenuEntry<
                                                            String>>[
                                                      PopupMenuItem<String>(
                                                        child: ListTile(
                                                          leading:
                                                              e.statutUnite ==
                                                                      false
                                                                  ? Icon(
                                                                      Icons
                                                                          .check,
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
                                                          title: Text(
                                                            e.statutUnite ==
                                                                    false
                                                                ? "Activer"
                                                                : "Desactiver",
                                                            style: TextStyle(
                                                              color: e.statutUnite ==
                                                                      false
                                                                  ? Colors.green
                                                                  : Colors.orange[
                                                                      400],
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                            ),
                                                          ),
                                                          onTap: () async {
                                                            e.statutUnite ==
                                                                    false
                                                                ? await UniteService()
                                                                    .activerUnite(e
                                                                        .idUnite!)
                                                                    .then(
                                                                        (value) =>
                                                                            {
                                                                              Provider.of<UniteService>(context, listen: false).applyChange(),
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
                                                                    .catchError(
                                                                        (onError) =>
                                                                            {
                                                                              ScaffoldMessenger.of(context).showSnackBar(
                                                                                SnackBar(
                                                                                  content: Row(
                                                                                    children: [
                                                                                      Text("Une erreur s'est produit : $onError"),
                                                                                    ],
                                                                                  ),
                                                                                  duration: const Duration(seconds: 5),
                                                                                ),
                                                                              ),
                                                                              Navigator.of(context).pop(),
                                                                            })
                                                                : await UniteService()
                                                                    .desactiverUnite(e
                                                                        .idUnite!)
                                                                    .then(
                                                                        (value) =>
                                                                            {
                                                                              Provider.of<UniteService>(context, listen: false).applyChange(),
                                                                              Navigator.of(context).pop(),
                                                                            })
                                                                    .catchError(
                                                                        (onError) =>
                                                                            {
                                                                              ScaffoldMessenger.of(context).showSnackBar(
                                                                                SnackBar(
                                                                                  content: Row(
                                                                                    children: [
                                                                                      Text("Une erreur s'est produit : $onError"),
                                                                                    ],
                                                                                  ),
                                                                                  duration: const Duration(seconds: 5),
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
                                                                        " Desactiver avec succèss "),
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
                                                          onTap: () {
                                                            Navigator.of(
                                                                    context)
                                                                .pop();
                                                            bottomUpdatesheet(
                                                                context, e);
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
                                                                  FontWeight
                                                                      .bold,
                                                            ),
                                                          ),
                                                          onTap: () async {
                                                            await UniteService()
                                                                .deleteUnite(
                                                                    e.idUnite!)
                                                                .then(
                                                                    (value) => {
                                                                          Provider.of<UniteService>(context, listen: false)
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
                                                                                  Text("Ce type d'acteur est déjà associer à un acteur"),
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
                                    ))
                                .toList());
                      }
                    });
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<dynamic> bottomUpdatesheet(BuildContext context, Unite? unite) async {
    return await showModalBottomSheet<int>(
      context: context,
      builder: (BuildContext context) {
        return SingleChildScrollView(
          child: Container(
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.5),
                    spreadRadius: 3,
                    blurRadius: 7,
                    offset: Offset(0, 3),
                  ),
                ],
              ),
              child: UpdateUnite(unite: unite!)),
        );
      },
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

  void _showBottomSheet() {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      isScrollControlled: true,
      builder: (BuildContext context) {
        return Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
              left: 16,
              right: 16,
              top: 16,
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Ajouter une unité ",
                        maxLines: 2,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                          fontSize: 18,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        child: Text("Fermer",
                            style: TextStyle(color: Colors.red, fontSize: 18)),
                      )
                    ],
                  ),
                  const SizedBox(height: 5),
                  Form(
                    key: formkey,
                    child: Column(
                      children: [
                        const SizedBox(
                          height: 10,
                        ),
                        TextFormField(
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return "Veuillez remplir les champs";
                            }
                            return null;
                          },
                          controller: libelleController,
                          decoration: InputDecoration(
                            hintText: "Nom unité",
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        TextFormField(
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return "Veuillez remplir les champs";
                            }
                            return null;
                          },
                          controller: sigleController,
                          decoration: InputDecoration(
                            hintText: "Sigle unité",
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        TextFormField(
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return "Veuillez remplir les champs";
                            }
                            return null;
                          },
                          controller: descController,
                          maxLines: null,
                          decoration: InputDecoration(
                            labelText: "Description",
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        ElevatedButton.icon(
                          onPressed: () async {
                            final String libelle = libelleController.text;
                            final String sigle = sigleController.text;
                            final String description = descController.text;
                            if (formkey.currentState!.validate()) {
                              try {
                                await UniteService()
                                    .addUnite(
                                        nomUnite: libelle,
                                        sigleUnite: sigle,
                                        description: description,
                                        acteur: acteur)
                                    .then((value) => {
                                          Provider.of<UniteService>(context,
                                                  listen: false)
                                              .applyChange(),
                                          libelleController.clear(),
                                          descController.clear(),
                                          sigleController.clear(),
                                          Navigator.of(context).pop()
                                        });
                              } catch (e) {
                                final String errorMessage = e.toString();
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Row(
                                      children: [
                                        Text(
                                            "Une erreur s'est produit : $errorMessage"),
                                      ],
                                    ),
                                    duration: const Duration(seconds: 5),
                                  ),
                                );
                              }
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green, // Orange color code
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                            minimumSize: const Size(290, 45),
                          ),
                          icon: const Icon(
                            Icons.add,
                            color: Colors.white,
                          ),
                          label: const Text(
                            "Ajouter",
                            style: TextStyle(
                              fontSize: 20,
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                  )
                ],
              ),
            ));
      },
    );
  }
}
