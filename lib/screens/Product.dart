// import 'dart:convert';

// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;
// import 'package:koumi_app/constants.dart';
// import 'package:koumi_app/models/Acteur.dart';
// import 'package:koumi_app/models/CategorieProduit.dart';
// import 'package:koumi_app/models/ParametreGeneraux.dart';
// import 'package:koumi_app/models/Stock.dart';
// import 'package:koumi_app/models/TypeActeur.dart';
// import 'package:koumi_app/providers/ActeurProvider.dart';
// import 'package:koumi_app/providers/ParametreGenerauxProvider.dart';
// import 'package:koumi_app/screens/AddAndUpdateProductScreen.dart';
// import 'package:koumi_app/screens/DetailProduits.dart';
// import 'package:koumi_app/screens/MyProduct.dart';
// import 'package:koumi_app/service/StockService.dart';
// import 'package:provider/provider.dart';
// import 'package:cached_network_image/cached_network_image.dart';

// import 'package:shared_preferences/shared_preferences.dart';

// class ProductScreen extends StatefulWidget {
//   String? id, nom;
//   ProductScreen({super.key, this.id, this.nom});

//   @override
//   State<ProductScreen> createState() => _ProductScreenState();
// }

// const d_colorGreen = Color.fromRGBO(43, 103, 6, 1);
// const d_colorOr = Color.fromRGBO(255, 138, 0, 1);
// const d_colorPage = Color.fromRGBO(255, 255, 255, 1);

// class _ProductScreenState extends State<ProductScreen> {
//   late Acteur acteur = Acteur();
//   late List<TypeActeur> typeActeurData = [];
//   List<ParametreGeneraux> paraList = [];
//   late ParametreGeneraux para = ParametreGeneraux();
//   late String type;
//   late TextEditingController _searchController;
//   List<Stock> stockListe = [];
//   late Future<List<Stock>> stockListeFuture;
//   late Future<List<Stock>> stockListeFuture1;
//   CategorieProduit? selectedCat;
//   String? typeValue;
//   late Future _catList;
//   bool isExist = false;
//   String? email = "";

//   void verify() async {
//     SharedPreferences prefs = await SharedPreferences.getInstance();
//     email = prefs.getString('emailActeur');
//     if (email != null) {
//       // Si l'email de l'acteur est présent, exécute checkLoggedIn
//       acteur = Provider.of<ActeurProvider>(context, listen: false).acteur!;
//       typeActeurData = acteur.typeActeur!;
//       type = typeActeurData.map((data) => data.libelle).join(', ');
//       setState(() {
//         isExist = true;
//       });
//     } else {
//       setState(() {
//         isExist = false;
//       });
//     }
//   }

//   Future<List<Stock>> getAllStock() async {
//     if(widget.id != null) {
//       stockListe = await StockService().fetchStockByMagasinWithPagination(widget.id!);
    
//     }
//      else if (selectedCat != null && widget.id != null) {
//       stockListe = await StockService().fetchStockByCategorieAndMagasinWithPagination(
//           selectedCat!.idCategorieProduit!, widget.id!);
//     }
//     // else{
//     //   stockListe = await StockService().fetchStock();
//     // }
    
//     return stockListe;
//   }

//   Future<List<Stock>> getAllStocks() async {
//      if (selectedCat != null) {
//       stockListe = await StockService()
//           .fetchStockByCategorieWithPagination(selectedCat!.idCategorieProduit!);
//     }
//       // stockListe = await StockService().fetchStock();
//     return stockListe;
//   }

  

//   void verifyParam() {
//     paraList = Provider.of<ParametreGenerauxProvider>(context, listen: false)
//         .parametreList!;

//     if (paraList.isNotEmpty) {
//       para = paraList[0];
//     } else {
//       // Gérer le cas où la liste est null ou vide, par exemple :
//       // Afficher un message d'erreur, initialiser 'para' à une valeur par défaut, etc.
//     }
//   }

//   @override
//   void initState() {
//     // acteur = Provider.of<ActeurProvider>(context, listen: false).acteur!;
//     // typeActeurData = acteur.typeActeur!;
//     // // selectedType == null;
//     // type = typeActeurData.map((data) => data.libelle).join(', ');
//     super.initState();
//     verify();
//     _searchController = TextEditingController();
//     _catList = http
//         .get(Uri.parse('$apiOnlineUrl/Categorie/allCategorie'));
//     // updateStockList();
//     stockListeFuture = getAllStock();
//     // stockListeFuture1 = getAllStocks();
//     stockListeFuture1 = getAllStocks();
  
