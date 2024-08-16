
//  import 'dart:convert';
// import 'dart:io';

// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:http/http.dart' as http;
// import 'package:koumi_app/models/Acteur.dart';
// import 'package:koumi_app/models/Magasin.dart';
// import 'package:koumi_app/models/Niveau1Pays.dart';
// import 'package:koumi_app/models/TypeActeur.dart';
// import 'package:koumi_app/providers/ActeurProvider.dart';
// import 'package:koumi_app/screens/MagasinActeur.dart';
// import 'package:koumi_app/screens/Produit.dart';
// import 'package:provider/provider.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:shimmer/shimmer.dart';

// import '../service/MagasinService.dart';

// class MagasinScreen extends StatefulWidget {
//   const MagasinScreen({super.key});

//   @override
//   State<MagasinScreen> createState() => _MagasinScreenState();
// }

// class _MagasinScreenState extends State<MagasinScreen>     with TickerProviderStateMixin {
 
 
  
//   TabController? _tabController;
//   late TextEditingController _searchController;

//   // List<Magasin> magasin = [];
//   late Acteur acteur = Acteur();
//   late List<TypeActeur> typeActeurData = [];
//   late String type;
//   List<Niveau1Pays> niveau1Pays = [];
//   String selectedRegionId =
//       ''; // Ajoutez une variable pour stocker l'ID de la région sélectionnée

//   double scaleFactor = 1;
//   bool isVisible = true;

//   String localiteMagasin = "";
//   String contactMagasin = "";
//   File? photo;
//   String searchText = "";

//        MagasinController  
//    _controller = Get.put(MagasinController() );



//   Future<void> fetchRegions() async {
//     try {
//       final response = await http
//           // .get(Uri.parse('https://koumi.ml/api-koumi/niveau1Pays/read'));
//           .get(Uri.parse('http://10.0.2.2:9000/api-koumi/niveau1Pays/read'));
//       if (response.statusCode == 200) {
//         final String jsonString = utf8.decode(response.bodyBytes);
//         List<dynamic> data = json.decode(jsonString);
//         setState(() {
//           niveau1Pays = data
//               .where((niveau1Pays) => niveau1Pays['statutN1'] == true)
//               .map((item) => Niveau1Pays(
//                   idNiveau1Pays: item['idNiveau1Pays'] as String,
//                   statutN1: item['statutN1'] as bool,
//                   nomN1: item['nomN1']))
//               .toList();

//         _tabController = TabController(length: niveau1Pays.length, vsync: this);
//         _tabController!.addListener(_handleTabChange);
//                     // selectedRegionId = niveau1Pays.first.idNiveau1Pays!;

//          // Fetch les magasins pour la première région
//         //  _controller.fetchMagasinByRegion(niveau1Pays.first.idNiveau1Pays!);
//         });


//               // controller.fetchMagasinByRegion(niveau1Pays.isNotEmpty ? niveau1Pays[_tabController!.index].idNiveau1Pays! : '');
//     // Appel de _handleTabChange pour capturer automatiquement l'ID de la première région
//         // fetchMagasinByRegion(
//         //     niveau1Pays.isNotEmpty ? niveau1Pays.first.idNiveau1Pays! : '');
//       } else {
//         throw Exception('Failed to load regions');
//       }
//     } catch (e) {
//       print('Error fetching regions: $e');
//     }
//   }
      
  

 

//   void _handleTabChange() async {
//     if (_tabController != null &&
//         _tabController!.index >= 0 &&
//         _tabController!.index < niveau1Pays.length) {
//       selectedRegionId = niveau1Pays[_tabController!.index].idNiveau1Pays!;
//     //  await  _controller.fetchMagasinByRegion(selectedRegionId);
//        await _controller.fetchMagasinByRegion(selectedRegionId);
//     }
//   }
//    // Déclarer une variable pour stocker l'ID de l'onglet précédemment sélectionné




//   bool isExist = false;
//   String? email = "";

//   void verify() async {


