import 'package:badges/badges.dart' as badges;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:koumi/Admin/NotificationPage.dart';
import 'package:koumi/models/Acteur.dart';
import 'package:koumi/models/MessageWa.dart';
import 'package:koumi/models/TypeActeur.dart';
import 'package:koumi/providers/ActeurProvider.dart';
import 'package:koumi/screens/PinLoginScreen.dart';
import 'package:koumi/service/BottomNavigationService.dart';
import 'package:koumi/service/MessageService.dart';
import 'package:profile_photo/profile_photo.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CustomAppBar extends StatefulWidget implements PreferredSizeWidget {
  const CustomAppBar({super.key});

  @override
  State<CustomAppBar> createState() => _CustomAppBarState();
  @override
  Size get preferredSize => const Size.fromHeight(100.0);
}

const d_colorGreen = Color.fromRGBO(43, 103, 6, 1);
const d_colorOr = Color.fromRGBO(255, 138, 0, 1);

class _CustomAppBarState extends State<CustomAppBar> {
  late Acteur acteur = Acteur();
  late List<TypeActeur> typeActeurData = [];
  String type = '';
  List<MessageWa> messageList = [];
  String? email = "";
  bool isExist = false;

  void verify() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    email = prefs.getString('whatsAppActeur');
    if (email != null) {
      // Si l'email de l'acteur est présent, exécute checkLoggedIn
      acteur = Provider.of<ActeurProvider>(context, listen: false).acteur!;
      typeActeurData = acteur.typeActeur!;
      type = typeActeurData.map((data) => data.libelle).join(', ');
      setState(() {
        isExist = true;
      });
    } else {
      setState(() {
        isExist = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    // Vérifiez si acteur est non nul avant de l'attribuer à la variable locale
    // if (Provider.of<ActeurProvider>(context, listen: false).acteur != null) {
    verify();

    // }
    // debugPrint("Acteur : ${acteur.nomActeur}");
  }

  @override
  Widget build(BuildContext context) {
    return !isExist
        ? Padding(
            padding: const EdgeInsets.symmetric(vertical: 25, horizontal: 25),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Image.asset(
                  'assets/images/logo.png',
                  height: 48,
                  scale: 1,
                ),
                ElevatedButton.icon(
                  onPressed: () {
                    Future.microtask(() {
                      Provider.of<BottomNavigationService>(context,
                              listen: false)
                          .changeIndex(0);
                    });
                    Get.to(
                      PinLoginScreen(),
                      duration: Duration(seconds: 1),
                      transition: Transition.leftToRight,
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.blue,
                    padding: EdgeInsets.symmetric(vertical: 12, horizontal: 20),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                  ),
                  icon: Icon(
                    Icons.login,
                    color: const Color.fromARGB(255, 3, 100, 179),
                  ),
                  label: Text(
                    "Se connecter",
                    style: TextStyle(
                      fontSize: 18,
                      fontStyle: FontStyle.italic,
                      fontWeight: FontWeight.w800,
                      color: const Color.fromARGB(255, 3, 100, 179),
                    ),
                  ),
                ),
              ],
            ),
          )
        : Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Padding(
              padding: const EdgeInsets.all(5.0),
              child: Consumer<ActeurProvider>(
                builder: (context, acteurProvider, child) {
                  final ac = acteurProvider.acteur;
                  if (ac == null) {
                    return SizedBox();
                  }

                  List<TypeActeur> typeActeurData = ac.typeActeur!;
                  type = typeActeurData.map((data) => data.libelle).join(', ');
                  return ListTile(
                    leading: ac.logoActeur == null || ac.logoActeur!.isEmpty
                        ? ProfilePhoto(
                            totalWidth: 50,
                            cornerRadius: 50,
                            color: Colors.black,
                            image: const AssetImage('assets/images/profil.jpg'),
                          )
                        : ProfilePhoto(
                            totalWidth: 50,
                            cornerRadius: 50,
                            color: Colors.black,
                            image: NetworkImage(
                                "https://koumi.ml/api-koumi/acteur/${ac.idActeur}/image"),
                          ),
                    title: Text(
                      ac.nomActeur!.toUpperCase(),
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                          color: d_colorGreen,
                          fontSize: 18,
                          fontWeight: FontWeight.w800),
                    ),
                    subtitle: Text(
                      type,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                          color: d_colorOr,
                          fontSize: 17,
                          fontWeight: FontWeight.w400),
                    ),
                    trailing: badges.Badge(
                      position: badges.BadgePosition.topEnd(top: -8, end: -1),
                      badgeContent:
                          Consumer(builder: (context, messageService, child) {
                        return FutureBuilder(
                            future: MessageService()
                                .fetchMessageByActeur(ac.idActeur!),
                            builder: (context, snapshot) {
                              if (snapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return Text("0",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 17,
                                      fontWeight: FontWeight.w800,
                                    ));
                              }

                              if (!snapshot.hasData) {
                                return Text("0",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 17,
                                      fontWeight: FontWeight.w800,
                                    ));
                              } else {
                                messageList = snapshot.data!;
                                return Text(
                                  messageList.length.toString(),
                                  style: TextStyle(
                                      color: Colors.white, fontSize: 17),
                                );
                              }
                            });
                      }),
                      child: GestureDetector(
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => NotificationPage()));
                        },
                        child: Icon(
                          Icons.notifications_none_outlined,
                          size: 40,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          );
  }
}
//  IconButton(
//                   onPressed: () async{
//                      final acteurProvider = Provider.of<ActeurProvider>(
//                                 context,
//                                 listen: false);

//                             // Déconnexion avec le provider
//                             await acteurProvider.logout();
//                             SharedPreferences prefs =
//                                 await SharedPreferences.getInstance();
//                             await prefs.clear();
//                             //                   Navigator.pushReplacement(
//                             // context,
//                             // MaterialPageRoute(builder: (context) => LoginScreen()),
//                             //                        );
//                             Get.off(BottomNavigationPage(),
//                                 duration: Duration(
//                                     seconds:
//                                         1), //duration of transitions, default 1 sec
//                                 transition: Transition.leftToRight);
//                   },
//                   icon: Icon(
//                     Icons.login,
//                     color: d_colorGreen, // Ajout d'une couleur à l'icône
//                     size: 30, // Ajout d'une taille à l'icône
//                   ),
//                 ),