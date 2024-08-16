// import 'dart:convert';

// import 'package:flutter/material.dart';

// import 'package:get/get.dart';
// import 'package:http/http.dart' as http;
// import 'package:koumi_app/models/Acteur.dart';
// import 'package:koumi_app/models/CartItem.dart';
// import 'package:koumi_app/models/CategorieProduit.dart';
// import 'package:koumi_app/models/Speculation.dart';
// import 'package:koumi_app/models/Stock.dart';
// import 'package:koumi_app/models/TypeActeur.dart';
// import 'package:koumi_app/models/Unite.dart';
// import 'package:koumi_app/providers/CartProvider.dart';
// import 'package:koumi_app/screens/Panier.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:koumi_app/providers/ActeurProvider.dart';
// import 'package:koumi_app/screens/AddAndUpdateProductScreen.dart';
// import 'package:koumi_app/screens/DetailProduits.dart';
// import 'package:koumi_app/screens/ProduitActeur.dart';
// import 'package:koumi_app/widgets/SnackBar.dart';
// import 'package:provider/provider.dart';
// import 'package:badges/badges.dart' as badges;

// import 'package:shimmer/shimmer.dart';

// class ProduitScreen extends StatefulWidget {
//   final String? id; // ID du magasin (optionnel)
//   final String? nom;
//   ProduitScreen({super.key, this.id, this.nom});

//   @override
//   State<ProduitScreen> createState() => _ProduitScreenState();
// }

// class _ProduitScreenState extends State<ProduitScreen>
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
//     List<CartItem> cartItems = [];

//   Set<String> loadedRegions = {};

//   String? email = "";
//       bool isExist = false;

//   void verify() async {

//     SharedPreferences prefs = await SharedPreferences.getInstance();
//     email = prefs.getString('emailActeur');
//     if (email != null) {
//       // Si l'email de l'acteur est présent, exécute checkLoggedIn
//       acteur = Provider.of<ActeurProvider>(context, listen: false).acteur!;
//       typeActeurData = acteur.typeActeur!;
//       type = typeActeurData.map((data) => data.libelle).join(', ');
//       cartItems = Provider.of<CartProvider>(context, listen: false).cartItems;
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


//   void fetchProduitByCategorieProduit(String idCategorie) async {
//     try {
//       final response = await http.get(Uri.parse(
//           // 'https://koumi.ml/api-koumi/Stock/categorieAndMagasin/$idCategorie'));
//           'http://10.0.2.2:9000/api-koumi/Stock/categorieProduit/$idCategorie'));
//       if (response.statusCode == 200) {
//         final String jsonString = utf8.decode(response.bodyBytes);
//         List<dynamic> data = json.decode(jsonString);
//         setState(() {
//           stock = data
//               .where((stock) => stock['statutSotck'] == true)
//               .map((item) => Stock(
//                     idStock: item['idStock'] as String,
//                     nomProduit: item['nomProduit'] as String,
//                     photo: item['photo'] ?? '',
//                     quantiteStock: item['quantiteStock'] ?? 0,
//                     prix: item['prix'] ?? 0,
//                     formeProduit: item['formeProduit'] as String,
//                     typeProduit: item['typeProduit'] as String,
//                     descriptionStock: item['descriptionStock'] as String,
//                     speculation: Speculation(
//                       idSpeculation: item['speculation']['idSpeculation'], 
//                       codeSpeculation: item['speculation']['codeSpeculation'], 
//                       nomSpeculation: item['speculation']['nomSpeculation'],
//                        descriptionSpeculation: item['speculation']['descriptionSpeculation'], 
//                        statutSpeculation: item['speculation']['statutSpeculation'],
//                         ),
//                         acteur:Acteur(
//                         idActeur:item['acteur']['idActeur'],
//                         nomActeur:item['acteur']['nomActeur'],
//                         ),
//                        unite: Unite(
//                         nomUnite: item['unite']['nomUnite'],
//                         sigleUnite: item['unite']['sigleUnite'],
//                         description: item['unite']['description'],
//                         statutUnite: item['unite']['statutUnite'],
//                        ), 
//                   ))
//               .toList();
//         });
//         debugPrint("Produit : ${stock.map((e) => e.nomProduit)}");
//       } else {
//         throw Exception('Failed to load stock');
//       }
//     } catch (e) {
//       print('Error fetching stock: $e');
//     }
//   }
//   void fetchProduitByCategorie(String idCategorie, String idMagasin) async {
//     try {
//       final response = await http.get(Uri.parse(
//           // 'https://koumi.ml/api-koumi/Stock/categorieAndMagasin/$idCategorie/$idMagasin'));
//           'http://10.0.2.2:9000/api-koumi/Stock/categorieAndMagasin/$idCategorie/$idMagasin'));
//       if (response.statusCode == 200) {
//         final String jsonString = utf8.decode(response.bodyBytes);
//         List<dynamic> data = json.decode(jsonString);
//         setState(() {
//           stock = data
//               .where((stock) => stock['statutSotck'] == true)
//               .map((item) => Stock(
//                     idStock: item['idStock'] as String,
//                     nomProduit: item['nomProduit'] as String,
//                     photo: item['photo'] ?? '',
//                     quantiteStock: item['quantiteStock'] ?? 0,
//                     prix: item['prix'] ?? 0,
//                     formeProduit: item['formeProduit'] as String,
//                     typeProduit: item['typeProduit'] as String,
//                     descriptionStock: item['descriptionStock'] as String,
//                     speculation: Speculation(
//                       idSpeculation: item['speculation']['idSpeculation'], 
//                       codeSpeculation: item['speculation']['codeSpeculation'], 
//                       nomSpeculation: item['speculation']['nomSpeculation'],
//                        descriptionSpeculation: item['speculation']['descriptionSpeculation'], 
//                        statutSpeculation: item['speculation']['statutSpeculation'],
//                         ),
//                         acteur:Acteur(
//                         idActeur:item['acteur']['idActeur'],
//                         nomActeur:item['acteur']['nomActeur'],
//                         ),
//                        unite: Unite(
//                         nomUnite: item['unite']['nomUnite'],
//                         sigleUnite: item['unite']['sigleUnite'],
//                         description: item['unite']['description'],
//                         statutUnite: item['unite']['statutUnite'],
//                        ), 
//                   ))
//               .toList();
//         });
//         debugPrint("Produit : ${stock.map((e) => e.nomProduit)}");
//       } else {
//         throw Exception('Failed to load stock');
//       }
//     } catch (e) {
//       print('Error fetching stock: $e');
//     }
//   }