//   }

//   @override
//   void dispose() {
//     _searchController
//         .dispose(); // Disposez le TextEditingController lorsque vous n'en avez plus besoin
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//           backgroundColor: const Color.fromARGB(255, 250, 250, 250),
//           centerTitle: true,
//           toolbarHeight: 100,
//           // leading: IconButton(
//           //     onPressed: () {
//           //       Navigator.of(context).pop();
//           //     },
//           //     icon: const Icon(Icons.arrow_back_ios, color: d_colorGreen)),
//           title: Text(
//             'Tous les Produit',
//             style: const TextStyle(
//                 color: d_colorGreen, fontWeight: FontWeight.bold),
//           ),
//           actions: !isExist
//               ? null
//               :
            
//              [
//   (typeActeurData
//           .map((e) => e.libelle!.toLowerCase())
//           .contains("commercant") ||
//       typeActeurData
//           .map((e) => e.libelle!.toLowerCase())
//           .contains("admin") ||
//       typeActeurData
//           .map((e) => e.libelle!.toLowerCase())
//           .contains("producteur"))
//       ? PopupMenuButton<String>(
//           padding: EdgeInsets.zero,
//           itemBuilder: (context) {
//             return <PopupMenuEntry<String>>[
//               PopupMenuItem<String>(
//                 child: ListTile(
//                   leading: const Icon(
//                     Icons.add,
//                     color: Colors.green,
//                   ),
//                   title: const Text(
//                     "Ajouter produit",
//                     style: TextStyle(
//                       color: Colors.green,
//                       fontWeight: FontWeight.bold,
//                     ),
//                   ),
//                   onTap: () async {
//                     Navigator.of(context).pop();
//                     Navigator.push(
//                       context,
//                       MaterialPageRoute(
//                         builder: (context) => AddAndUpdateProductScreen(
//                           isEditable: false,
//                         ),
//                       ),
//                     );
//                   },
//                 ),
//               ),
//               PopupMenuItem<String>(
//                 child: ListTile(
//                   leading: const Icon(
//                     Icons.remove_red_eye,
//                     color: Colors.green,
//                   ),
//                   title: const Text(
//                     "Mes produits",
//                     style: TextStyle(
//                       color: Colors.green,
//                       fontWeight: FontWeight.bold,
//                     ),
//                   ),
//                   onTap: () async {
//                     Navigator.of(context).pop();
//                     Navigator.push(
//                       context,
//                       MaterialPageRoute(
//                         builder: (context) => MyProductScreen(),
//                       ),
//                     );
//                   },
//                 ),
//               ),
//             ];
//           },
//         )
//       : PopupMenuButton<String>(
//           padding: EdgeInsets.zero,
//           itemBuilder: (context) {
//             return <PopupMenuEntry<String>>[
//               PopupMenuItem<String>(
//                 child: ListTile(
//                   leading: const Icon(
//                     Icons.remove_red_eye,
//                     color: Colors.green,
//                   ),
//                   title: const Text(
//                     "Mes produits",
//                     style: TextStyle(
//                       color: Colors.green,
//                       fontWeight: FontWeight.bold,
//                     ),
//                   ),
//                   onTap: () async {
//                     Navigator.of(context).pop();
//                     Navigator.push(
//                       context,
//                       MaterialPageRoute(
//                         builder: (context) => MyProductScreen(),
//                       ),
//                     );
//                   },
//                 ),
//               ),
//             ];
//           },
//         ),
// ]

                
//                 ),
//       body: SingleChildScrollView(
//         child: Column(children: [
//           const SizedBox(height: 10),

