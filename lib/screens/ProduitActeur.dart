// import 'dart:convert';

// import 'package:flutter/material.dart';

// import 'package:get/get.dart';
// import 'package:http/http.dart' as http;
// import 'package:koumi_app/models/Acteur.dart';
// import 'package:koumi_app/models/CartItem.dart';
// import 'package:koumi_app/models/CategorieProduit.dart';
// import 'package:koumi_app/models/Magasin.dart';
// import 'package:koumi_app/models/Speculation.dart';
// import 'package:koumi_app/models/Stock.dart';
// import 'package:koumi_app/models/TypeActeur.dart';
// import 'package:koumi_app/models/Unite.dart';
// import 'package:koumi_app/models/ZoneProduction.dart';
// import 'package:koumi_app/providers/CartProvider.dart';
// import 'package:koumi_app/screens/Panier.dart';
// import 'package:koumi_app/service/StockService.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:koumi_app/providers/ActeurProvider.dart';
// import 'package:koumi_app/screens/AddAndUpdateProductScreen.dart';
// import 'package:koumi_app/screens/DetailProduits.dart';
// import 'package:koumi_app/screens/ProduitActeur.dart';
// import 'package:koumi_app/widgets/SnackBar.dart';
// import 'package:provider/provider.dart';
// import 'package:badges/badges.dart' as badges;

// import 'package:shimmer/shimmer.dart';

// class ProduitActeurScreen extends StatefulWidget {
//   final String? id; // ID du magasin (optionnel)
//   final String? nom;
//   ProduitActeurScreen({super.key, this.id, this.nom});

//   @override
//   State<ProduitActeurScreen> createState() => _ProduitActeurScreenState();
// }

// class _ProduitActeurScreenState extends State<ProduitActeurScreen>
//     with TickerProviderStateMixin {
//   TabController? _tabController;
//   late TextEditingController _searchController;

//   List<Stock> stock = [];
//  late Acteur acteur =
//       Acteur(); 
//         late List<TypeActeur> typeActeurData = [];
//   late String type;
    
//    bool? isEditable = false;
//   List<CategorieProduit> categorieProduit = [];
//   String selectedCategorieProduit = "";
//   String selectedCategorieProduitNom = "";

//   Set<String> loadedRegions = {};

//   String? email = "";
//       bool isExist = false;
//        StockController  
//    controller = Get.put(StockController());

//   void verify() async {

//     SharedPreferences prefs = await SharedPreferences.getInstance();
//     email = prefs.getString('emailActeur');
//     if (email != null) {
//       // Si l'email de l'acteur est présent, exécute checkLoggedIn
//       acteur = Provider.of<ActeurProvider>(context, listen: false).acteur!;
//       typeActeurData = acteur.typeActeur!;
//       type = typeActeurData.map((data) => data.libelle).join(', ');
      
//     }
//     if(widget.id != null) {
//       setState(() {
//         isExist = true;
//       });
//     }else{
//       setState(() {
//         setState(() {
//           isExist = false;
//         });
//       });
//     }
//   }


  
//   void fetchCategorie() async {
//     try {
//       final response = await http
//           .get(Uri.parse('https://koumi.ml/api-koumi/Categorie/allCategorie'));
//           // .get(Uri.parse('http://10.0.2.2:9000/api-koumi/Categorie/allCategorie'));
//       if (response.statusCode == 200) {
//         final String jsonString = utf8.decode(response.bodyBytes);
//         List<dynamic> data = json.decode(jsonString);
//         setState(() {
//          categorieProduit = data
//           .where((element) => element['statutCategorie'] == true)
//               .map((item) => CategorieProduit(
//                     idCategorieProduit: item['idCategorieProduit'] as String,
//                     libelleCategorie: item['libelleCategorie'] as String,
//                     statutCategorie: item['statutCategorie'] as bool
//                   ))
//               .toList();
//           _tabController =
//               TabController(length: categorieProduit.length, vsync: this);
//           _tabController!.addListener(_handleTabChange);
//           selectedCategorieProduit = categorieProduit.isNotEmpty
//               ? categorieProduit.first.idCategorieProduit!
//               : '';
//           selectedCategorieProduitNom = categorieProduit.isNotEmpty
//               ? categorieProduit[_tabController!.index].libelleCategorie!
//               : '';
//     widget.id != null   ? controller.fetchProduitByCategorieProduit(selectedCategorieProduit, widget.id!, acteur.idActeur!) : controller.fetchProduitByCategorieAndActeur(selectedCategorieProduit, acteur.idActeur!);
//         });
//         debugPrint(
//             "Id Cat : ${categorieProduit.map((e) => e.idCategorieProduit)}");
//       } else {
//         throw Exception('Failed to load categories');
//       }
//     } catch (e) {
//       print('Error fetching categories: $e');
//     }
//   }