//   void fetchCategorie() async {
//     try {
//       final response = await http
//           // .get(Uri.parse('https://koumi.ml/api-koumi/Categorie/allCategorie'));
//           .get(Uri.parse('http://10.0.2.2:9000/api-koumi/Categorie/allCategorie'));
//       if (response.statusCode == 200) {
//         final String jsonString = utf8.decode(response.bodyBytes);
//         List<dynamic> data = json.decode(jsonString);
//         setState(() {
//           categorieProduit = data
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
//          isExist ?  fetchProduitByCategorie(selectedCategorieProduit, widget.id!) : fetchProduitByCategorieProduit(selectedCategorieProduit);
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
// categorieProduit[_tabController!.index].libelleCategorie!;
//     isExist ? fetchProduitByCategorie(selectedCategorieProduit, widget.id!) : fetchProduitByCategorieProduit(selectedCategorieProduit);
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
//       // fetchProduitByCategorie(selectedCategorieProduit);
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
//             actions:  isExist ? null : [
//                cartItems.isEmpty ?
//               PopupMenuButton<String>(
//               padding: EdgeInsets.zero,
//               itemBuilder: (context) {
//                 print("Type: $type");
//         return stock.any((element) => element.acteur!.idActeur == acteur.idActeur)
//                     ? <PopupMenuEntry<String>>[
//                         PopupMenuItem<String>(
//                           child: ListTile(
//                             leading: const Icon(
//                               Icons.remove_red_eye,
//                               color: Colors.green,
//                             ),
//                             title: const Text(
//                               "Mes Produits",
//                               style: TextStyle(
//                                 color: Colors.green,
//                                 fontWeight: FontWeight.bold,
//                               ),
//                             ),
//                             onTap: () async {
//                               Navigator.push(
//                                   context,
//                                   MaterialPageRoute(
//                                       builder: (context) => ProduitActeurScreen()));
//                             },
//                           ),
//                         ),
//                       ]
//                     : <PopupMenuEntry<String>>[
//                         PopupMenuItem<String>(
//                           child: ListTile(
//                             leading: const Icon(
//                               Icons.add,
//                               color: Colors.green,
//                             ),
//                             title: const Text(
//                               "Ajouter produit",
//                               style: TextStyle(
//                                 color: Colors.green,
//                                 fontWeight: FontWeight.bold,
//                               ),
//                             ),
//                             onTap: () async {
//                               Navigator.push(
//                                   context,
//                                   MaterialPageRoute(
//                                       builder: (context) =>
//                                           AddAndUpdateProductScreen(isEditable: isEditable,)));
//                             },
//                           ),
//                         ),
//                       ];
//               },
//             )
              