//           // const SizedBox(height: 10),
//           Padding(
//             padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
//             child: FutureBuilder(
//               future: _catList,
//               builder: (_, snapshot) {
//                 if (snapshot.connectionState == ConnectionState.waiting) {
//                   return DropdownButtonFormField(
//                     items: [],
//                     onChanged: null,
//                     decoration: InputDecoration(
//                       labelText: 'En cours de chargement ...',
//                       contentPadding: const EdgeInsets.symmetric(
//                           vertical: 10, horizontal: 20),
//                       border: OutlineInputBorder(
//                         borderRadius: BorderRadius.circular(8),
//                       ),
//                     ),
//                   );
//                 }
//                 if (snapshot.hasError) {
//                  return  DropdownButtonFormField(
//                                     items: [],
//                                     onChanged: null,
//                                     decoration: InputDecoration(
//                                       labelText:"Une erreur s'est produite veuiller réessayer",
//                                       contentPadding:
//                                           const EdgeInsets.symmetric(
//                                               vertical: 10, horizontal: 20),
//                                       border: OutlineInputBorder(
//                                         borderRadius: BorderRadius.circular(8),
//                                       ),
//                                     ),
//                                   );
//                 }
//                 if (snapshot.hasData) {
//                   dynamic jsonString = utf8.decode(snapshot.data.bodyBytes);
//                   dynamic responseData = json.decode(jsonString);
//                   if (responseData is List) {
//                     final reponse = responseData;
//                     final categorieList = reponse
//                         .map((e) => CategorieProduit.fromMap(e))
//                         .where((con) => con.statutCategorie == true)
//                         .toList();

//                     if (categorieList.isEmpty) {
//                       return DropdownButtonFormField(
//                         items: [],
//                         onChanged: null,
//                         decoration: InputDecoration(
//                           labelText: '-- Aucune categorie trouvé --',
//                           contentPadding: const EdgeInsets.symmetric(
//                               vertical: 10, horizontal: 20),
//                           border: OutlineInputBorder(
//                             borderRadius: BorderRadius.circular(8),
//                           ),
//                         ),
//                       );
//                     }

//                     return DropdownButtonFormField<String>(
//                       isExpanded: true,
//                       items: categorieList
//                           .map(
//                             (e) => DropdownMenuItem(
//                               value: e.idCategorieProduit,
//                               child: Text(e.libelleCategorie!),
//                             ),
//                           )
//                           .toList(),
//                       hint: Text("-- Filtre par categorie --"),
//                       value: typeValue,
//                       onChanged: (newValue) {
//                         setState(() {
//                           typeValue = newValue;
//                           if (newValue != null) {
//                             selectedCat = categorieList.firstWhere(
//                               (element) => element.idCategorieProduit == newValue,
//                             );
//                                                         debugPrint("id:${selectedCat!.idCategorieProduit!}");
//                           }
//                         });
//                       },
//                       decoration: InputDecoration(
//                         contentPadding: const EdgeInsets.symmetric(
//                             vertical: 10, horizontal: 20),
//                         border: OutlineInputBorder(
//                           borderRadius: BorderRadius.circular(8),
//                         ),
//                       ),
//                     );
//                   } else {
//                     return DropdownButtonFormField(
//                       items: [],
//                       onChanged: null,
//                       decoration: InputDecoration(
//                         labelText: '-- Aucune categorie trouvé --',
//                         contentPadding: const EdgeInsets.symmetric(
//                             vertical: 10, horizontal: 20),
//                         border: OutlineInputBorder(
//                           borderRadius: BorderRadius.circular(8),
//                         ),
//                       ),
//                     );
//                   }
//                 }
//                 return  DropdownButtonFormField(
//                                     items: [],
//                                     onChanged: null,
//                                     decoration: InputDecoration(
//                                       labelText: 'Probleme de connexion',
//                                       contentPadding:
//                                           const EdgeInsets.symmetric(
//                                               vertical: 10, horizontal: 20),
//                                       border: OutlineInputBorder(
//                                         borderRadius: BorderRadius.circular(8),
//                                       ),
//                                     ),
//                                   );
//               },
//             ),
//           ),
//           const SizedBox(height: 10),
//           Consumer<StockService>(builder: (context, stockService, child) {
//             return FutureBuilder(
//                 future:  selectedCat == null ? 
//                 stockService.fetchStock() :  stockService.fetchStockByCategorieWithPagination(selectedCat!.idCategorieProduit!),
//                 builder: (context, snapshot) {
//                   if (snapshot.connectionState == ConnectionState.waiting) {
//                     return const Center(
//                       child: CircularProgressIndicator(
//                         color: Colors.orange,
//                       ),
//                     );
//                   }

