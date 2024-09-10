import 'dart:convert';
import 'dart:io';

import 'package:email_validator/email_validator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_multi_formatter/formatters/phone_input_formatter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:intl_phone_number_input/intl_phone_number_input.dart';
import 'package:koumi/constants.dart';
import 'package:koumi/models/Niveau3Pays.dart';
import 'package:koumi/models/Pays.dart';
import 'package:koumi/models/TypeActeur.dart';
import 'package:koumi/screens/RegisterEndScreen.dart';
import 'package:koumi/service/BottomNavigationService.dart';
import 'package:koumi/service/TypeActeurService.dart';
import 'package:koumi/widgets/BottomNavigationPage.dart';
import 'package:multi_dropdown/multiselect_dropdown.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:provider/provider.dart';
import 'package:dropdown_plus_plus/dropdown_plus_plus.dart';
import 'package:profile_photo/profile_photo.dart';

class RegisterNextScreen extends StatefulWidget {
  String nomActeur, telephone, whatsAppActeur;
  String pays;
  // late List<TypeActeur> typeActeur;

  RegisterNextScreen(
      {super.key,
      required this.nomActeur,
      required this.whatsAppActeur,
      required this.telephone,
      required this.pays});

  @override
  State<RegisterNextScreen> createState() => _RegisterNextScreenState();
}

const d_colorOr = Color.fromRGBO(255, 138, 0, 1);

class _RegisterNextScreenState extends State<RegisterNextScreen> {
  PhoneCountryData? _initialCountryData;

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  String maillon = "";

  String telephone = "";
  String adresse = "";
  String localisation = "";
  bool _obscureText = true;
  List<String> typeLibelle = [];
  List<TypeActeur> typeActeur = [];

  String? paysValue;
  late Pays monPays;
  late Future _mesPays;
  File? image1;
  String? image1Src;
  String _errorMessage = "";

  // Valeur par défaut
  late PhoneNumber _phoneNumber;

  String email = "";
  TextEditingController emailController = TextEditingController();

  String processedNumber = "";
  String initialCountry = 'ML';
  PhoneNumber number = PhoneNumber(isoCode: 'ML');

  final MultiSelectController _controllerTypeActeur = MultiSelectController();

