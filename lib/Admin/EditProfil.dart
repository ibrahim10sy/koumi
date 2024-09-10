import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:koumi/constants.dart';
import 'package:koumi/models/Acteur.dart';
import 'package:koumi/models/Speculation.dart';
import 'package:koumi/models/TypeActeur.dart';
import 'package:koumi/providers/ActeurProvider.dart';
import 'package:koumi/service/ActeurService.dart';
import 'package:koumi/widgets/LoadingOverlay.dart';
import 'package:multi_dropdown/multiselect_dropdown.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:profile_photo/profile_photo.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class EditProfil extends StatefulWidget {
  // Acteur? acteurs;
  EditProfil({super.key});

  @override
  State<EditProfil> createState() => _EditProfilState();
}

const d_colorGreen = Color.fromRGBO(43, 103, 6, 1);
const d_colorOr = Color.fromRGBO(255, 138, 0, 1);
const d_colorPage = Color.fromRGBO(255, 255, 255, 1);

class _EditProfilState extends State<EditProfil> {
  TextEditingController nomActeurController = TextEditingController();
  TextEditingController whatsAppController = TextEditingController();
  TextEditingController telephoneActeurController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController localisationController = TextEditingController();
  TextEditingController adresseController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController confirmPasswordController = TextEditingController();
  MultiSelectController _controllerTypeActeur = MultiSelectController();
  late TextEditingController _searchController;
  TextEditingController typeSController = TextEditingController();
  TextEditingController typeController = TextEditingController();

  MultiSelectController _controllerSpeculation = MultiSelectController();
  List<TypeActeur> typeActeur = [];
  final _tokenTextController = TextEditingController();
  List<Speculation> optionS = [];
  bool isEditing = false;
  bool _isLoading = false;
  bool _obscureText = true;
  Acteur? acteur;
  String? imageSrc;
  String? id;
  File? photo;
  late List<TypeActeur> typeActeurData = [];
  late String type;
  List<TypeActeur> selectedTypes = [];
  List<Speculation> selectedSpec = [];
  List<String> specu = [];
  List<String> typeLibelle = [];
  List<String> libelleSpeculation = [];
  List<Speculation> listeSpeculations = [];
  late Future _typeListe;
  late Future _typeList;