//                   if (!snapshot.hasData) {
//                     return SingleChildScrollView(
//                       child: Padding(
//                         padding: EdgeInsets.all(10),
//                         child: Center(
//                           child: Column(
//                             children: [
//                               Image.asset('assets/images/notif.jpg'),
//                               SizedBox(
//                                 height: 10,
//                               ),
//                               Text(
//                                 'Aucun produit trouvé',
//                                 style: TextStyle(
//                                   color: Colors.black,
//                                   fontSize: 17,
//                                   overflow: TextOverflow.ellipsis,
//                                 ),
//                               ),
//                             ],
//                           ),
//                         ),
//                       ),
//                     );
//                   } else {
//                     stockListe = snapshot.data!;
//                     // Vous pouvez afficher une image ou un texte ici
//                     String searchText = "";
//                     List<Stock> filtereSearch = stockListe.where((search) {
//                       String libelle = search.nomProduit!.toLowerCase();
//                       searchText = _searchController.text.trim().toLowerCase();
//                       return libelle.contains(searchText);
//                     }).toList();

                   

//                     return 
//                     stockListe
//                     .where((element) => element.statutSotck == true )
//                     .isEmpty
//                         ? 
//                         SingleChildScrollView(
//                             child: Padding(
//                               padding: EdgeInsets.all(10),
//                               child: Center(
//                                 child: Column(
//                                   children: [
//                                     Image.asset('assets/images/notif.jpg'),
//                                     SizedBox(
//                                       height: 10,
//                                     ),
//                                     Text(
//                                       'Aucun produit trouvé',
//                                       style: TextStyle(
//                                         color: Colors.black,
//                                         fontSize: 17,
//                                         overflow: TextOverflow.ellipsis,
//                                       ),
//                                     ),
//                                   ],
//                                 ),
//                               ),
//                             ),
//                           )
//                         : GridView.builder(
//                             shrinkWrap: true,
//                             physics: NeverScrollableScrollPhysics(),
//                             gridDelegate:
//                                 SliverGridDelegateWithFixedCrossAxisCount(
//                               crossAxisCount: 2,
//                               mainAxisSpacing: 10,
//                               crossAxisSpacing: 10,
//                               childAspectRatio: 0.8,
//                             ),
//                             itemCount: stockListe.length,
//                             itemBuilder: (context, index) {
//                               var e = stockListe
//                                   // .where((element) =>
//                                   //     element.statutSotck == true)
//                                   .elementAt(index);
//                               return GestureDetector(
//                                 onTap: () {
//                                   Navigator.push(
//                                     context,
//                                     MaterialPageRoute(
//                                       builder: (context) => DetailProduits(
//                                         stock: e,
//                                       ),
//                                     ),
//                                   );
//                                 },
//                                 child: Card(
//                                   margin: EdgeInsets.all(8),
//                                   // decoration: BoxDecoration(
//                                   //   color: Color.fromARGB(250, 250, 250, 250),
//                                   //   borderRadius: BorderRadius.circular(15),
//                                   //   boxShadow: [
//                                   //     BoxShadow(
//                                   //       color: Colors.grey.withOpacity(0.3),
//                                   //       offset: Offset(0, 2),
//                                   //       blurRadius: 8,
//                                   //       spreadRadius: 2,
//                                   //     ),
//                                   //   ],
//                             //       isExist == true ?
//                             // typeActeurData
//                             //         .map((e) => e.libelle!.toLowerCase())
//                             //         .contains("admin")
//                             //     ? stockListe.where((element) =>
//                             //             element.statutSotck == true || element.statutSotck == false )  .
//                             //     length
//                             //     : stockListe
//                             //         .where((element) =>
//                             //             element.statutSotck == true && element.acteur?.statutActeur == true)
//                             //         .length : stockListe
//                             //         .where((element) =>
//                             //             element.statutSotck == true && element.acteur?.statutActeur == true)
//                             //         .length 
//                                   // ),