//   void _handleTabChange() {
//     if (_tabController != null &&
//         _tabController!.index >= 0 &&
//         _tabController!.index < categorieProduit.length) {
//       selectedCategorieProduit =
//           categorieProduit[_tabController!.index].idCategorieProduit!;
//       selectedCategorieProduitNom =
//      categorieProduit[_tabController!.index].libelleCategorie!;
//     widget.id != null   ? controller.fetchProduitByCategorieProduit(selectedCategorieProduit, widget.id!, acteur.idActeur!) : controller.fetchProduitByCategorieAndActeur(selectedCategorieProduit, acteur.idActeur!);
  
//       debugPrint("Cat id : " + selectedCategorieProduit);
//     }
//   }

//   @override
//   void initState() {
//     super.initState();
//     _searchController = TextEditingController();
//       verify();

//     if (categorieProduit.isEmpty) {
//       fetchCategorie();
//     }
//   }

//   @override
//   void dispose() {
//     _tabController?.dispose();
//     _searchController.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//            const d_colorGreen = Color.fromRGBO(43, 103, 6, 1);
//            // Wrap your loading content with Redacted Widget

//     return Container(
//       child: DefaultTabController(
//         length: categorieProduit.length,
//         child: Scaffold(

//        backgroundColor: const Color.fromARGB(255, 250, 250, 250),
//       appBar: AppBar(
//         bottom: TabBar(
//               isScrollable: categorieProduit.length > 4,
//               labelColor: Colors.black,
//               controller: _tabController, // Ajoutez le contrôleur TabBar
//               tabs: categorieProduit.map((cat) => Tab(text: cat.libelleCategorie)).toList(),
//             ),
//         //     actions: [
//         //   Row(
//         //     children: [
//         //       Consumer<CartProvider>(
//         //         builder: (context, cartProvider, child) {
//         //           return badges.Badge(
//         //             badgeStyle: badges.BadgeStyle(
//         //               badgeColor: Colors.red,
//         //             ),
//         //             position: badges.BadgePosition.bottomEnd(bottom: 1, end: 1),
//         //             badgeContent: Text(
//         //               cartProvider.cartItems.length.toString(),
//         //               style: const TextStyle(
//         //                 color: Colors.white,
//         //               ),
//         //             ),
//         //             child: IconButton(
//         //               color: Colors.blue,
//         //               icon: const Icon(Icons.local_mall),
//         //               iconSize: 25,
//         //               onPressed: () {
//         //                 Navigator.push(
//         //                     context,
//         //                     MaterialPageRoute(
//         //                         builder: (BuildContext ctx) =>
//         //                              Panier()));
//         //               },
//         //             ),
//         //           );
//         //         },
//         //       ),
//         //       const SizedBox(
//         //         width: 5,
//         //       )
//         //     ],
//         //   )
//         // ],
//           centerTitle: true,
//           toolbarHeight: 100,
//           // leading: IconButton(
//           //     onPressed: () {
//           //       Navigator.of(context).pop();
//           //     },
//           //     icon: const Icon(Icons.arrow_back_ios, color: d_colorGreen)),
//           title: Text(
//             'Mes Produits',
//             style: const TextStyle(
//                 color: d_colorGreen, fontWeight: FontWeight.bold),
//           ),
//         //  actions: [
//         //     PopupMenuButton<String>(
//         //       padding: EdgeInsets.zero,
//         //       itemBuilder: (context) {
//         //         print("Type: $type");
//         // return stock.any((element) => element.acteur!.idActeur == acteur.idActeur)
//         //             ? 
//         //              <PopupMenuEntry<String>>[
//         //                 PopupMenuItem<String>(
//         //                   child: ListTile(
//         //                     leading: const Icon(
//         //                       Icons.add,
//         //                       color: Colors.green,
//         //                     ),
//         //                     title: const Text(
//         //                       "Ajouter produit",
//         //                       style: TextStyle(
//         //                         color: Colors.green,
//         //                         fontWeight: FontWeight.bold,
//         //                       ),
//         //                     ),
//         //                     onTap: () async {
//         //                       Navigator.push(
//         //                           context,
//         //                           MaterialPageRoute(
//         //                               builder: (context) =>
//         //                                   AddAndUpdateProductScreen(isEditable: isEditable,)));
//         //                     },
//         //                   ),
//         //                 ),
//         //               ]:
//         //               <PopupMenuEntry<String>>[
//         //                 PopupMenuItem<String>(
//         //                   child: ListTile(
//         //                     leading: const Icon(
//         //                       Icons.remove_red_eye,
//         //                       color: Colors.green,
//         //                     ),
//         //                     title: const Text(
//         //                       "Tous les produits",
//         //                       style: TextStyle(
//         //                         color: Colors.green,
//         //                         fontWeight: FontWeight.bold,
//         //                       ),
//         //                     ),
//         //                     onTap: () async {
//         //                       Navigator.push(
//         //                           context,
//         //                           MaterialPageRoute(
//         //                               builder: (context) => ProduitActeurScreen()));
//         //                     },
//         //                   ),
//         //                 ),
//         //               ];
//         //       },
//         //     )
//         //   ]
//           ),