//        : Row(
//             children: [
//               Consumer<CartProvider>(
//                 builder: (context, cartProvider, child) {
//                   return badges.Badge(
//                     badgeStyle: badges.BadgeStyle(
//                       badgeColor: Colors.red,
//                     ),
//                     position: badges.BadgePosition.bottomEnd(bottom: 1, end: 1),
//                     badgeContent: Text(
//                       cartProvider.cartItems.length.toString(),
//                       style: const TextStyle(
//                         color: Colors.white,
//                       ),
//                     ),
//                     child: IconButton(
//                       color: Colors.blue,
//                       icon: const Icon(Icons.local_mall),
//                       iconSize: 25,
//                       onPressed: () {
//                         Navigator.push(
//                             context,
//                             MaterialPageRoute(
//                                 builder: (BuildContext ctx) =>
//                                      Panier()));
//                       },
//                     ),
//                   );
//                 },
//               ),
//               const SizedBox(
//                 width: 5,
//               )
//             ],
//           ) 
//         ],
//           centerTitle: true,
//           toolbarHeight: 100,
//           // leading: IconButton(
//           //     onPressed: () {
//           //       Navigator.of(context).pop();
//           //     },
//           //     icon: const Icon(Icons.arrow_back_ios, color: d_colorGreen)),
//           title: Text(
//             'Produits',
//             style: const TextStyle(
//                 color: d_colorGreen, fontWeight: FontWeight.bold),
//           ),
        
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
//                 const SizedBox(height: 10),
//               !isExist ? Flexible(
//                   child: GestureDetector(
//                     child:  TabBarView(
//                       controller: _tabController,
//                       children:  categorieProduit.map((categorie) {
//                         return buildGridViews(
//                             categorie.idCategorieProduit!);
//                       }).toList(),
//                     ) ,
//                   ),
//                 ) :  Flexible(
//                   child: GestureDetector(
//                     child:  TabBarView(
//                       controller: _tabController,
//                       children:  categorieProduit.map((categorie) {
//                         return buildGridView(
//                             categorie.idCategorieProduit!,  widget.id!);
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

  
//   Widget buildGridView(String idCategorie, String idMagasin) {
//     List<Stock> filteredStocks = stock;
//     String searchText = "";
  
 
//     if (filteredStocks.isEmpty) {
//              return  SingleChildScrollView(
//           child: Center(
//             child: Column(
//               children: [
//                 Image.asset('assets/images/notif.jpg'),
//                 SizedBox(
//                   height: 10,
//                 ),
//                   Center(
//                     child: Text(
//                       textAlign: TextAlign.justify,
//                       'Aucun produit trouvé ' +
//                           " dans la categorie " +
//                           selectedCategorieProduitNom.toUpperCase(),
//                       style: TextStyle(fontSize: 16),
//                     ),
//                   )
//               ],
//             ),
//           ),
//         );
   
//     } else {
//       List<Stock> filteredStocksSearch = filteredStocks.where((stock) {
//         String nomProduit = stock.nomProduit!.toLowerCase();
//         searchText = _searchController.text.toLowerCase();
//         return nomProduit.contains(searchText);
//       }).toList();

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
//                 height: 120, // Taille de la photo
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
//               const SizedBox(height: 3,),
//               Padding(
//   padding: const EdgeInsets.symmetric(horizontal: 4.0),
//   child: Row(
//     mainAxisAlignment: MainAxisAlignment.spaceBetween,
//     children: [
//       Text(
//         '${filteredStocksSearch[index].prix!.toInt()} FCFA', // Convertir en entier
//         style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, overflow:TextOverflow.ellipsis),
//       ),
//       Container(
//         width: 30, // Largeur du conteneur réduite
//         height: 30, // Hauteur du conteneur réduite
//         decoration: BoxDecoration(
//           color: Colors.blue, // Couleur de fond du bouton
//           borderRadius: BorderRadius.circular(15), // Coins arrondis du bouton
//         ),
//         child: IconButton(
//           onPressed: () {
//             // Action à effectuer lorsque le bouton est pressé
//             if (filteredStocksSearch[index].acteur!.idActeur! == acteur.idActeur!){
//                         Snack.error(titre: "Alerte", message: "Désolé!, Vous ne pouvez pas commander un produit qui vous appartient");
//                         }else{
//                           Provider.of<CartProvider>(context, listen: false)
//                         .addToCart(filteredStocksSearch[index], 1, "");
//                         }
//             // Par exemple, ajouter le produit au panier
//           },
//           icon: Icon(Icons.add), // Icône du panier
//           color: Colors.white, // Couleur de l'icône
//           iconSize: 20, // Taille de l'icône réduite
//           padding: EdgeInsets.zero, // Aucune marge intérieure
//           splashRadius: 15, // Rayon de l'effet de pression réduit
//           tooltip: 'Ajouter au panier', // Info-bulle au survol de l'icône
//         ),
//       ),
//     ],
//   ),
// ),