//                                   child: Column(
//                                     crossAxisAlignment:
//                                         CrossAxisAlignment.stretch,
//                                     children: [
//                                       ClipRRect(
//                                         borderRadius:
//                                             BorderRadius.circular(8.0),
//                                         child: Container(
//                                           height: 85,
//                                           child: stockListe[index].photo ==
//                                                   null || stockListe[index].photo!.isEmpty
//                                               ? Image.asset(
//                                                   "assets/images/default_image.png",
//                                                   fit: BoxFit.cover,
//                                                 )
//                                               : CachedNetworkImage(
//                                                   imageUrl:
//                                                       "https://koumi.ml/api-koumi/Stock/${stockListe[index].idStock}/image",
//                                                   fit: BoxFit.cover,
//                                                   placeholder: (context, url) =>
//                                                       const Center(
//                                                           child:
//                                                               CircularProgressIndicator()),
//                                                   errorWidget:
//                                                       (context, url, error) =>
//                                                           Image.asset(
//                                                     'assets/images/default_image.png',
//                                                     fit: BoxFit.cover,
//                                                   ),
//                                                 ),
//                                         ),
//                                       ),
//                                       // SizedBox(height: 8),
//                                       ListTile(
//                                         title: Text(
//                                           e.nomProduit!,
//                                           style: TextStyle(
//                                             fontSize: 16,
//                                             fontWeight: FontWeight.bold,
//                                             color: Colors.black87,
//                                           ),
//                                           maxLines: 2,
//                                           overflow: TextOverflow.ellipsis,
//                                         ),
//                                         subtitle: Text(
//                                           overflow: TextOverflow.ellipsis,
//                                           "${stockListe[index].quantiteStock!.toString()} ${stockListe[index].unite!.nomUnite} ",
//                                           style: TextStyle(
//                                             overflow: TextOverflow.ellipsis,
//                                             fontSize: 15,
//                                             fontWeight: FontWeight.bold,
//                                             color: Colors.black87,
//                                           ),
//                                         ),
//                                       ),
//                                       Padding(
//                                         padding: const EdgeInsets.symmetric(
//                                             horizontal: 15),
//                                         child: Text(
//                                           para.monnaie != null
//                                               ? "${stockListe[index].prix.toString()} ${para.monnaie}"
//                                               : "${stockListe[index].prix.toString()} FCFA",
//                                           style: TextStyle(
//                                             fontSize: 15,
//                                             color: Colors.black87,
//                                           ),
//                                         ),
//                                       ),
//                                       //  _buildItem(
//                                       //         "Localité :", filtereSearch[index].localiteMagasin!),
//                                       //  _buildItem(
//                                       //     "Acteur :", e.acteur!.typeActeur!.map((e) => e.libelle!).join(','))
//                                       // typeActeurData
//                                       //         .map((e) =>
//                                       //             e.libelle!.toLowerCase())
//                                       //         .contains("admin")
//                                       //     ? Padding(
//                                       //         padding:
//                                       //             const EdgeInsets.symmetric(
//                                       //                 horizontal: 8.0),
//                                       //         child: Row(
//                                       //           mainAxisAlignment:
//                                       //               MainAxisAlignment
//                                       //                   .spaceBetween,
//                                       //           children: [
//                                       //             _buildEtat(
//                                       //                 stockListe[index]
//                                       //                     .statutSotck!),
//                                       //             SizedBox(
//                                       //               width: 120,
//                                       //             ),
//                                       //             Expanded(
//                                       //               child:
//                                       //               //     PopupMenuButton<String>(
//                                                     //   padding: EdgeInsets.zero,
//                                                     //   itemBuilder: (context) =>
//                                                     //       <PopupMenuEntry<
//                                                     //           String>>[
//                                                     //     PopupMenuItem<String>(
//                                                     //         child: ListTile(
//                                                     //       leading: stockListe[
//                                                     //                       index]
//                                                     //                   .statutSotck ==
//                                                     //               false
//                                                     //           ? Icon(
//                                                     //               Icons.check,
//                                                     //               color: Colors
//                                                     //                   .green,
//                                                     //             )
//                                                     //           : Icon(
//                                                     //               Icons
//                                                     //                   .disabled_visible,
//                                                     //               color: Colors
//                                                     //                       .orange[
//                                                     //                   400]),
//                                                     //       title: Text(
//                                                     //         stockListe[index]
//                                                     //                     .statutSotck ==
//                                                     //                 false
//                                                     //             ? "Activer"
//                                                     //             : "Desactiver",
//                                                     //         style: TextStyle(
//                                                     //           color: stockListe[
//                                                     //                           index]
//                                                     //                       .statutSotck ==
//                                                     //                   false
//                                                     //               ? Colors.green
//                                                     //               : Colors.red,
//                                                     //           fontWeight:
//                                                     //               FontWeight
//                                                     //                   .bold,
//                                                     //         ),
//                                                     //       ),
//                                                     //       onTap: () async {
//                                                     //         // Changement d'état du magasin ici
//                                                     //         stockListe[index]
//                                                     //                     .statutSotck ==
//                                                     //                 false
//                                                     //             ? await StockService()
//                                                     //                 .activerStock(
//                                                     //                     stockListe[index]
//                                                     //                         .idStock!)
//                                                     //                 .then(
//                                                     //                     (value) =>
//                                                     //                         {
//                                                     //                           // Mettre à jour la liste des magasins après le changement d'état
//                                                     //                           Provider.of<StockService>(context, listen: false).applyChange(),
//                                                     //                           setState(() {
//                                                     //                             stockListeFuture = StockService().fetchStock();
//                                                     //                           }),
//                                                     //                           Navigator.of(context).pop(),
//                                                     //                         })
//                                                     //                 .catchError(
//                                                     //                     (onError) =>
//                                                     //                         {
//                                                     //                           ScaffoldMessenger.of(context).showSnackBar(
//                                                     //                             const SnackBar(
//                                                     //                               content: Row(
//                                                     //                                 children: [
//                                                     //                                   Text("Une erreur s'est produit"),
//                                                     //                                 ],
//                                                     //                               ),
//                                                     //                               duration: Duration(seconds: 5),
//                                                     //                             ),
//                                                     //                           ),
//                                                     //                           Navigator.of(context).pop(),
//                                                     //                         })
//                                                     //             : await StockService()
//                                                     //                 .desactiverStock(
//                                                     //                     stockListe[index]
//                                                     //                         .idStock!)
//                                                     //                 .then(
//                                                     //                     (value) =>
//                                                     //                         {
//                                                     //                           Provider.of<StockService>(context, listen: false).applyChange(),
//                                                     //                           setState(() {
//                                                     //                             stockListeFuture = StockService().fetchStock();
//                                                     //                           }),
//                                                     //                           Navigator.of(context).pop(),
//                                                     //                         });