//           body: Padding(
//             padding: const EdgeInsets.all(8.0),
//             child: Column(
//               children: [
//                 const SizedBox(height: 10),
//                 Padding(
//             padding: const EdgeInsets.all(10.0),
//             child: Container(
//               padding: EdgeInsets.symmetric(horizontal: 10),
//               decoration: BoxDecoration(
//                 color: Colors.blueGrey[50], // Couleur d'arrière-plan
//                 borderRadius: BorderRadius.circular(25),
//               ),
//               child: Row(
//                 children: [
//                   Icon(Icons.search,
//                       color: Colors.blueGrey[400]), // Couleur de l'icône
//                   SizedBox(
//                       width:
//                           10), // Espacement entre l'icône et le champ de recherche
//                   Expanded(
//                     child: TextField(
//                       controller: _searchController,
//                       onChanged: (value) {
//                         setState(() {});
//                       },
//                       decoration: InputDecoration(
//                         hintText: 'Rechercher',
//                         border: InputBorder.none,
//                         hintStyle: TextStyle(
//                             color: Colors
//                                 .blueGrey[400]), // Couleur du texte d'aide
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//                  widget.id != null ? Flexible(
//                   child: GestureDetector(
//                     child:  TabBarView(
//                       controller: _tabController,
//                       children:  categorieProduit.map((categorie) {
//                         return buildGridView(
//                             categorie.idCategorieProduit!,  widget.id, acteur.idActeur!);
//                       }).toList(),
//                     ) ,
//                   ),
//                 ) : Flexible(
//                   child: GestureDetector(
//                     child:  TabBarView(
//                       controller: _tabController,
//                       children:  categorieProduit.map((categorie) {
//                         return buildGridViews(
//                             categorie.idCategorieProduit!,acteur.idActeur!);
//                       }).toList(),
//                     ) ,
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }

  
//   Widget buildGridView(String idCategorie, String? idMagasin, String idActeur) {
//     List<Stock> filteredStocks = stock;
//     String searchText = "";
  
 
//     if (filteredStocks.isEmpty) {
//        return  _buildShimmerEffect();
//       //  SingleChildScrollView(
//       //     child: Padding(
//       //                       padding: EdgeInsets.all(10),
//       //                       child: Center(
//       //                         child: Column(
//       //                           children: [
//       //                             Image.asset('assets/images/notif.jpg'),
//       //                             SizedBox(
//       //                               height: 10,
//       //                             ),
//       //   Padding(
//       //     padding: const EdgeInsets.all(8.0),
//       //     child: Center(
//       //       child: Text(
//       //         textAlign: TextAlign.justify,
//       //         'Aucun produit trouvé  ' +
//       //             " dans la categorie " +
//       //             selectedCategorieProduitNom.toUpperCase() + " dans le magasin " + widget.nom!,
//       //         style: TextStyle(fontSize: 16),
//       //       ),
//       //     ),
//       //   )
//       //                           ],
//       //                         ),
//       //                       ),
//       //                     ),
//       //   );
   
//     } else {
//       List<Stock> filteredStocksSearch = filteredStocks.where((stock) {
//         String nomProduit = stock.nomProduit!.toLowerCase();
//         searchText = _searchController.text.toLowerCase();
//         return nomProduit.contains(searchText);
//       }).toList();

