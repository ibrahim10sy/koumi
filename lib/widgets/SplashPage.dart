import 'package:flutter/material.dart';
import 'package:koumi/widgets/BottomNavigationPage.dart';
import 'package:lottie/lottie.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

const d_colorGreen = Color.fromRGBO(43, 103, 6, 1);
const d_colorOr = Color.fromRGBO(255, 138, 0, 1);

class _SplashPageState extends State<SplashPage> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    // _navigateToNextPage();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 247, 246, 246),
      body: Column(
        children: [
          Expanded(
            child: PageView(
              controller: _pageController,
              onPageChanged: (index) {
                setState(() {
                  _currentPage = index;
                });
              },
              children: [
                // Étape 1
                _buildStep1(
                    imagePath: 'assets/images/logo.png',
                    title: "Bienvenue sur koumi",
                    description:
                        "KOUMI est une application dédiée à l'agriculture, facilitant la mise en relation des principaux acteurs du secteur agricole. Pour vous offrir une meilleur expérience nous aurons besoin d'accèder à la géolocalisation"),
                _buildStep(
                  animationPath: 'assets/anime.json',
                  title: 'Pourquoi la localisation est requise ?',
                  description:
                      "Nous avons besoin de votre localisation pour vous fournir des services adaptés à votre emplacement, comme des recommandations personnalisées sur des produits et des alertes géolocalisées.Pour en savoir plus, veuillez consulter notre politique de condifentialité dans '\Profil'. ",
                ),
                // Étape 2
                _buildStep(
                  animationPath: 'assets/gps.json',
                  title: 'Distance Tracker',
                  description:
                      "La fonctionnalité Distance Tracker permet de suivre et de calculer en arrière-plan la distance parcourue par un utilisateur, à l'aide du GPS intégré de son appareil. Cette solution est particulièrement utile dans des scénarios agricoles pour estimer les zones couvertes lors des activités comme la fertilisation, la pulvérisation ou la récolte.",
                ),
              ],
            ),
          ),
          // Indicateurs de pagination
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              3,
              (index) => _buildPageIndicator(index),
            ),
          ),
          const SizedBox(height: 20),
          // Boutons Passer/Suivant
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Bouton "Passer"
                TextButton(
                  onPressed: () {
                    _navigateToNextPage();
                  },
                  child: const Text(
                    "Passer",
                    style: TextStyle(color: d_colorOr, fontSize: 16),
                  ),
                ),
                // Bouton "Suivant"
                TextButton(
                  onPressed: () {
                    if (_currentPage == 2) {
                      _navigateToNextPage();
                    } else {
                      _pageController.nextPage(
                        duration: const Duration(microseconds: 300),
                        curve: Curves.easeInOut,
                      );
                    }
                  },
                  child: const Text(
                    "Suivant",
                    style: TextStyle(color: d_colorOr, fontSize: 16),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Indicateur de pagination
  Widget _buildPageIndicator(int index) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4.0),
      width: _currentPage == index ? 14.0 : 10.0,
      height: 10.0,
      decoration: BoxDecoration(
        color: _currentPage == index ? d_colorOr : d_colorGreen,
        borderRadius: BorderRadius.circular(4.0),
      ),
    );
  }

  // Méthode pour construire une étape
  Widget _buildStep({
    required String animationPath,
    required String title,
    required String description,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 30.0, vertical: 40.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Lottie.asset(animationPath, width: 200, height: 200),
          const SizedBox(height: 30),
          Text(
            title,
            style: const TextStyle(
              color: Colors.black,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            description,
            textAlign: TextAlign.justify,
            style: const TextStyle(
              color: Colors.black,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStep1({
    required String imagePath,
    required String title,
    required String description,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 30.0, vertical: 40.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(
            imagePath,
            height: 200,
            width: 200,
          ),
          const SizedBox(height: 30),
          Text(
            title,
            style: const TextStyle(
              color: Colors.black,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            description,
            textAlign: TextAlign.justify,
            style: const TextStyle(
              color: Colors.black,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  // Navigation vers la page suivante
  void _navigateToNextPage() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => BottomNavigationPage()),
    );
  }
}