  Future<File> saveImagePermanently(String imagePath) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final name = path.basename(imagePath);
      final image = File('${directory.path}/$name');
      return File(imagePath).copy(image.path);
    } catch (e) {
      // Gérer l'exception
      print('Erreur lors de la sauvegarde de l\'image : $e');
      rethrow;
    }
  }

  Future<File?> getImage(ImageSource source) async {
    try {
      final image = await ImagePicker().pickImage(source: source);
      if (image == null) return null;
      return File(image.path);
    } catch (e) {
      // Gérer l'exception
      print('Erreur lors de la sélection de l\'image : $e');
      return null;
    }
  }

  Future<void> _pickImage(ImageSource source) async {
    final image = await getImage(source);
    if (image != null) {
      setState(() {
        photo = image;
        imageSrc = image.path;
      });
      await saveImagePermanently(image.path);
    }
  }

  Future<void> _showImageSourceDialog() async {
    final BuildContext context = this.context;
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Photo d'identité"),
          content: Wrap(
            alignment: WrapAlignment.center,
            children: [
              GestureDetector(
                onTap: () {
                  Navigator.pop(context); // Fermer le dialogue
                  _pickImage(ImageSource.camera);
                },
                child: Column(
                  children: [
                    Icon(Icons.camera_alt, size: 40),
                    Text('Camera'),
                  ],
                ),
              ),
              const SizedBox(width: 40),
              GestureDetector(
                onTap: () {
                  Navigator.pop(context); // Fermer le dialogue
                  _pickImage(ImageSource.gallery);
                },
                child: Column(
                  children: [
                    Icon(Icons.image, size: 40),
                    Text('Galerie photo'),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // Méthode pour récupérer les données depuis SharedPreferences
  Future<void> retrieveData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    // Récupérer les chaînes JSON depuis SharedPreferences
    String? typeActeurJson = prefs.getString('typeActeurList');
    String? speculationsJson = prefs.getString('speculationsList');

    // Vérifier si les données sont présentes
    if (typeActeurJson != null && speculationsJson != null) {
      // Décoder les JSON pour obtenir des listes de Map
      List<dynamic> typeActeurData = json.decode(typeActeurJson);
      List<dynamic> speculationData = json.decode(speculationsJson);

      // Convertir chaque élément en instance de TypeActeur et Speculation
      List<TypeActeur> liste1 =
          typeActeurData.map((data) => TypeActeur.fromMap(data)).toList();
      print("share Type acteur ${liste1.toString()}");

      List<Speculation> liste2 =
          speculationData.map((data) => Speculation.fromMap(data)).toList();
      print("share speculation acteur ${liste2.toString()}");
      selectedSpec = liste2;
      libelleSpeculation = selectedSpec.map((e) => e.nomSpeculation!).toList();
      typeSController.text = libelleSpeculation.map((e) => e).join(',');
      print("speculation acteur selected Spec share: ${selectedSpec}");

      selectedTypes = liste1;
      typeLibelle = selectedTypes.map((e) => e.libelle!).toList();
      typeController.text = typeLibelle.map((e) => e).join(',');
      print("type acteur selected Types share : ${selectedTypes}");
      print("type libelle share: ${typeLibelle}");
      // Utilisez typeActeurList et speculationsList comme nécessaire
    } else {
      print("Aucune donnée trouvée pour TypeActeur et Speculation");
    }
  }

  @override
  void initState() {
    super.initState();
    // acteur = widget.acteurs!;
    acteur = Provider.of<ActeurProvider>(context, listen: false).acteur!;
    id = acteur!.idActeur!;
    debugPrint("init  id $id ${acteur.toString()}");
    nomActeurController.text = acteur!.nomActeur!;
    whatsAppController.text = acteur!.whatsAppActeur!;
    telephoneActeurController.text = acteur!.telephoneActeur!;
    localisationController.text = acteur!.localiteActeur!;
    adresseController.text = acteur!.adresseActeur!;

    if (acteur!.emailActeur != null) {
      emailController.text = acteur!.emailActeur!;
      print("email : ${acteur!.emailActeur}");
    }

    _searchController = TextEditingController();
    _typeListe =
        http.get(Uri.parse('$apiOnlineUrl/Speculation/getAllSpeculation'));
    _typeList = http.get(Uri.parse('$apiOnlineUrl/typeActeur/read'));

    print("niveau 3 : ${acteur!.niveau3PaysActeur!}");

    retrieveData();
  }

  @override
  void dispose() {
    _controllerTypeActeur.dispose();
    _controllerSpeculation.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _showMultiSelectDialogS() async {
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
                    hintText: 'Rechercher une spéculation...',
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
                future: _typeListe,
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
                      List<Speculation> typeListe = responseData
                          .map((e) => Speculation.fromMap(e))
                          .where((con) => con.statutSpeculation == true)
                          .toList();

                      if (typeListe.isEmpty) {
                        return const Padding(
                          padding: EdgeInsets.all(10),
                          child: Center(child: Text("Aucun type trouvé")),
                        );
                      }

                      String searchText = _searchController.text.toLowerCase();
                      List<Speculation> filteredSearch = typeListe
                          .where((type) => type.nomSpeculation!
                              .toLowerCase()
                              .contains(searchText))
                          .toList();

                      return filteredSearch.isEmpty
                          ? const Text(
                              'Aucune spéculation trouvé',
                              style:
                                  TextStyle(color: Colors.black, fontSize: 17),
                            )
                          : SizedBox(
                              width: double.maxFinite,
                              child: ListView.builder(
                                itemCount: filteredSearch.length,
                                itemBuilder: (context, index) {
                                  final type = filteredSearch[index];
                                  final isSelected =
                                      selectedSpec.contains(type);

                                  return ListTile(
                                    title: Text(
                                      type.nomSpeculation!,
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
                                            ? selectedSpec.remove(type)
                                            : selectedSpec.add(type);
                                      });
                                    },
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
                    List<String> typeLibelle =
                        selectedSpec.map((e) => e.nomSpeculation!).toList();
                    typeSController.text = typeLibelle.join(', ');
                    _searchController.clear();
                    print('Options sélectionnées : $selectedSpec');
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
                    hintText: 'Rechercher un type...',
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
                                  final typeActeur = filteredSearch[index];
                                  final isSelected =
                                      selectedTypes.contains(typeActeur);

                                  return ListTile(
                                    title: Text(
                                      typeActeur.libelle!,
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
                                            ? selectedTypes.remove(typeActeur)
                                            : selectedTypes.add(typeActeur);
                                      });
                                    },
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
                    List<String> typeLibelle =
                        selectedTypes.map((e) => e.libelle!).toList();
                    typeController.text = typeLibelle.join(', ');
                    _searchController.clear();
                    print('Options sélectionnées : $selectedTypes');
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

  @override
  Widget build(BuildContext context) {
    return LoadingOverlay(
      isLoading: _isLoading,
      child: Scaffold(
        backgroundColor: const Color.fromARGB(255, 250, 250, 250),
        appBar: AppBar(
          backgroundColor: d_colorOr,
          centerTitle: true,
          toolbarHeight: 75,
          leading: IconButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          ),
          title: const Text(
            "Modifier le Profil",
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ),
        body: SingleChildScrollView(
          child: Column(
            children: [
              Row(
                children: [
                  SizedBox(width: 15),
                  SizedBox(height: 10),
                  photo != null
                      ? Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: SizedBox(
                            height: 100,
                            width: 100,
                            child: Image.file(
                              photo!,
                              height: 100,
                              width: 200,
                              fit: BoxFit.cover,
                            ),
                          ))
                      : Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: acteur!.logoActeur == null ||
                                  acteur!.logoActeur!.isEmpty
                              ? ProfilePhoto(
                                  totalWidth: 100,
                                  cornerRadius: 100,
                                  color: Colors.black,
                                  image: const AssetImage(
                                      'assets/images/profil.jpg'),
                                )
                              : ProfilePhoto(
                                  totalWidth: 100,
                                  cornerRadius: 100,
                                  color: Colors.black,
                                  image: NetworkImage(
                                      "https://koumi.ml/api-koumi/acteur/${acteur!.idActeur}/image"),
                                ),
                        ),
                  TextButton(
                      onPressed: () {
                        _showImageSourceDialog();
                      },
                      // onHover : true,
                      child: Text(
                        "Changer le logo",
                        style: TextStyle(
                            fontSize: 18,
                            color: d_colorOr,
                            fontWeight: FontWeight.w900),
                      ))
                ],
              ),
              SizedBox(
                height: 20,
              ),
              Padding(
                padding: const EdgeInsets.all(10.0),
                child: TextFormField(
                  controller: nomActeurController,
                  decoration: InputDecoration(
                    labelText: "Nom complet",
                    contentPadding: const EdgeInsets.symmetric(
                        vertical: 10, horizontal: 20),
                    // hintText: "Entrez votre prenom et nom",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  keyboardType: TextInputType.text,
                  validator: (val) {
                    if (val == null || val.isEmpty) {
                      return "Veillez entrez votre prenom et nom";
                    } else {
                      return null;
                    }
                  },
                ),
              ),
              SizedBox(
                height: 5,
              ),
              Padding(
                padding: const EdgeInsets.all(10.0),
                child: GestureDetector(
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
              ),
              SizedBox(
                height: 5,
              ),
              Padding(
                padding: const EdgeInsets.all(10.0),
                child: GestureDetector(
                  onTap: _showMultiSelectDialogS,
                  child: TextFormField(
                    onTap: _showMultiSelectDialogS,
                    controller: typeSController,
                    decoration: InputDecoration(
                      suffixIcon: Icon(Icons.arrow_drop_down,
                          color: Colors.blueGrey[400]),
                      hintText: "Sélectionner une spéculation ",
                      contentPadding: const EdgeInsets.symmetric(
                          vertical: 10, horizontal: 20),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(
                height: 5,
              ),
              Padding(
                padding: const EdgeInsets.all(10.0),
                child: TextFormField(
                  controller: emailController,
                  decoration: InputDecoration(
                    labelText: "Email",
                    contentPadding: const EdgeInsets.symmetric(
                        vertical: 10, horizontal: 20),
                    // hintText: "Entrez votre prenom et nom",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  keyboardType: TextInputType.text,
                  validator: (val) {
                    if (val == null || val.isEmpty) {
                      return "Veillez entrez votre prenom et nom";
                    } else {
                      return null;
                    }
                  },
                  // onSaved: (val) => nomActeur = val!,
                ),
              ),
              SizedBox(
                height: 5,
              ),
              Padding(
                padding: const EdgeInsets.all(10.0),
                child: TextFormField(
                  controller: whatsAppController,
                  decoration: InputDecoration(
                    labelText: "Numéro wathsApp",
                    contentPadding: const EdgeInsets.symmetric(
                        vertical: 10, horizontal: 20),
                    // hintText: "Entrez votre prenom et nom",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  keyboardType: TextInputType.text,
                  validator: (val) {
                    if (val == null || val.isEmpty) {
                      return "Veillez entrez votre prenom et nom";
                    } else {
                      return null;
                    }
                  },
                  // onSaved: (val) => nomActeur = val!,
                ),
              ),
              SizedBox(
                height: 5,
              ),
              Padding(
                padding: const EdgeInsets.all(10.0),
                child: TextFormField(
                  controller: telephoneActeurController,
                  decoration: InputDecoration(
                    labelText: "Numéro",
                    contentPadding: const EdgeInsets.symmetric(
                        vertical: 10, horizontal: 20),
                    // hintText: "Entrez votre prenom et nom",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  keyboardType: TextInputType.text,
                  validator: (val) {
                    if (val == null || val.isEmpty) {
                      return "Veillez entrez votre prenom et nom";
                    } else {
                      return null;
                    }
                  },
                  // onSaved: (val) => nomActeur = val!,
                ),
              ),
              SizedBox(
                height: 5,
              ),
              Padding(
                padding: const EdgeInsets.all(10.0),
                child: TextFormField(
                  controller: localisationController,
                  decoration: InputDecoration(
                    labelText: "Localité",
                    contentPadding: const EdgeInsets.symmetric(
                        vertical: 10, horizontal: 20),
                    // hintText: "Entrez votre prenom et nom",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  keyboardType: TextInputType.text,
                  validator: (val) {
                    if (val == null || val.isEmpty) {
                      return "Veillez entrez votre prenom et nom";
                    } else {
                      return null;
                    }
                  },
                  // onSaved: (val) => nomActeur = val!,
                ),
              ),
              SizedBox(
                height: 5,
              ),
              Padding(
                padding: const EdgeInsets.all(10.0),
                child: TextFormField(
                  controller: adresseController,
                  decoration: InputDecoration(
                    labelText: "Adresse",
                    contentPadding: const EdgeInsets.symmetric(
                        vertical: 10, horizontal: 20),
                    // hintText: "Entrez votre prenom et nom",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  keyboardType: TextInputType.text,
                  validator: (val) {
                    if (val == null || val.isEmpty) {
                      return "Veillez entrez votre prenom et nom";
                    } else {
                      return null;
                    }
                  },
                  // onSaved: (val) => nomActeur = val!,
                ),
              ),
              SizedBox(
                height: 10,
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: ElevatedButton(
                  onPressed: () async {
                    final idActeur = acteur?.idActeur;
                    final nomActeur = nomActeurController.text;
                    final emailActeur = emailController.text;
                    final adresse = adresseController.text;
                    final localisation = localisationController.text;
                    final typeActeur = selectedTypes;
                    final speculation = selectedSpec;
                    final whatsApp = whatsAppController.text;
                    final tel = telephoneActeurController.text;
                    final niveau3PaysActeur = acteur?.niveau3PaysActeur;

                    print("Spec envoie  : ${selectedSpec}");
                    print("Type envoie  : ${selectedTypes}");
                    debugPrint(
                      "acteur edit  nom: $nomActeur, email: $emailActeur, adresse: $adresse, loc: $localisation, type: ${typeActeur.toList()}, speculation: ${speculation.toList()}, wa: $whatsApp, tel: $tel, emailActeur: $emailActeur, pays: $niveau3PaysActeur",
                    );
                    Acteur a = Acteur();
                    a = Provider.of<ActeurProvider>(context, listen: false)
                        .acteur!;
                    typeActeurData = a.typeActeur!;
                    print("acteur pro  : ${typeActeurData}");

                    if (idActeur == null || idActeur.isEmpty) {
                      debugPrint("ID est null ou vide");

                      return;
                    }

                    try {
                      setState(() {
                        _isLoading = true;
                      });

                      final response = await ActeurService().updateActeur(
                        context: context,
                        idActeur: idActeur,
                        nomActeur: nomActeur,
                        adresseActeur: adresse,
                        telephoneActeur: tel,
                        whatsAppActeur: whatsApp,
                        localiteActeur: localisation,
                        emailActeur: emailActeur,
                        niveau3PaysActeur: niveau3PaysActeur,
                        typeActeur: selectedTypes,
                        speculation: selectedSpec,
                        logoActeur: photo,
                      );

                      debugPrint("profil modifier avec succèss");

                      setState(() {
                        _isLoading = false;
                      });

                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("Profil modifié avec succès"),
                          duration: Duration(seconds: 5),
                        ),
                      );
                    } catch (e) {
                      debugPrint(
                          "Erreur lors de la mise à jour de l'acteur: ${e.toString()}");

                      setState(() {
                        _isLoading = false;
                      });

                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("Une erreur s'est produite"),
                          duration: Duration(seconds: 5),
                        ),
                      );
                    } finally {
                      setState(() {
                        _isLoading = false;
                      });
                    }
                  },
                  child: Text(
                    "Modifier",
                    style: TextStyle(
                      fontSize: 20,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        const Color(0xFFFF8A00), // Code couleur orange
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    minimumSize: Size(250, 40),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
