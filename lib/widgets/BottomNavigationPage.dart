import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:koumi/screens/Acceuil.dart';
import 'package:koumi/screens/MyProduct.dart';
import 'package:koumi/screens/Panier.dart';
import 'package:koumi/screens/Profil.dart';
import 'package:koumi/service/BottomNavigationService.dart';
import 'package:provider/provider.dart';

import 'connection_verify.dart';

class BottomNavigationPage extends StatefulWidget {
  // String? iso;
  BottomNavigationPage({super.key});

  @override
  State<BottomNavigationPage> createState() => _BottomNavigationPageState();
}

const d_color = Color.fromRGBO(254, 243, 231, 1);
const d_colorPage = Color.fromRGBO(255, 255, 255, 1);
const d_colorOr = Color.fromRGBO(254, 243, 231, 1);

class _BottomNavigationPageState extends State<BottomNavigationPage> {
  int activePageIndex = 0;
  Future<bool> _onBackPressed() async {
    // Essayez de revenir en arrière dans la pile de navigation actuelle
    final NavigatorState? navigator =
        _navigatorKeys[activePageIndex].currentState;
    if (navigator != null && navigator.canPop()) {
      // S'il y a une page précédente, pop la page
      navigator.pop();
      return false; // Indiquez que l'événement de retour a été géré
    }
    return true; // Indiquez que l'application peut se fermer
  }
 
  final List<GlobalKey<NavigatorState>> _navigatorKeys = [
    GlobalKey<NavigatorState>(),
    GlobalKey<NavigatorState>(),
    GlobalKey<NavigatorState>(),
    GlobalKey<NavigatorState>(),
  ];
  List pages = <Widget>[
    const Accueil(),
    MyProductScreen(),
    Panier(),
    const Profil()
  ];

  void _changeActivePageValue(int index) {
    setState(() {
      activePageIndex = index;
    });
  }

  void _onItemTap(int index) {
    Provider.of<BottomNavigationService>(context, listen: false)
        .changeIndex(index);
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    Future.microtask(() {
      Provider.of<BottomNavigationService>(context, listen: false)
          .changeIndex(0);
    });
    Get.put(ConnectionVerify(), permanent: true);
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        final isFirstRouteInCurrentTab =
            !await _navigatorKeys[activePageIndex].currentState!.maybePop();
        return isFirstRouteInCurrentTab;
      },
      child: Scaffold(
        backgroundColor: d_colorPage,
        appBar: AppBar(
          toolbarHeight: 0,
          elevation: 0,
        ),
        body: Consumer<BottomNavigationService>(
          builder: (context, bottomService, child) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              _changeActivePageValue(bottomService.pageIndex);
            });
            return Stack(
              children: [
                _buildOffstageNavigator(0),
                _buildOffstageNavigator(1),
                _buildOffstageNavigator(2),
                _buildOffstageNavigator(3)
              ],
            );
          },
        ),
        bottomNavigationBar: BottomNavigationBar(
          backgroundColor: Colors.white,
          elevation: 5.0,
          items: const [
            BottomNavigationBarItem(
              backgroundColor: Color.fromARGB(255, 250, 250, 250),
              icon: Icon(Icons.home_filled),
              label: "Accueil",
            ),
            BottomNavigationBarItem(
              backgroundColor: Color.fromARGB(255, 250, 250, 250),
              icon: Icon(Icons.list_alt_sharp),
              label: "Produits",
            ),
            BottomNavigationBarItem(
              backgroundColor: Color.fromARGB(255, 250, 250, 250),
              icon: Icon(Icons.shopping_cart),
              label: "Panier",
            ),
            BottomNavigationBarItem(
              backgroundColor: Color.fromARGB(255, 250, 250, 250),
              icon: Icon(Icons.person_pin),
              label: "Profil",
            ),
          ],
          unselectedItemColor: Colors.black,
          selectedItemColor: Color(0xFFFF8A00),
          iconSize: 30,
          showUnselectedLabels: true,
          selectedLabelStyle: const TextStyle(color: Colors.black),
          currentIndex: activePageIndex,
          onTap: _onItemTap,
        ),
      ),
    );
  }

  Map<String, WidgetBuilder> _routeBuilders(BuildContext context, int index) {
    return {
      '/': (context) => pages[index],
    };
  }

  Widget _buildOffstageNavigator(int index) {
    var routeBuilders = _routeBuilders(context, index);

    return Offstage(
      offstage: activePageIndex != index,
      child: Navigator(
        key: _navigatorKeys[index],
        onGenerateRoute: (routeSettings) {
          return MaterialPageRoute(
            builder: (context) => routeBuilders[routeSettings.name]!(context),
          );
        },
      ),
    );
  }

  // Map<String, WidgetBuilder> _routeBuilders(BuildContext context, int index) {
  //   return {
  //     '/': (context) {
  //       return [const Accueil(), ProduitScreen(), Panier(), const Profil()]
  //           .elementAt(index);
  //     },
  //   };
  // }

  // Widget _buildOffstageNavigator(int index) {
  //   var routeBuilders = _routeBuilders(context, index);

  //   return Offstage(
  //     offstage: activePageIndex != index,
  //     child: Navigator(
  //       key: _navigatorKeys[index],
  //       onGenerateRoute: (routeSettings) {
  //         return MaterialPageRoute(
  //           builder: (context) => routeBuilders[routeSettings.name]!(context),
  //         );
  //       },
  //     ),
  //   );
  // }
}
