import 'package:flutter/material.dart';
import 'package:koumi/models/Acteur.dart';
import 'package:koumi/providers/ActeurProvider.dart';
import 'package:koumi/service/ActeurService.dart';
import 'package:koumi/service/BottomNavigationService.dart';
import 'package:koumi/widgets/BottomNavigationPage.dart';
import 'package:koumi/widgets/LoadingOverlay.dart';
import 'package:provider/provider.dart';
import 'package:get/get.dart';

class DeleteActeur extends StatefulWidget {
  Acteur? acteurs;
  DeleteActeur({super.key, this.acteurs});

  @override
  State<DeleteActeur> createState() => _DeleteActeurState();
}

const d_colorGreen = Color.fromRGBO(43, 103, 6, 1);
const d_colorOr = Color.fromRGBO(255, 138, 0, 1);

class _DeleteActeurState extends State<DeleteActeur> {
  String? _selectedReason;
  final List<String> _reasons = [
    "Application trop complexe à utiliser",
    "Je voulais seulement tester",
    "Non pertinence ",
    "Trop de bugs ",
  ];
  late Acteur acteur;
  bool _isLoading = false;

  @override
  void initState() {
    acteur = widget.acteurs!;
    super.initState();
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
              icon: const Icon(Icons.arrow_back_sharp,
                  size: 30, color: Colors.white)),
          title: Text(
            'Supprimer mon compte',
            style: const TextStyle(
                color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
          ),
        ),
        body: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  "Pourquoi nous quittez-vous ?",
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      color: Colors.black87),
                ),
              ),
              Column(
                children: _reasons.map((reason) {
                  return RadioListTile<String>(
                    title: Text(reason),
                    activeColor: d_colorOr,
                    value: reason,
                    groupValue: _selectedReason,
                    onChanged: (value) {
                      setState(() {
                        _selectedReason = value;
                      });
                    },
                  );
                }).toList(),
              ),
              SizedBox(height: 10),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  "Votre compte sera définitivement supprimé dans 24 heures. Un message de confirmation vous sera envoyé.",
                  textAlign: TextAlign.justify,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.black54,
                  ),
                ),
              ),
              SizedBox(height: 30),
              Center(
                child: ElevatedButton(
                  onPressed: () {
                    if (_selectedReason == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text("Veuillez sélectionner une raison."),
                          backgroundColor: Colors.redAccent,
                        ),
                      );
                    } else {
                      _showConfirmationDialog(context);
                    }
                  },
                  child: Text('Confirmer',
                      style: TextStyle(
                        fontSize: 20,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      )),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: d_colorOr,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    minimumSize: const Size(250, 40),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showConfirmationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Row(
            children: [
              Icon(Icons.info, color: d_colorOr),
              SizedBox(width: 8),
              Text('Confirmation'),
            ],
          ),
          content: Text(
              'Votre compte sera supprimé dans 24 heures. Vous recevrez un message de confirmation par e-mail.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text(
                'Annuler',
                style: TextStyle(color: d_colorOr),
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                // Navigator.of(context).pop();
                try {
                  setState(() {
                    _isLoading = true;
                  });
                  await ActeurService()
                      .demandeActeur(
                          idActeur: acteur.idActeur!, msg: _selectedReason!)
                      .then((onValue) async {
                    setState(() {
                      _isLoading = false;
                    });
                    print("Send");
                    final acteurProvider =
                        Provider.of<ActeurProvider>(context, listen: false);

                    // Déconnexion avec le provider
                    await acteurProvider.logout();

                    Get.offAll(BottomNavigationPage(),
                        transition: Transition.leftToRight);
                    Provider.of<BottomNavigationService>(context, listen: false)
                        .changeIndex(0);

                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Row(
                          children: [
                            Icon(Icons.check_circle, color: d_colorOr),
                            SizedBox(width: 8),
                            Text('Votre compte sera supprimé dans 24 heures.'),
                          ],
                        ),
                        duration: Duration(seconds: 5),
                      ),
                    );
                  }).catchError((onError) {
                    setState(() {
                      _isLoading = false;
                    });
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Row(
                          children: [
                            Icon(Icons.warning, color: d_colorOr),
                            SizedBox(width: 8),
                            Text('Une erreur s\'est produite. '),
                          ],
                        ),
                        duration: Duration(seconds: 3),
                      ),
                    );
                  });
                } catch (e) {
                  setState(() {
                    _isLoading = false;
                  });
                  print(e.toString());
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: d_colorOr,
              ),
              child: Text('Confirmer',
                  style: TextStyle(
                    color: Colors.white,
                  )),
            ),
          ],
        );
      },
    );
  }
}
//  Text(
//                 'Êtes-vous sûr de vouloir supprimer votre compte ?',
//                 textAlign: TextAlign.center,
//                 style: TextStyle(
//                   fontSize: 18,
//                   fontWeight: FontWeight.bold,
//                   color: Colors.black87,
//                 ),
//               ),