  final TextEditingController controller = TextEditingController();
  TextEditingController localisationController = TextEditingController();
  TextEditingController maillonController = TextEditingController();
  TextEditingController paysController = TextEditingController();
  TextEditingController adresseController = TextEditingController();
  TextEditingController imageController = TextEditingController();
  TextEditingController typeController = TextEditingController();
  String selectedCountry = "";
  late Future _niveau3List;
  late Future _typeList;
  String niveau3 = '';
  String? n3Value;
  late TextEditingController _searchController;
  Future<void> _getCurrentUserLocation() async {
    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.low);
  }

  void validateEmail(String val) {
    if (val.isEmpty) {
      setState(() {
        _errorMessage = "Email ne doit pas être vide";
      });
    } else if (!EmailValidator.validate(val, true)) {
      setState(() {
        _errorMessage = "Email non valide";
      });
    } else {
      setState(() {
        _errorMessage = "";
      });
    }
  }

  String removePlus(String phoneNumber) {
    if (phoneNumber.startsWith('+')) {
      return phoneNumber.substring(1); // Remove the first character
    } else {
      return phoneNumber; // No change if "+" is not present
    }
  }

  Future<File> saveImagePermanently(String imagePath) async {
    final directory = await getApplicationDocumentsDirectory();
    final name = basename(imagePath);
    final image = File('${directory.path}/$name');

    return File(imagePath).copy(image.path);
  }

  Future<File?> getImage(ImageSource source) async {
    final image = await ImagePicker().pickImage(source: source);
    if (image == null) return null;
    imageController.text = image.name;
    return File(image.path);
  }

  Future<void> _pickImage(ImageSource source) async {
    final image = await getImage(source);
    if (image != null) {
      setState(() {
        this.image1 = image;
        image1Src = image.path;
        imageController.text = image.path;
      });
    }
  }

  Future<void> _showImageSourceDialog() async {
    final BuildContext context = this.context;
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return SizedBox(
          height: 150,
          child: AlertDialog(
            title: Text("Photo de profil"),
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
          ),
        );
      },
    );
  }

  List<TypeActeur> selectedTypes = [];
  List<Niveau3Pays> filteredList = [];
  List<TypeActeur> options = [];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _searchController = TextEditingController();
    // _loadTypeActeurs();
    _niveau3List = http.get(Uri.parse(
        '$apiOnlineUrl/nivveau3Pays/listeNiveau3PaysByNomPays/${widget.pays}'));
    _typeList = http.get(Uri.parse('$apiOnlineUrl/typeActeur/read'));

    debugPrint(
        '$apiOnlineUrl/nivveau3Pays/listeNiveau3PaysByNomPays/${widget.pays}');
    debugPrint(
        "Nom complet : ${widget.nomActeur}, Téléphone : ${widget.telephone},  WA : ${widget.whatsAppActeur}, Pays : ${widget.pays} ");
  }

  // void _loadTypeActeurs() async {
  //   await fetchTypeActeurs();
  //   setState(() {}); // Update UI after fetching data
  // }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _showMultiSelectDialog() {
    final BuildContext context = this.context;
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Sélectionner un type d\'acteur'),
          content: MultiSelectDropDown.network(
            networkConfig: NetworkConfig(
              url: '$apiOnlineUrl/typeActeur/read',
              method: RequestMethod.get,
              headers: {
                'Content-Type': 'application/json',
              },
            ),
            searchEnabled: true,
            searchLabel: 'Rechercher...',
            searchBackgroundColor: Colors.blueGrey[50],
            chipConfig: const ChipConfig(wrapType: WrapType.wrap),
            responseParser: (response) {
              typeActeur = (response as List<dynamic>)
                  .where((data) =>
                      (data['libelle']).trim().toLowerCase() != 'admin')
                  .map((e) {
                return TypeActeur(
                  idTypeActeur: e['idTypeActeur'] as String,
                  libelle: e['libelle'] as String,
                  statutTypeActeur: e['statutTypeActeur'] as bool,
                );
              }).toList();

              // Filtrer les types avec un libellé différent de "admin" et statutTypeActeur true
              final filteredTypes = typeActeur
                  .where((typeActeur) =>
                      typeActeur.libelle != "admin" &&
                      typeActeur.libelle != "Admin" &&
                      typeActeur.statutTypeActeur == true)
                  .toList();

              // Créer des ValueItems pour les types filtrés
              final List<ValueItem<TypeActeur>> valueItems =
                  filteredTypes.map((typeActeur) {
                return ValueItem<TypeActeur>(
                  label: typeActeur.libelle!,
                  value: typeActeur,
                );
              }).toList();

              return Future<List<ValueItem<TypeActeur>>>.value(valueItems);
            },
            controller: _controllerTypeActeur,
            hint: 'Sélectionner un type d\'acteur',
            fieldBackgroundColor: Color.fromARGB(255, 219, 219, 219),
            onOptionSelected: (options) {
              if (mounted) {
                setState(() {
                  typeLibelle.clear();
                  typeLibelle
                      .addAll(options.map((data) => data.label).toList());
                  selectedTypes =
                      options.map<TypeActeur>((item) => item.value!).toList();
                  print("Types sélectionnés : $selectedTypes");
                  print("Libellé sélectionné ${typeLibelle.toString()}");
                });
              }
            },
            responseErrorBuilder: ((context, body) {
              return const Padding(
                padding: EdgeInsets.all(10.0),
                child: Text('Aucun type disponible'),
              );
            }),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Fermer'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
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
    _getCurrentUserLocation(); // Call the function to get location

    Locale deviceLocale = Localizations.localeOf(context);
    String countryCode = deviceLocale.countryCode ?? '';

    setState(() {
      selectedCountry = countryCode.toUpperCase();
    });

    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 250, 250, 250),
      appBar: AppBar(
          leading: IconButton(
            onPressed: () {
              // Fonction de retour
              Navigator.pop(context);
            },
            icon: Icon(
              Icons.arrow_back,
              color: Colors.black,
              size: 30,
            ),
            iconSize: 30,
            splashRadius: 20,
            padding: EdgeInsets.zero,
            constraints: BoxConstraints(minWidth: 40, minHeight: 40),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Get.offAll(BottomNavigationPage(),
                    transition: Transition.leftToRight);
                Provider.of<BottomNavigationService>(context, listen: false)
                    .changeIndex(0);
              },
              child: const Text(
                'Fermer',
                style: TextStyle(color: Colors.orange, fontSize: 17),
              ),
            )
          ]),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment:
                MainAxisAlignment.start, // Alignement vertical en haut
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // SizedBox(
              //   height: 120,
              //   width: double.infinity,
              //   child: GestureDetector(
              //     onTap: _showImageSourceDialog,
              //     child: (image1 == null)
              //         ?
              //         : ClipRRect(
              //             borderRadius: BorderRadius.circular(8),
              //             child: Image.file(
              //               image1!,
              //               height: 100,
              //               width: 200,
              //               fit: BoxFit.cover,
              //             ),
              //           ),
              //   ),
              // ),
              SizedBox(
                  height: 130,
                  width: double.infinity,
                  child:
                      Center(child: Image.asset('assets/images/logo-pr.png'))),
              Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(
                        height: 20,
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 10.0),
                        child: Text(
                          "Type Acteur (Multi-selection)",
                          style: TextStyle(color: (Colors.black), fontSize: 18),
                        ),
                      ),
                      GestureDetector(
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

                      const SizedBox(
                        height: 10,
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 10.0),
                        child: Text(
                          "Email ",
                          style: TextStyle(color: (Colors.black), fontSize: 18),
                        ),
                      ),

                      TextFormField(
                        controller: emailController,
                        decoration: InputDecoration(
                          hintText: "Entrez votre email",
                          contentPadding: const EdgeInsets.symmetric(
                              vertical: 10, horizontal: 20),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        keyboardType: TextInputType.emailAddress,
                        onChanged: (val) {
                          validateEmail(val);
                        },
                        onSaved: (val) => email = val!,
                      ),
                      // fin  adresse email
                      const SizedBox(
                        height: 10,
                      ),

                      Padding(
                        padding: const EdgeInsets.only(left: 10.0),
                        child: Text(
                          "Localité",
                          style: TextStyle(color: (Colors.black), fontSize: 18),
                        ),
                      ),
                      FutureBuilder(
                        future: _niveau3List,
                        builder: (_, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return TextDropdownFormField(
                              options: [],
                              decoration: InputDecoration(
                                  contentPadding: const EdgeInsets.symmetric(
                                      vertical: 10, horizontal: 20),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  suffixIcon: Icon(Icons.search),
                                  labelText: "Chargement..."),
                              cursorColor: Colors.green,
                            );
                          }

                          if (snapshot.hasData) {
                            dynamic jsonString =
                                utf8.decode(snapshot.data.bodyBytes);
                            dynamic responseData = json.decode(jsonString);

                            if (responseData is List) {
                              final reponse = responseData;
                              final niveau3List = reponse
                                  .map((e) => Niveau3Pays.fromMap(e))
                                  .where((con) => con.statutN3 == true)
                                  .toList();
                              if (niveau3List.isEmpty) {
                                return TextDropdownFormField(
                                  options: [],
                                  decoration: InputDecoration(
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                              vertical: 10, horizontal: 20),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      suffixIcon: Icon(Icons.search),
                                      labelText: "Aucune localité trouvé"),
                                  cursorColor: Colors.green,
                                );
                              }

                              return DropdownFormField<Niveau3Pays>(
                                onEmptyActionPressed: (String str) async {},
                                dropdownHeight: 200,
                                decoration: InputDecoration(
                                    contentPadding: const EdgeInsets.symmetric(
                                        vertical: 10, horizontal: 20),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    suffixIcon: Icon(Icons.search),
                                    labelText: "Rechercher une localité"),
                                onSaved: (dynamic n) {
                                  niveau3 = n?.nomN3;
                                  print("onSaved : $niveau3");
                                },
                                onChanged: (dynamic n) {
                                  niveau3 = n?.nomN3;
                                  print("selected : $niveau3");
                                },
                                displayItemFn: (dynamic item) => Text(
                                  item?.nomN3 ?? '',
                                  style: TextStyle(fontSize: 16),
                                ),
                                findFn: (String str) async => niveau3List,
                                selectedFn: (dynamic item1, dynamic item2) {
                                  if (item1 != null && item2 != null) {
                                    return item1.idNiveau3Pays ==
                                        item2.idNiveau3Pays;
                                  }
                                  return false;
                                },
                                filterFn: (dynamic item, String str) => item
                                    .nomN3!
                                    .toLowerCase()
                                    .contains(str.toLowerCase()),
                                dropdownItemFn: (dynamic item,
                                        int position,
                                        bool focused,
                                        bool selected,
                                        Function() onTap) =>
                                    ListTile(
                                  title: Text(item.nomN3!),
                                  tileColor: focused
                                      ? Color.fromARGB(20, 0, 0, 0)
                                      : Colors.transparent,
                                  onTap: onTap,
                                ),
                              );
                            }
                          }
                          return TextDropdownFormField(
                            options: [],
                            decoration: InputDecoration(
                                contentPadding: const EdgeInsets.symmetric(
                                    vertical: 10, horizontal: 20),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                suffixIcon: Icon(Icons.search),
                                labelText: "Aucune localité trouvé"),
                            cursorColor: Colors.green,
                          );
                        },
                      ),

                      const SizedBox(
                        height: 10,
                      ),

                      Padding(
                        padding: const EdgeInsets.only(left: 10.0),
                        child: Text(
                          "Adresse  *",
                          style: TextStyle(color: (Colors.black), fontSize: 18),
                        ),
                      ),
                      TextFormField(
                        controller: adresseController,
                        decoration: InputDecoration(
                          hintText: "Entrez votre adresse de residence",
                          contentPadding: const EdgeInsets.symmetric(
                              vertical: 10, horizontal: 20),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        keyboardType: TextInputType.text,
                        validator: (val) {
                          if (val == null || val.isEmpty) {
                            return "Veillez entrez votre adresse de residence";
                          } else {
                            return null;
                          }
                        },
                        onSaved: (val) => adresse = val!,
                      ),
                      // const SizedBox(
                      //   height: 10,
                      // ),
                      // Padding(
                      //   padding: const EdgeInsets.only(left: 10.0),
                      //   child: Text(
                      //     "Photo de profil (optionnel)",
                      //     style: TextStyle(color: (Colors.black), fontSize: 18),
                      //   ),
                      // ),
                      // TextFormField(
                      //   controller: imageController,
                      //   onTap: _showImageSourceDialog,
                      //   readOnly: true,
                      //   decoration: InputDecoration(
                      //     hintText: "Télécharger une image",
                      //     contentPadding: const EdgeInsets.symmetric(
                      //         vertical: 10, horizontal: 20),
                      //     border: OutlineInputBorder(
                      //       borderRadius: BorderRadius.circular(8),
                      //     ),
                      //     prefixIcon: Icon(Icons.upload),
                      //     // Show clear button when an image is selected
                      //     suffixIcon: imageController.text.isNotEmpty
                      //         ? IconButton(
                      //             icon: Icon(Icons.clear),
                      //             onPressed: () {
                      //               setState(() {
                      //                 imageController.clear();
                      //                 image1 = null;
                      //               });
                      //             },
                      //           )
                      //         : null,
                      //   ),
                      // ),
                      const SizedBox(
                        height: 20,
                      ),
                      Center(
                        child: ElevatedButton(
                          onPressed: () {
                            // Handle button press action here
                            if (_formKey.currentState!.validate()) {
                              if (niveau3.isEmpty) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                        "Veuillez sélectionner une localité"),
                                    duration: Duration(seconds: 5),
                                  ),
                                );
                              } else {
                                // Vérifier si au moins un type d'acteur est sélectionné
                                if (selectedTypes.isNotEmpty) {
                                  // Naviguer vers l'écran suivant en passant les types d'acteurs sélectionnés
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              RegisterEndScreen(
                                                nomActeur: widget.nomActeur,
                                                email: emailController.text,
                                                telephoneActeur:
                                                    widget.telephone,
                                                adresse: adresseController.text,
                                                numeroWhatsApp:
                                                    widget.whatsAppActeur,
                                                localistaion: niveau3,
                                                pays: widget.pays,
                                                typeActeur: selectedTypes,
                                              )));
                                } else {
                                  // Afficher un message indiquant que l'utilisateur doit sélectionner au moins un type d'acteur
                                  ScaffoldMessenger.of(context)
                                      .showSnackBar(SnackBar(
                                    content: Text(
                                        'Veuillez sélectionner au moins un type d\'acteur.'),
                                  ));
                                }
                              }
                            }
                          },
                          child: Text(
                            " Suivant ",
                            style: TextStyle(
                              fontSize: 20,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                const Color(0xFFFF8A00), // Orange color code
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                            minimumSize: Size(250, 40),
                          ),
                        ),
                      ),
                    ],
                  )),
            ],
          ),
        ),
      ),
    );
  }
}