//       if (filteredStocksSearch.isEmpty  && _searchController.text.isNotEmpty) {
//         return  
//     SingleChildScrollView(
//           child: Padding(
//                             padding: EdgeInsets.all(10),
//                             child: Center(
//                               child: Column(
//                                 children: [
//                                   Image.asset('assets/images/notif.jpg'),
//                                   SizedBox(
//                                     height: 10,
//                                   ),
//         Padding(
//           padding: const EdgeInsets.all(8.0),
//           child: Center(
//             child: Text(
//               textAlign: TextAlign.justify,
//               'Aucun produit trouvé avec le nom ' +
//                   searchText.toUpperCase() +
//                   " dans la categorie " +
//                   selectedCategorieProduitNom.toUpperCase(),
//               style: TextStyle(fontSize: 16),
//             ),
//           ),
//         )
//                                 ],
//                               ),
//                             ),
//                           ),
//         );
//       }
//       if (filteredStocksSearch.isEmpty) {
//         return  
//     SingleChildScrollView(
//           child: Padding(
//                             padding: EdgeInsets.all(10),
//                             child: Center(
//                               child: Column(
//                                 children: [
//                                   Image.asset('assets/images/notif.jpg'),
//                                   SizedBox(
//                                     height: 10,
//                                   ),
//         Padding(
//           padding: const EdgeInsets.all(8.0),
//           child: Center(
//             child: Text(
//               textAlign: TextAlign.justify,
//               'Aucun produit trouvé' +
//                   " dans la categorie " +
//                   selectedCategorieProduitNom.toUpperCase(),
//               style: TextStyle(fontSize: 16),
//             ),
//           ),
//         )
//                                 ],
//                               ),
//                             ),
//                           ),
//         );
//       }

     
//  return Container(
//   height:MediaQuery.of(context).size.height,
//   color: Colors.white,
//    child: GridView.builder(
//     gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
//       crossAxisCount: 2,
//       mainAxisSpacing: 10,
//       crossAxisSpacing: 10,
//     ),
//     itemCount: filteredStocks.length,
//     itemBuilder: (context, index) {
//       return Container(
//         decoration: BoxDecoration(
//          color: Colors.white,
//           borderRadius: BorderRadius.circular(15),
//           boxShadow: [
//             BoxShadow(
//               color: Colors.grey.withOpacity(0.2),
//               offset: const Offset(0, 2),
//               blurRadius: 5,
//               spreadRadius: 2,
//             ),
//           ],
//         ),
//         margin: EdgeInsets.all(5),
//         child: GestureDetector(
//           onTap: () {
//             // Action à effectuer lorsqu'un produit est cliqué
//             Stock stock = filteredStocksSearch[index];
 