//                                                     //         ScaffoldMessenger
//                                                     //                 .of(context)
//                                                     //             .showSnackBar(
//                                                     //           SnackBar(
//                                                     //             content: Row(
//                                                     //               children: [
//                                                     //                 Text(stockListe[index].statutSotck ==
//                                                     //                         false
//                                                     //                     ? "Activer avec succèss "
//                                                     //                     : "Desactiver avec succèss"),
//                                                     //               ],
//                                                     //             ),
//                                                     //             duration:
//                                                     //                 Duration(
//                                                     //                     seconds:
//                                                     //                         2),
//                                                     //           ),
//                                                     //         );
//                                                     //       },
//                                                     //     )),
//                                                     //   ],
//                                                     // ),
//                                           //         ),
//                                           //       ],
//                                           //     ),
//                                           //   )
//                                           // : SizedBox(),
//                                     ],
//                                   ),
//                                 ),
//                               );
//                             },
//                           );
//                   }
//                 });
//           }),

//         ]),
//       ),
//     );
//   }

//   Widget _buildItem(String title, String value) {
//     return Padding(
//       padding: const EdgeInsets.all(8.0),
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//         children: [
//           Text(
//             title,
//             style: const TextStyle(
//                 color: Colors.black87,
//                 fontWeight: FontWeight.w500,
//                 fontStyle: FontStyle.italic,
//                 overflow: TextOverflow.ellipsis,
//                 fontSize: 16),
//           ),
//           Text(
//             value,
//             style: const TextStyle(
//                 color: Colors.black,
//                 fontWeight: FontWeight.w800,
//                 overflow: TextOverflow.ellipsis,
//                 fontSize: 16),
//           )
//         ],
//       ),
//     );
//   }

//   Widget _buildEtat(bool isState) {
//     return Container(
//       width: 15,
//       height: 15,
//       decoration: BoxDecoration(
//         borderRadius: BorderRadius.circular(15),
//         color: isState ? Colors.green : Colors.red,
//       ),
//     );
//   }
// }