//     SharedPreferences prefs = await SharedPreferences.getInstance();
//     email = prefs.getString('emailActeur');
//     if (email != null) {
//       // Si l'email de l'acteur est présent, exécute checkLoggedIn
//       acteur = Provider.of<ActeurProvider>(context, listen: false).acteur!;
//       // typeActeurData = acteur.typeActeur!;
//       // type = typeActeurData.map((data) => data.libelle).join(', ');
//       setState(() {
//         isExist = true;
//         if (niveau1Pays.isNotEmpty) {
//         _tabController = TabController(length: niveau1Pays.length, vsync: this);
//         _tabController!.addListener(_handleTabChange);
//       }
//       fetchRegions().then((value) => {
//                _controller.fetchMagasinByRegion(niveau1Pays.isNotEmpty ? niveau1Pays.first.idNiveau1Pays! : '')
//       });
//       // selectedRegionId = niveau1Pays.isNotEmpty ? niveau1Pays.first.idNiveau1Pays! : '';
//       });
//     } else {
//       setState(() {
//         isExist = false;
//       });
//       // fetchMagasinsByRegion(selectedRegionId);
//       //  _tabController = TabController(length: niveau1Pays.length, vsync: this);
//       //   _tabController!.addListener(_handleTabChange);
        
//     }
      
  

//   }


//   @override
//   void initState() {
//     verify();
//     super.initState();
//     _searchController = TextEditingController();
//     // _buildShimmerEffect();
//     _controller.isLoadingn.listen((isLoading) {
//     if (!isLoading) {
//       // Les données sont chargées, mettez à jour l'interface utilisateur
//       setState(() {
        
//       });
//     }
//   });
//   // Charger les régions
//   // fetchRegions();
//   }

//   @override
//   Widget build(BuildContext context) {
//     const d_colorGreen = Color.fromRGBO(43, 103, 6, 1);
//         return
//          Container(
//           child: DefaultTabController(
//             length: niveau1Pays.length,
//             child: Scaffold(
//               backgroundColor: const Color.fromARGB(255, 250, 250, 250),
//               appBar: AppBar(
//                 centerTitle: true,
//                 toolbarHeight: 100,
//                 leading: IconButton(
//                     onPressed: () {
//                       Navigator.of(context).pop();
//                     },
//                     icon: const Icon(Icons.arrow_back_ios, color: d_colorGreen)),
//                 title: Text('Tous les magasins'),
//                 bottom: TabBar(
//                   isScrollable: niveau1Pays.length > 4,
//                   labelColor: Colors.black,
//                   controller: _tabController, // Ajoutez le contrôleur TabBar
//                   tabs: niveau1Pays
//                       .map((region) => Tab(text: region.nomN1!))
//                       .toList(),
//                 ),
//                  actions: !isExist ? null :  [
//                  PopupMenuButton<String>(
//                     padding: EdgeInsets.zero,
//                     itemBuilder: (context) => <PopupMenuEntry<String>>[
                      
//                       PopupMenuItem<String>(
//                         child: ListTile(
//                           leading: const Icon(
//                             Icons.remove_red_eye,
//                             color: Colors.green,
//                           ),
//                           title: const Text(
//                             "Mes magasins",
//                             style: TextStyle(
//                               color: Colors.green,
//                               fontWeight: FontWeight.bold,
//                             ),
//                           ),
//                           onTap: () async {
//                             Navigator.push(
//                                 context,
//                                 MaterialPageRoute(
//                                     // builder: (context) => AaaaScreen()));
//                                     // builder: (context) => AaaaScreen()));
//                                     builder: (context) => MagasinActeurScreen()));
//                           },
//                         ),
//                       ),
                      
//                     ],
//                   )
//                 ],
//               ),
//               body: Padding(
//                 padding: const EdgeInsets.all(8.0),
//                 child: Column(
//                   children: [
//                     const SizedBox(height: 10),
//                     Padding(
//                       padding: const EdgeInsets.all(10.0),
//                       child: Container(
//                         padding: EdgeInsets.symmetric(horizontal: 10),
//                         decoration: BoxDecoration(
//                           color: Colors.blueGrey[50], // Couleur d'arrière-plan
//                           borderRadius: BorderRadius.circular(25),
//                         ),
//                         child: Row(
//                           children: [
//                             Icon(Icons.search,
//                                 color: Colors.blueGrey[400]), // Couleur de l'icône
//                             SizedBox(
//                                 width:
//                                     10), // Espacement entre l'icône et le champ de recherche
//                             Expanded(
//                               child: TextField(
//                                 controller: _searchController,
//                                 onChanged: (value) {
//                                   setState(() {});
//                                 },
//                                 decoration: InputDecoration(
//                                   hintText: 'Rechercher',
//                                   border: InputBorder.none,
//                                   hintStyle: TextStyle(
//                                       color: Colors.blueGrey[
//                                           400]), // Couleur du texte d'aide
//                                 ),
//                               ),
//                             ),
//                           ],
//                         ),
//                       ),
//                     ),
//                     const SizedBox(height: 10),
//                     // const SizedBox(height:10),
//                     Flexible(
//                       child: GestureDetector(
//                         child: 
//  TabBarView(
//    controller:
//        _tabController, // Ajoutez le contrôleur TabBarView
//    children: niveau1Pays.map((region) {
//      return buildGridView(region.idNiveau1Pays!);
//    }).toList(),
//  ),
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//           ),
               