//             ],
//           ),
//         ),
//       );
//     },
//    ),
//  );

//     }
//   }
//   Widget buildGridViews(String idCategorie) {
//     List<Stock> filteredStocks = stock;
//     String searchText = "";
  
 
//     if (filteredStocks.isEmpty) {
//        return  SingleChildScrollView(
//           child: Center(
//             child: Column(
//               children: [
//                 Image.asset('assets/images/notif.jpg'),
//                 SizedBox(
//                   height: 10,
//                 ),
//                   Center(
//                     child: Text(
//                       textAlign: TextAlign.justify,
//                       'Aucun produit trouvé ' +
//                           " dans la categorie " +
//                           selectedCategorieProduitNom.toUpperCase(),
//                       style: TextStyle(fontSize: 16),
//                     ),
//                   )
//               ],
//             ),
//           ),
//         );
   
//     } else {
//       List<Stock> filteredStocksSearch = filteredStocks.where((stock) {
//         String nomProduit = stock.nomProduit!.toLowerCase();
//         searchText = _searchController.text.toLowerCase();
//         return nomProduit.contains(searchText);
//       }).toList();

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
//                 height: 120, // Taille de la photo
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
//               const SizedBox(height: 3,),
//               Padding(
//   padding: const EdgeInsets.symmetric(horizontal: 4.0),
//   child: Row(
//     mainAxisAlignment: MainAxisAlignment.spaceBetween,
//     children: [
//       Text(
//         '${filteredStocksSearch[index].prix!.toInt()} FCFA', // Convertir en entier
//         style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, overflow:TextOverflow.ellipsis),
//       ),
//       Container(
//         width: 30, // Largeur du conteneur réduite
//         height: 30, // Hauteur du conteneur réduite
//         decoration: BoxDecoration(
//           color: Colors.blue, // Couleur de fond du bouton
//           borderRadius: BorderRadius.circular(15), // Coins arrondis du bouton
//         ),
//         child: IconButton(
//           onPressed: () {
//             // Action à effectuer lorsque le bouton est pressé
//             if (filteredStocksSearch[index].acteur!.idActeur! == acteur.idActeur!){
//                         Snack.error(titre: "Alerte", message: "Désolé!, Vous ne pouvez pas commander un produit qui vous appartient");
//                         }else{
//                           Provider.of<CartProvider>(context, listen: false)
//                         .addToCart(filteredStocksSearch[index], 1, "");
//                         }
//             // Par exemple, ajouter le produit au panier
//           },
//           icon: Icon(Icons.add), // Icône du panier
//           color: Colors.white, // Couleur de l'icône
//           iconSize: 20, // Taille de l'icône réduite
//           padding: EdgeInsets.zero, // Aucune marge intérieure
//           splashRadius: 15, // Rayon de l'effet de pression réduit
//           tooltip: 'Ajouter au panier', // Info-bulle au survol de l'icône
//         ),
//       ),
//     ],
//   ),
// ),

//             ],
//           ),
//         ),
//       );
//     },
//    ),
//  );

//     }
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

//   Widget _buildShimmerEffect() {
//     return Shimmer.fromColors(
//       baseColor: Colors.grey[300]!,
//       highlightColor: Colors.grey[100]!,
//       child: GridView.builder(
//         gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
//           crossAxisCount: 2,
//           mainAxisSpacing: 10,
//           crossAxisSpacing: 10,
//         ),
//         itemCount: 6,
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
// }