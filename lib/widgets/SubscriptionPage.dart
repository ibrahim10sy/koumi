import 'package:flutter/material.dart';
import 'package:koumi/widgets/NextSubscriptionPage.dart';

class SubscriptionPage extends StatefulWidget {
  @override
  _SubscriptionPageState createState() => _SubscriptionPageState();
}

const d_colorGreen = Color.fromRGBO(43, 103, 6, 1);
const d_colorOr = Color.fromRGBO(255, 138, 0, 1);

class _SubscriptionPageState extends State<SubscriptionPage> {
  // Variable pour stocker l'option sélectionnée
  String selectedPlan = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: d_colorOr,
        toolbarHeight: 75,
        leading: IconButton(
          onPressed: () {
             Navigator.pop(context, true);
          },
          icon: const Icon(
            Icons.arrow_back_ios,
            color: Colors.white,
          ),
        ),
        title: const Text(
          "Abonnement",
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 20),
            Text(
              'Veuillez Choisir un plan d\'abonnement',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            SizedBox(height: 20),

            GestureDetector(
              onTap: () {
                setState(() {
                  selectedPlan = 'semestriel';
                });
              },
              child: SubscriptionOption(
                title: 'Abonnement 6 mois',
                price: 'semestriel',
                description: 'Accès complet pour 6 mois',
                isSelected: selectedPlan == 'semestriel',
              ),
            ),
            SizedBox(height: 20),

            GestureDetector(
              onTap: () {
                setState(() {
                  selectedPlan = 'annuel';
                });
              },
              child: SubscriptionOption(
                title: 'Abonnement 12 mois',
                price: 'annuel',
                description: 'Accès complet pour 1 an',
                isSelected: selectedPlan == 'annuel',
              ),
            ),

            SizedBox(height: 30),

            // Spacer pour pousser le contenu vers le haut
            Spacer(),

            // Bouton pour s'abonner fixé en bas
            Center(
              child: ElevatedButton(
                onPressed: () {
                  if (selectedPlan.isEmpty) {
                    // Alerte si aucun plan n'est sélectionné
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                          content: Text('Veuillez sélectionner un abonnement')),
                    );
                  } else {}
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => Nextsubscriptionpage(
                              selectedPlan: selectedPlan)));
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: d_colorOr,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  minimumSize: const Size(250, 40),
                ),
                child: Text(
                  'S\'abonner',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Widget pour les options d'abonnement
class SubscriptionOption extends StatelessWidget {
  final String title;
  final String price;
  final String description;
  final bool isSelected;

  SubscriptionOption({
    required this.title,
    required this.price,
    required this.description,
    this.isSelected = false,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Container(
        decoration: BoxDecoration(
          color: isSelected
              ? Colors.green[100]
              : const Color.fromARGB(
                  255, 245, 243, 243), // Surbrillance si sélectionné
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.3),
              spreadRadius: 3,
              blurRadius: 5,
              offset: Offset(0, 3),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              // Ajouter la puce de sélection
              Radio(
                value: true,
                groupValue:
                    isSelected, // Indique si cette option est sélectionnée
                onChanged: (bool? value) {
                  // La gestion de la sélection se fait dans le parent
                },
                activeColor: Colors.green, // Couleur de la puce sélectionnée
              ),
              SizedBox(width: 10),

              // Contenu des informations d'abonnement
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    SizedBox(height: 5),
                    Text(
                      price,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                    ),
                    SizedBox(height: 5),
                    Text(
                      description,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.black54,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