//        );
      
//   }

//      Widget buildGridView(String id) {

//         debugPrint("taille : ${_controller.magasinListen.length}");
     
//      // Si aucun magasin n'est trouvé après le filtrage
//         List<Magasin> filteredMagasins = _controller.magasinListen.where((magasin) {
//       String nomMagasin = magasin.nomMagasin!.toString().toLowerCase();
//       searchText = _searchController.text.toLowerCase();
//       return nomMagasin.contains(searchText);
//     }).toList();

//     //   if (filteredMagasins.isEmpty) {
//     //   // Vous pouvez afficher une image ou un texte ici
//     //   return 
//     //   SingleChildScrollView(
//     //       child: Padding(
//     //         padding: EdgeInsets.all(10),
//     //         child: Center(
//     //           child: Column(
//     //             children: [
//     //               Image.asset('assets/images/notif.jpg'),
//     //               SizedBox(
//     //                 height: 10,
//     //               ),
//     //               Text(
//     //                 'Aucun magasin trouvé ' ,
//     //                 style: TextStyle(
//     //                   color: Colors.black,
//     //                   fontSize: 17,
//     //                   overflow: TextOverflow.ellipsis,
//     //                 ),
//     //               ),
//     //             ],
//     //           ),
//     //         ),
//     //       ),
//     //     );

//     // }
                                       
//       if (filteredMagasins.isEmpty &&  _searchController.text.isNotEmpty) {
//       // Vous pouvez afficher une image ou un texte ici
//       return 
//       SingleChildScrollView(
//           child: Padding(
//             padding: EdgeInsets.all(10),
//             child: Center(
//               child: Column(
//                 children: [
//                   Image.asset('assets/images/notif.jpg'),
//                   SizedBox(
//                     height: 10,
//                   ),
//                   Text(
//                     'Aucun magasin trouvé avec le nom ' + _searchController.text.toUpperCase(),
//                     style: TextStyle(
//                       color: Colors.black,
//                       fontSize: 17,
//                       overflow: TextOverflow.ellipsis,
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         );

//     }
//           debugPrint("m f : ${filteredMagasins.length}");
//            if (_controller.magasinListen.isEmpty) {
//       // Vous pouvez afficher une image ou un texte ici
//       return 
//       SingleChildScrollView(
//           child: Padding(
//             padding: EdgeInsets.all(10),
//             child: Center(
//               child: Column(
//                 children: [
//                   Image.asset('assets/images/notif.jpg'),
//                   SizedBox(
//                     height: 10,
//                   ),
//                   Text(
//                     'Aucun magasin trouvé ' ,
//                     style: TextStyle(
//                       color: Colors.black,
//                       fontSize: 17,
//                       overflow: TextOverflow.ellipsis,
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         );

//     } else{
//                                 return Obx(
//         () => _controller.isLoadingn.value
//                                   ? _buildShimmerEffect() :
 
//                                    Container(
//                                                             child: GridView.builder(
//                                                               gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
//                                                                 crossAxisCount: 2,
//                                                                 mainAxisSpacing: 2,
//                                                                 crossAxisSpacing: 10,
//                                                               ),
//                                                               itemCount: filteredMagasins.length,
//                                                               itemBuilder: (context, index) {
//                                                                 Magasin magasinn = filteredMagasins[index];
//                                                                 Magasin currentMagasin = magasinn;
//                                                                 String typeActeurList = '';
                                                  
