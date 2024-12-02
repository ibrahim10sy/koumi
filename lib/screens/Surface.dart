import 'package:flutter/material.dart';
import 'package:koumi/models/Acteur.dart';
import 'package:koumi/providers/ActeurProvider.dart';
import 'package:koumi/screens/CampagnePage.dart';
import 'package:koumi/screens/SuperficiePage.dart';
import 'package:get/get.dart';
import 'package:koumi/service/BottomNavigationService.dart';
import 'package:koumi/widgets/BottomNavBarAdmin.dart';
import 'package:koumi/widgets/BottomNavigationPage.dart';
import 'package:provider/provider.dart';

class Surface extends StatefulWidget {
  const Surface({super.key});

  @override
  State<Surface> createState() => _SurfaceState();
}

const d_colorGreen = Color.fromRGBO(43, 103, 6, 1);
const d_colorOr = Color.fromRGBO(255, 138, 0, 1);

class _SurfaceState extends State<Surface> {
  Acteur? acteur;
  @override
  void initState() {
    super.initState();
    acteur = Provider.of<ActeurProvider>(context, listen: false).acteur!;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 250, 250, 250),
      appBar: AppBar(
        backgroundColor: d_colorOr,
        centerTitle: true,
        toolbarHeight: 75,
        leading: IconButton(
            onPressed: () {
              final List<String> type =
                  acteur!.typeActeur!.map((e) => e.libelle!).toList();
              if (type.contains('admin') || type.contains('Admin')) {
                Get.offAll(BottomNavBarAdmin(),
                    transition: Transition.leftToRight);
                Provider.of<BottomNavigationService>(context, listen: false)
                    .changeIndex(2);
              } else {
                Get.offAll(BottomNavigationPage(),
                    transition: Transition.leftToRight);
                Provider.of<BottomNavigationService>(context, listen: false)
                    .changeIndex(2);
              }
            },
            icon: const Icon(Icons.arrow_back_sharp,
                size: 30, color: Colors.white)),
        title: Text(
          "Surface cultiver",
          style: const TextStyle(
              color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
                padding: EdgeInsets.symmetric(
                  vertical: MediaQuery.of(context).size.height * 0.02,
                  horizontal: MediaQuery.of(context).size.width * 0.05,
                ),
                child: Container(
                  width: MediaQuery.of(context).size.width * 0.9,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(15),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.2),
                        offset: const Offset(0, 2),
                        blurRadius: 5,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      getList(
                          "zone.png",
                          'Superficie cultiver',
                          const SuperficiePage(),
                          const Icon(
                            Icons.chevron_right_sharp,
                            size: 30,
                          )),
                      const Divider(
                        color: Colors.grey,
                        height: 4,
                        thickness: 1,
                        indent: 50,
                        endIndent: 0,
                      ),
                      getList(
                          "cereale.png",
                          'Campagne agricole',
                          const CampagnePage(),
                          const Icon(
                            Icons.chevron_right_sharp,
                            size: 30,
                          )),
                    ],
                  ),
                ))
          ],
        ),
      ),
    );
  }

  Widget getList(String imgLocation, String text, Widget page, Icon icon2) {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => page),
          );
        },
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                SizedBox(
                  width: MediaQuery.of(context).size.width * 0.07,
                  child: Image.asset(
                    "assets/images/$imgLocation",
                    fit: BoxFit
                        .cover, // You can adjust the BoxFit based on your needs
                  ),
                ),
                const SizedBox(
                  width: 15,
                ),
                Text(
                  text,
                  style: const TextStyle(
                    fontSize: 18,
                    color: Colors.black87,
                    overflow: TextOverflow.ellipsis,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            icon2
          ],
        ),
      ),
    );
  }
}