// Get.to(
//   () => DetailProduits(
//     stock: stock,
//   ),
//   duration: const Duration(seconds: 1), // Duration of transition
//   transition: Transition.leftToRight, // Transition effect
// );       
// },
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Container(
//                 width: double.infinity,
//                 height: 110, // Taille de la photo
//                 child: Image.network(
//                   filteredStocks[index].photo ?? 'assets/images/mang.jpg',
//                   fit: BoxFit.cover,
//                   errorBuilder: (context, error, stackTrace) {
//                     return Image.asset(
//                       'assets/images/mang.jpg',
//                       fit: BoxFit.cover,
//                     );
//                   },
//                 ),
//               ),
//               Padding(
//                 padding: const EdgeInsets.symmetric(horizontal: 4.0),
//                 child: Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                   children: [
//                     Text(
//                       filteredStocksSearch[index].nomProduit!,
//                       style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold , overflow:TextOverflow.ellipsis),
//                     ),
//                     Container(
//                       decoration: BoxDecoration(
//                         borderRadius: BorderRadius.circular(40),
//                         color: Colors.grey[200],
//                       ),
//                       child: Text(
//                         filteredStocksSearch[index].quantiteStock!.toInt().toString(),
//                         style: TextStyle(fontSize: 14,  overflow:TextOverflow.ellipsis),
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//               // const SizedBox(height: 3,),
//               Container(
//                                                            child: 
//                                                             Container(
                                                      
//                                                           child: Padding(
//                                                          padding: const EdgeInsets.symmetric(horizontal:8.0),
//                                                                                                        child: Row(
//                                                               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                                                               children: [
//                                                                 _buildEtat(filteredStocksSearch[index].statutSotck!),
//                                                                 SizedBox(width: 130,),
//                                                                 Expanded(
//                                                                   child: PopupMenuButton<String>(
//                                                                     padding: EdgeInsets.zero,
//                                                                     itemBuilder: (context) =>
//                                                                         <PopupMenuEntry<String>>[
//                                                                       PopupMenuItem<String>(
//                                                                         child: ListTile(
//                                                                           leading: const Icon(
//                                                                             Icons.check,
//                                                                             color: Colors.green,
//                                                                           ),
//                                                                           title: const Text(
//                                                                             "Activer",
//                                                                             style: TextStyle(
//                                                                               color: Colors.green,
//                                                                               fontWeight: FontWeight.bold,
//                                                                             ),
//                                                                           ),
//                                                                           onTap: () async {
//                                                                             await StockService()
//                                                                                 .activerStock(filteredStocksSearch[index].idStock!)
//                                                                                 .then((value) => {
//                                                                                       Navigator.of(context).pop(),
//                                                                                     })
//                                                                                 .catchError((onError) => {
//                                                                                       ScaffoldMessenger.of(context)
//                                                                                           .showSnackBar(
//                                                                                         const SnackBar(
//                                                                                           content: Row(
//                                                                                             children: [
//                                                                                               Text(
//                                                                                                   "Une erreur s'est produit"),
//                                                                                             ],
//                                                                                           ),
//                                                                                           duration:
//                                                                                               Duration(seconds: 5),
//                                                                                         ),
//                                                                                       ),
//                                                                                       Navigator.of(context).pop(),
//                                                                                     });
                                                                  
//                                                                             ScaffoldMessenger.of(context)
//                                                                                 .showSnackBar(
//                                                                               const SnackBar(
//                                                                                 content: Row(
//                                                                                   children: [
//                                                                                     Text("Activer avec succèss "),
//                                                                                   ],
//                                                                                 ),
//                                                                                 duration: Duration(seconds: 2),
//                                                                               ),
//                                                                             );
//                                                                           },
//                                                                         ),
//                                                                       ),
//                                                                       PopupMenuItem<String>(
//                                                                         child: ListTile(
//                                                                           leading: Icon(
//                                                                             Icons.disabled_visible,
//                                                                             color: Colors.orange[400],
//                                                                           ),
//                                                                           title: Text(
//                                                                             "Désactiver",
//                                                                             style: TextStyle(
//                                                                               color: Colors.orange[400],
//                                                                               fontWeight: FontWeight.bold,
//                                                                             ),
//                                                                           ),
//                                                                           onTap: () async {
//                                                                             await StockService()
//                                                                                 .desactiverStock(filteredStocksSearch[index].idStock!)
//                                                                                 .then((value) => {
//                                                                                       Navigator.of(context).pop(),
//                                                                                     })
//                                                                                 .catchError((onError) => {
//                                                                                       ScaffoldMessenger.of(context)
//                                                                                           .showSnackBar(
//                                                                                         const SnackBar(
//                                                                                           content: Row(
//                                                                                             children: [
//                                                                                               Text(
//                                                                                                   "Une erreur s'est produit"),
//                                                                                             ],
//                                                                                           ),
//                                                                                           duration:
//                                                                                               Duration(seconds: 5),
//                                                                                         ),
//                                                                                       ),
//                                                                                       Navigator.of(context).pop(),
//                                                                                     });
                                                                  
//                                                                             ScaffoldMessenger.of(context)
//                                                                                 .showSnackBar(
//                                                                               const SnackBar(
//                                                                                 content: Row(
//                                                                                   children: [
//                                                                                     Text("Désactiver avec succèss "),
//                                                                                   ],
//                                                                                 ),
//                                                                                 duration: Duration(seconds: 2),
//                                                                               ),
//                                                                             );
//                                                                           },
//                                                                         ),
//                                                                       ),
                                                                      
//                                                                       PopupMenuItem<String>(
//                                                                         child: ListTile(
//                                                                           leading: const Icon(
//                                                                             Icons.delete,
//                                                                             color: Colors.red,
//                                                                           ),
//                                                                           title: const Text(
//                                                                             "Supprimer",
//                                                                             style: TextStyle(
//                                                                               color: Colors.red,
//                                                                               fontWeight: FontWeight.bold,
//                                                                             ),
//                                                                           ),
//                                                                           onTap: () async {
//                                                                             await StockService()
//                                                                                 .deleteStock(filteredStocksSearch[index]
//                                                                                     .idStock!)
//                                                                                 .then((value) => {
//                                                                                       Provider.of<StockService>(
//                                                                                               context,
//                                                                                               listen: false)
//                                                                                           .applyChange(),
//                                                                                       setState(() {
//                                                                                         filteredStocksSearch = stock;
//                                                                                       }),
//                                                                                       Navigator.of(context).pop(),
//                                                                                       ScaffoldMessenger.of(context)
//                                                                                           .showSnackBar(
//                                                                                         const SnackBar(
//                                                                                           content: Row(
//                                                                                             children: [
//                                                                                               Text(
//                                                                                                   "Magasin supprimer avec succès"),
//                                                                                             ],
//                                                                                           ),
//                                                                                           duration:
//                                                                                               Duration(seconds: 2),
//                                                                                         ),
//                                                                                       )
//                                                                                     })
//                                                                                 .catchError((onError) => {
//                                                                                       ScaffoldMessenger.of(context)
//                                                                                           .showSnackBar(
//                                                                                         const SnackBar(
//                                                                                           content: Row(
//                                                                                             children: [
//                                                                                               Text(
//                                                                                                   "Impossible de supprimer"),
//                                                                                             ],
//                                                                                           ),
//                                                                                           duration:
//                                                                                               Duration(seconds: 2),
//                                                                                         ),
//                                                                                       )
//                                                                                     });
//                                                                           },
//                                                                         ),
//                                                                       ),
//                                                                     ],
//                                                                   ),
//                                                                 ),
//                                                               ],
//                                                                                                        ),
//                                                                                                      ),
//                                                             ),
//                                                          ),

//             ],
//           ),
//         ),
//       );
//     },
//    ),
//  );

//     }
//   }

//   Widget buildGridViews(String idCategorie, String idActeur) {
//     List<Stock> filteredStocks = stock;
//     String searchText = "";
  
 
//     if (filteredStocks.isEmpty) {
//        return   _buildShimmerEffect();
   
//     } else {
//       List<Stock> filteredStocksSearch = filteredStocks.where((stock) {
//         String nomProduit = stock.nomProduit!.toLowerCase();
//         searchText = _searchController.text.toLowerCase();
//         return nomProduit.contains(searchText);
//       }).toList();

//       if (filteredStocksSearch.isEmpty && _searchController.text.isNotEmpty) {
//         return  
//     SingleChildScrollView(
//           child: Padding(
//                             padding: EdgeInsets.all(10),
//                             child: Center(
//                               child: Column(
//                                 children: [
//                                   Image.asset('assets/images/notif.jpg'),
//                                   SizedBox(
//                                     height: 10,
//                                   ),
//         Padding(
//           padding: const EdgeInsets.all(8.0),
//           child: Center(
//             child: Text(
//               textAlign: TextAlign.justify,
//               'Aucun produit trouvé avec le nom ' +
//                   searchText.toUpperCase() +
//                   " dans la categorie " +
//                   selectedCategorieProduitNom.toUpperCase(),
//               style: TextStyle(fontSize: 16),
//             ),
//           ),
//         )
//                                 ],
//                               ),
//                             ),
//                           ),
//         );
//       }
     
//  return Container(
//     height:MediaQuery.of(context).size.height,
//   color: Colors.white,
//    child: GridView.builder(
//     gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
//       crossAxisCount: 2,
//       mainAxisSpacing: 10,
//       crossAxisSpacing: 10,
//     ),
//     itemCount: filteredStocks.length,
//     itemBuilder: (context, index) {
//       return Container(
//         decoration: BoxDecoration(
//          color: Colors.white,
//           borderRadius: BorderRadius.circular(15),
//           boxShadow: [
//             BoxShadow(
//               color: Colors.grey.withOpacity(0.2),
//               offset: const Offset(0, 2),
//               blurRadius: 5,
//               spreadRadius: 2,
//             ),
//           ],
//         ),
//         margin: EdgeInsets.all(5),
//         child: GestureDetector(
//           onTap: () {
//             // Action à effectuer lorsqu'un produit est cliqué
//             Stock stock = filteredStocksSearch[index];
 
// Get.to(
//   () => DetailProduits(
//     stock: stock,
//   ),
//   duration: const Duration(seconds: 1), // Duration of transition
//   transition: Transition.leftToRight, // Transition effect
// );       },
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Container(
//                 width: double.infinity,
//                 height: 110, // Taille de la photo
//                 child: Image.network(
//                   filteredStocks[index].photo ?? 'assets/images/mang.jpg',
//                   fit: BoxFit.cover,
//                   errorBuilder: (context, error, stackTrace) {
//                     return Image.asset(
//                       'assets/images/mang.jpg',
//                       fit: BoxFit.cover,
//                     );
//                   },
//                 ),
//               ),
//               Padding(
//                 padding: const EdgeInsets.symmetric(horizontal: 4.0),
//                 child: Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                   children: [
//                     Text(
//                       filteredStocksSearch[index].nomProduit!,
//                       style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold , overflow:TextOverflow.ellipsis),
//                     ),
//                     Container(
//                       decoration: BoxDecoration(
//                         borderRadius: BorderRadius.circular(40),
//                         color: Colors.grey[200],
//                       ),
//                       child: Text(
//                         filteredStocksSearch[index].quantiteStock!.toInt().toString(),
//                         style: TextStyle(fontSize: 14,  overflow:TextOverflow.ellipsis),
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//               Container(
//                                                            child: 
//                                                             Container(
//                                                           child: Padding(
//                                                                                                        padding: const EdgeInsets.symmetric(horizontal:8.0),
//                                                                                                        child: Row(
//                                                               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                                                               children: [
//                                                                 _buildEtat(filteredStocksSearch[index].statutSotck!),
//                                                                 SizedBox(width: 130,),
//                                                                 Expanded(
//                                                                   child: PopupMenuButton<String>(
//                                                                     padding: EdgeInsets.zero,
//                                                                     itemBuilder: (context) =>
//                                                                         <PopupMenuEntry<String>>[
//                                                                       PopupMenuItem<String>(
//                                                                         child: ListTile(
//                                                                           leading: const Icon(
//                                                                             Icons.check,
//                                                                             color: Colors.green,
//                                                                           ),
//                                                                           title: const Text(
//                                                                             "Activer",
//                                                                             style: TextStyle(
//                                                                               color: Colors.green,
//                                                                               fontWeight: FontWeight.bold,
//                                                                             ),
//                                                                           ),
//                                                                           onTap: () async {
//                                                                             await StockService()
//                                                                                 .activerStock(filteredStocksSearch[index].idStock!)
//                                                                                 .then((value) => {
//                                                                                       Navigator.of(context).pop(),
//                                                                                     })
//                                                                                 .catchError((onError) => {
//                                                                                       ScaffoldMessenger.of(context)
//                                                                                           .showSnackBar(
//                                                                                         const SnackBar(
//                                                                                           content: Row(
//                                                                                             children: [
//                                                                                               Text(
//                                                                                                   "Une erreur s'est produit"),
//                                                                                             ],
//                                                                                           ),
//                                                                                           duration:
//                                                                                               Duration(seconds: 5),
//                                                                                         ),
//                                                                                       ),
//                                                                                       Navigator.of(context).pop(),
//                                                                                     });
                                                                  
//                                                                             ScaffoldMessenger.of(context)
//                                                                                 .showSnackBar(
//                                                                               const SnackBar(
//                                                                                 content: Row(
//                                                                                   children: [
//                                                                                     Text("Activer avec succèss "),
//                                                                                   ],
//                                                                                 ),
//                                                                                 duration: Duration(seconds: 2),
//                                                                               ),
//                                                                             );
//                                                                           },
//                                                                         ),
//                                                                       ),
//                                                                       PopupMenuItem<String>(
//                                                                         child: ListTile(
//                                                                           leading: Icon(
//                                                                             Icons.disabled_visible,
//                                                                             color: Colors.orange[400],
//                                                                           ),
//                                                                           title: Text(
//                                                                             "Désactiver",
//                                                                             style: TextStyle(
//                                                                               color: Colors.orange[400],
//                                                                               fontWeight: FontWeight.bold,
//                                                                             ),
//                                                                           ),
//                                                                           onTap: () async {
//                                                                             await StockService()
//                                                                                 .desactiverStock(filteredStocksSearch[index].idStock!)
//                                                                                 .then((value) => {
//                                                                                       Navigator.of(context).pop(),
//                                                                                     })
//                                                                                 .catchError((onError) => {
//                                                                                       ScaffoldMessenger.of(context)
//                                                                                           .showSnackBar(
//                                                                                         const SnackBar(
//                                                                                           content: Row(
//                                                                                             children: [
//                                                                                               Text(
//                                                                                                   "Une erreur s'est produit"),
//                                                                                             ],
//                                                                                           ),
//                                                                                           duration:
//                                                                                               Duration(seconds: 5),
//                                                                                         ),
//                                                                                       ),
//                                                                                       Navigator.of(context).pop(),
//                                                                                     });
                                                                  
//                                                                             ScaffoldMessenger.of(context)
//                                                                                 .showSnackBar(
//                                                                               const SnackBar(
//                                                                                 content: Row(
//                                                                                   children: [
//                                                                                     Text("Désactiver avec succèss "),
//                                                                                   ],
//                                                                                 ),
//                                                                                 duration: Duration(seconds: 2),
//                                                                               ),
//                                                                             );
//                                                                           },
//                                                                         ),
//                                                                       ),
                                                                      
//                                                                       PopupMenuItem<String>(
//                                                                         child: ListTile(
//                                                                           leading: const Icon(
//                                                                             Icons.delete,
//                                                                             color: Colors.red,
//                                                                           ),
//                                                                           title: const Text(
//                                                                             "Supprimer",
//                                                                             style: TextStyle(
//                                                                               color: Colors.red,
//                                                                               fontWeight: FontWeight.bold,
//                                                                             ),
//                                                                           ),
//                                                                           onTap: () async {
//                                                                             await StockService()
//                                                                                 .deleteStock(filteredStocksSearch[index]
//                                                                                     .idStock!)
//                                                                                 .then((value) => {
//                                                                                       Provider.of<StockService>(
//                                                                                               context,
//                                                                                               listen: false)
//                                                                                           .applyChange(),
//                                                                                       setState(() {
//                                                                                         filteredStocksSearch = stock;
//                                                                                       }),
//                                                                                       Navigator.of(context).pop(),
//                                                                                       ScaffoldMessenger.of(context)
//                                                                                           .showSnackBar(
//                                                                                         const SnackBar(
//                                                                                           content: Row(
//                                                                                             children: [
//                                                                                               Text(
//                                                                                                   "Magasin supprimer avec succès"),
//                                                                                             ],
//                                                                                           ),
//                                                                                           duration:
//                                                                                               Duration(seconds: 2),
//                                                                                         ),
//                                                                                       )
//                                                                                     })
//                                                                                 .catchError((onError) => {
//                                                                                       ScaffoldMessenger.of(context)
//                                                                                           .showSnackBar(
//                                                                                         const SnackBar(
//                                                                                           content: Row(
//                                                                                             children: [
//                                                                                               Text(
//                                                                                                   "Impossible de supprimer"),
//                                                                                             ],
//                                                                                           ),
//                                                                                           duration:
//                                                                                               Duration(seconds: 2),
//                                                                                         ),
//                                                                                       )
//                                                                                     });
//                                                                           },
//                                                                         ),
//                                                                       ),
//                                                                     ],
//                                                                   ),
//                                                                 ),
//                                                               ],
//                                                                                                        ),
//                                                                                                      ),
//                                                             ),
//                                                          ),

//             ],
//           ),
//         ),
//       );
//     },
//    ),
//  );

//     }
//   }
  



//     Widget _buildShimmerEffect() {
//     return Shimmer.fromColors(
//       period: Duration(seconds: 2),
//       baseColor: Colors.grey[300]!,
//       highlightColor: Colors.grey[100]!,
//       child: GridView.builder(
//         gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
//           crossAxisCount: 2,
//           mainAxisSpacing: 10,
//           crossAxisSpacing: 10,
//         ),
//         itemCount: 6, // Nombre de cellules de la grille
//         itemBuilder: (context, index) {
//           return Container(
//             decoration: BoxDecoration(
//               color: Colors.white,
//               borderRadius: BorderRadius.circular(10),
//             ),
//           );
//         },
//       ),
//     );
//   }


//     Widget _buildEtat(bool isState) {
//     return Container(
//       width: 15,
//       height: 15,
//       decoration: BoxDecoration(
//         borderRadius: BorderRadius.circular(15),
//         color: isState ? Colors.green : Colors.red,
//       ),
//     );
//   }

//  Widget _buildItem(String title, String value) {
//     return Padding(
//       padding: const EdgeInsets.all(4.0),
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//         children: [
//           Flexible(
//             child: Text(
//               title,
//               style: const TextStyle(
              
//                   color: Colors.black87,
//                   fontWeight: FontWeight.w800,
//                   fontStyle: FontStyle.italic,
//                   overflow: TextOverflow.ellipsis,
//                   fontSize: 16),
//             ),
//           ),
//           Flexible(
//             child: Text(
//               value,
//               style: const TextStyle(
//                   color: Colors.black,
//                   fontWeight: FontWeight.w800,
//                   overflow: TextOverflow.ellipsis,
//                   fontSize: 16),
//             ),
//           )
//         ],
//       ),
//     );
//   }

  

//   Widget builCard(String idCategorie, String idMagasin){
  
//      return Container(
//       height:  200, 
//       width: MediaQuery.of(context).size.width / 2 - 20, // Half-width for two cards per row
//       margin: const EdgeInsets.all(10.0),
//       decoration: BoxDecoration(
//         borderRadius: BorderRadius.circular(15.0),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.grey.withOpacity(0.2),
//             spreadRadius: 3.0,
//             blurRadius: 5.0,
//           )
//         ],
//         image: DecorationImage(
//           image: NetworkImage(""),
//           fit: BoxFit.cover,
//         ),
//       ),
//       child: Stack(
//         children: [
//           Positioned(
//             bottom: 10.0,
//             left: 10.0,
//             child: Text(
//               "Nom",
//               style: const TextStyle(
//                 color: Colors.white,
//                 fontSize: 16.0,
//                 fontWeight: FontWeight.bold,
//               ),
//             ),
//           ),
//           Positioned(
//             bottom: 10.0,
//             right: 10.0,
//             child: Row(
//               children: [
//                 Icon(
//                   Icons.star,
//                   color: Colors.yellow[700],
//                   size: 16.0,
//                 ),
//                 Text(
//                   "3", // Display rating with one decimal place
//                   style: const TextStyle(
//                     color: Colors.white,
//                     fontSize: 14.0,
//                   ),
//                 ),
//               ],
//             ),
//           ),
//           Positioned(
//             top: 10.0,
//             right: 10.0,
//             child: Container(
//               padding: const EdgeInsets.all(5.0),
//               decoration: BoxDecoration(
//                 color: Colors.black.withOpacity(0.5),
//                 borderRadius: BorderRadius.circular(5.0),
//               ),
//               child: Text(
//                 '2000', // Display price with two decimal places
//                 style: const TextStyle(
//                   color: Colors.white,
//                   fontSize: 12.0,
//                 ),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );

//   }

 
// }