//                                                                 // Vérifiez d'abord si l'acteur est disponible dans le magasin
//                                                                 if (currentMagasin.acteur != null &&
//                                                     currentMagasin.acteur!.typeActeur != null) {
//                                                   // Parcourez la liste des types d'acteurs et extrayez les libellés
//                                                   typeActeurList = currentMagasin.acteur!.typeActeur!
//                                                       .map((type) => type
//                                                           .libelle) // Utilisez la propriété libelle pour récupérer le libellé
//                                                       .join(', '); // Joignez tous les libellés avec une virgule
//                                                                 }
//                                                                 // ici on a recuperer les details du  magasin
//                                                                 // String magasin = filteredMagasins[index].photo!;
//                                                                 return GestureDetector(
//                                                          onTap: () {
//                                                         String id = magasinn.idMagasin!;
//                                                         String nom = magasinn.nomMagasin!;
                                                    
//                                                         Navigator.push(
//                                                           context,
//                                                           PageRouteBuilder(
//                                                             pageBuilder: (context, animation, secondaryAnimation) =>
//                                                                 ProduitScreen(
//                                                               id: id,
//                                                               nom: nom,
//                                                             ),
//                                                             transitionsBuilder:
//                                                                 (context, animation, secondaryAnimation, child) {
//                                                               var begin =
//                                   Offset(0.0, 1.0); // Commencer en bas de l'écran
//                                                               var end = Offset.zero; // Finir en haut de l'écran
//                                                               var curve = Curves.ease;
//                                                               var tween = Tween(begin: begin, end: end)
//                                   .chain(CurveTween(curve: curve));
//                                                               return SlideTransition(
//                                                                 position: animation.drive(tween),
//                                                                 child: child,
//                                                               );
//                                                             },
//                                                             transitionDuration: const Duration(
//                                                                 milliseconds: 1900), // Durée de la transition
//                                                           ),
//                                                         );
//                                                       },
//                                                   child: Column(
//                                                     children: [
//                                                              Container(
//                                                               // height: MediaQuery.sizeOf(context).height,
//                                       decoration: BoxDecoration(
//                                         color: Colors.white,
//                                         borderRadius: BorderRadius.circular(15),
//                                         boxShadow: [
//                                                 BoxShadow(
//                                                   color: Colors.grey
//                                                       .withOpacity(0.2),
//                                                   offset: const Offset(0, 2),
//                                                   blurRadius: 5,
//                                                   spreadRadius: 2,
//                                                 ),
//                                               ],
//                                       ),
//                                       child: Padding(
//                                         padding: const EdgeInsets.all(4.0),
//                                         child: Column(
//                                           crossAxisAlignment:
//                                               CrossAxisAlignment.stretch,
//                                           children: [
//                                             Padding(
//                                               padding: const EdgeInsets.all(8.0),
//                                               child: ClipRRect(
//                                                 borderRadius:
//                                                     BorderRadius.circular(8.0),
//                                                 child: SizedBox(
//                                                   height: 80,
//                                                   child: magasinn.photo == null
//                                                       ? Image.asset(
//                                                           "assets/images/magasin.png",
//                                                           fit: BoxFit.cover,
//                                                         )
//                                                       : Image.network(
//                                                           "https://koumi.ml/api-koumi/Magasin/${magasinn.idMagasin}/image",
//                                                           fit: BoxFit.cover,
//                                                           errorBuilder:
//                                                               (BuildContext
//                                                                       context,
//                                                                   Object
//                                                                       exception,
//                                                                   StackTrace?
//                                                                       stackTrace) {
//                                                             return Image.asset(
//                                                               'assets/images/magasin.png',
//                                                               fit: BoxFit.cover,
//                                                             );
//                                                           },
//                                                         ),
                                                        
//                                                 ),
//                                               ),
//                                             ),
//                                             // _buildItem(
//                                             //     "Nom :", magasin.nomMagasin!.toUpperCase()),
//                                          Column(
//                                                       children: [
//                                                            Padding(
//                                                padding: const EdgeInsets.all(4.0),
//                                                child: Row(
//                                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                                                  children: [
//                                                    Flexible(
//                                                      child: Text(
//                                                        "Nom",
//                                                        style: const TextStyle(
                                                       
//                                                            color: Colors.black87,
//                                                            fontWeight: FontWeight.w800,
//                                                            fontStyle: FontStyle.italic,
//                                                            overflow: TextOverflow.ellipsis,
//                                                            fontSize: 16),
//                                                      ),
//                                                    ),
//                                                    Flexible(
//                                                      child: Text(
//                                                        magasinn.nomMagasin!.toUpperCase(),
//                                                        style: const TextStyle(
//                                                            color: Colors.black,
//                                                            fontWeight: FontWeight.w800,
//                                                            overflow: TextOverflow.ellipsis,
//                                                            fontSize: 16),
//                                                      ),
//                                                    )
//                                                  ],
//                                                ),
//                                              ),
//                                             // _buildItem(
//                                             //     "Acteur ", type),
                                       
