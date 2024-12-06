import 'package:flutter/material.dart';

class TermsConditionsPage extends StatefulWidget {
  @override
  _TermsConditionsPageState createState() => _TermsConditionsPageState();
}

const d_colorOr = Color.fromRGBO(255, 138, 0, 1);

class _TermsConditionsPageState extends State<TermsConditionsPage> {
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
            Navigator.of(context).pop();
          },
          icon:
              const Icon(Icons.arrow_back_sharp, size: 30, color: Colors.white),
        ),
        title: const Text(
          "Conditions et Politique",
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Bienvenue sur KOUMI",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                "KOUMI est une application dédiée à l'agriculture, facilitant la mise en relation des principaux acteurs du secteur agricole. Nous vous invitons à lire attentivement nos conditions générales d'utilisation et notre politique de confidentialité.",
                style: TextStyle(
                  fontSize: 16,
                  height: 1.5,
                ),
                textAlign: TextAlign.justify,
              ),
              const SizedBox(height: 20),
              const Text(
                "Conditions Générales",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 10),
              _buildSection(
                "1. Modifications des Conditions d'Utilisation",
                "Nous nous réservons le droit de modifier, à tout moment et à notre seule discrétion, tout ou partie des présentes conditions d'utilisation. L'utilisation continue de l'application après les modifications implique votre acceptation.",
              ),
              _buildSection(
                "2. Propriété des Soumissions",
                "Toute information soumise via KOUMI (commentaires, idées, etc.) devient la propriété exclusive de KOUMI et peut être utilisée sans compensation envers vous.",
              ),
              _buildSection(
                "3. Inscription et Notifications",
                "En vous inscrivant, vous acceptez de recevoir des notifications sur les produits agricoles, équipements en vente/location, et autres services via WhatsApp ou d'autres canaux.",
              ),
              _buildSection(
                "4. Limite d'Âge",
                "L'inscription à KOUMI est interdite aux personnes de moins de 13 ans.",
              ),
              _buildSection(
                "5. Désinscription",
                "Pour vous désinscrire des notifications WhatsApp, envoyez \"STOP\" au +223 51 55 48 51. Une confirmation vous sera envoyée.",
              ),
              const SizedBox(height: 20),
              const Text(
                "Politique de Confidentialité",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 10),
              _buildSection(
                "1. Collecte des Données Personnelles",
                "Nous collectons des informations nécessaires pour fournir nos services, comme votre nom, numéro de téléphone, localisation et préférences. Ces données sont utilisées uniquement pour améliorer votre expérience sur KOUMI.",
              ),
              _buildSection(
                "2. Accès à la Localisation",
                "L'accès à votre localisation nous permet de :\n"
                    "- Mettre en avant des produits disponibles dans votre pays.\n"
                    "- Afficher automatiquement les localités de votre pays lors de la création de compte.\n"
                    "- Suivre votre position en arrière-plan pour calculer la superficie de la surface parcourue, utile dans des scénarios agricoles.",
              ),
              _buildSection(
                "3. Utilisation des Données",
                "Vos données personnelles servent à fournir des services personnalisés, comme des notifications en temps réel, des recommandations de produits, et des analyses géographiques.",
              ),
              _buildSection(
                "4. Protection des Données",
                "KOUMI s'engage à sécuriser vos informations personnelles. Vos données sont stockées de manière sécurisée et ne sont jamais partagées sans votre consentement.",
              ),
              const SizedBox(height: 20),
              const Text(
                "Contacts",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: d_colorOr,
                ),
              ),
              const SizedBox(height: 10),
              _buildContactSection(
                "Adresse :",
                "Baco Djicoroni, Bamako, Mali",
              ),
              _buildContactSection(
                "Numéro :",
                "+223 51 55 48 51",
              ),
              _buildContactSection(
                "Email :",
                "contact@aismali.com",
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSection(String title, String content) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            content,
            textAlign: TextAlign.justify,
            style: const TextStyle(
              fontSize: 16,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactSection(String title, String content) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(width: 5),
          Expanded(
            child: Text(
              content,
              style: const TextStyle(
                fontSize: 16,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