//                                                            ],
//                                          ),
                                            
//                                           ],
//                                         ),
//                                       ),
//                                     ),
                                                  
                                    
                                                     
//                                                     ],
//                                                   ),
//                                                                 );
//                                                               },
//                                                             ),
//                                 ));
//      }
                                
//                   // } else 
//     // } 
//               // );
    
//   }


 

//   Widget _buildShimmerEffect() {
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

  

// }






















































// import 'dart:convert';

// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;
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
//   ScrollController _scrollController = ScrollController();

//   String? email = "";
//   bool _isLoading = false;

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
//     if (selectedCat != null) {
//       stockListe = await StockService()
//           .fetchProduitByCategorie(selectedCat!.idCategorieProduit!);
//     }else if (selectedCat != null && widget.id != null) {
//       stockListe = await StockService().fetchProduitByCategorieAndMagasin(
//           selectedCat!.idCategorieProduit!, widget.id!);
//     }
    
//     return stockListe;
//   }

//   Future<List<Stock>> getAllStocks() async {
//      if(widget.id != null) {
//       stockListe = await StockService().fetchStockByMagasin(widget.id!);
//     } else{
//       stockListe = await StockService().fetchStock();
//     }
//     return stockListe;
//   }

//   // Méthode pour mettre à jour la liste de stocks
//   // void updateStockList() async {
//   //   try {
//   //     setState(() {
//   //       stockListeFuture = getAllStock();
//   //     });
//   //   } catch (error) {
//   //     print('Erreur lors de la mise à jour de la liste de stocks: $error');
//   //   }

//   // }


//   Future<List<Stock>> fetchMoreStocks() async{
//    if (selectedCat != null) {
//       stockListe = await StockService()
//           .fetchProduitByCategorie(selectedCat!.idCategorieProduit!);
//     }else if (selectedCat != null && widget.id != null) {
//       stockListe = await StockService().fetchProduitByCategorieAndMagasin(
//           selectedCat!.idCategorieProduit!, widget.id!);
//     }else if(widget.id != null) {
//       stockListe = await StockService().fetchStockByMagasin(widget.id!);
//     } else{
//       stockListe = await StockService().fetchStock();
//     }
//    return stockListe;
//    }

//    Future<void> _loadMoreStocks() async {
//   if (!_isLoading) {
//     setState(() {
//       _isLoading = true;
//     });

//     try {
//       // Appel à votre API pour charger plus de stocks
//       List<Stock> moreStocks = await fetchMoreStocks();

//       setState(() {
//         // Ajoutez les nouveaux stocks chargés à votre liste existante
//         stockListe.addAll(moreStocks);
//       });
//     } catch (e) {
//       print('Erreur lors du chargement de plus de stocks: $e');
//     } finally {
//       setState(() {
//         _isLoading = false;
//       });
//     }
//   }
// }


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
//         .get(Uri.parse('https://koumi.ml/api-koumi/Categorie/allCategorie'));
//     // updateStockList();
//     stockListeFuture = getAllStock();
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
//                   return Text("Une erreur s'est produite veuillez reessayer");
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
//             return FutureBuilder<List<Stock>>(
//                 future: selectedCat != null ?
//                 stockListeFuture : stockListeFuture1,
//                 // stockListeFuture  ,
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
//                           controller: _scrollController,
//                             shrinkWrap: true,
//                             physics: NeverScrollableScrollPhysics(),
//                             gridDelegate:
//                                 SliverGridDelegateWithFixedCrossAxisCount(
//                               crossAxisCount: 2,
//                               mainAxisSpacing: 10,
//                               crossAxisSpacing: 10,
//                               childAspectRatio: 0.8,
//                             ),
//                             itemCount: stockListe.where((element) => element.statutSotck == true)
//                             .length,
//                             itemBuilder: (context, index) {
//                               var e = stockListe
//                                   // .where((element) =>
//                                   //     element.statutSotck == true)
//                                   .elementAt(index);
//                       //         index == stockListe.length ?
//                       //          CircularProgressIndicator(
//                       //   color: Colors.orange,
//                       // )
//                       //          :
//                                GestureDetector(
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
