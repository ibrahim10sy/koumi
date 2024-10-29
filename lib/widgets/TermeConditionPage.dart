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
            icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          ),
          title: Text(
            "Conditions Générales",
            style: TextStyle(
                fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
          )),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Bienvenue sur KOUMI",
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10),
              // Texte de description général
              Text(
                "KOUMI est une application dédiée à l'agriculture, facilitant la mise en relation des principaux acteurs du secteur agricole, à savoir les producteurs, les fournisseurs d’intrants agricoles, les partenaires de développement, les prestataires, les commerçants et les transformateurs.",
                style: TextStyle(fontSize: 16),
              ),
              SizedBox(height: 20),
              // Sections de conditions
              _buildSectionTitle(
                  "1. Modifications des Conditions d'Utilisation"),
              _buildSectionText(
                "Nous nous réservons le droit de modifier, à tout moment et à notre seule discrétion, tout ou partie des présentes conditions d'utilisation, et ce sans préavis. Il vous incombe de consulter régulièrement ces conditions pour prendre connaissance de toute modification. L'utilisation continue de l'application après la publication des modifications implique votre acceptation de ces dernières.",
              ),
              _buildSectionTitle("2. Propriété des Soumissions"),
              _buildSectionText(
                "Toute information, suggestion, ou contenu que vous soumettez via KOUMI (par exemple, des commentaires ou des idées) ne sera pas considérée comme confidentielle. Vous acceptez que ces soumissions deviennent la propriété exclusive de KOUMI et pourront être utilisées à des fins commerciales ou autres, sans compensation, obligation, ou responsabilité envers vous.",
              ),
              _buildSectionTitle("3. Inscription et Notifications"),
              _buildSectionText(
                "En vous inscrivant à KOUMI, vous consentez à recevoir des notifications en temps réel, notamment des mises à jour sur les prix des produits agricoles, les intrants, les équipements en vente ou en location, ainsi que des services de transport. Vous recevrez également des alertes concernant l'ajout de nouveaux produits agricoles et intrants. Ces notifications peuvent être envoyées via WhatsApp ou d'autres canaux.",
              ),
              _buildSectionTitle("4. Consentement à Recevoir des Messages"),
              _buildSectionText(
                "En acceptant de recevoir des messages de KOUMI, vous consentez à recevoir des notifications par WhatsApp via un système de numérotation téléphonique automatique. Vous comprenez que votre consentement à recevoir ces messages n’est pas une condition obligatoire pour acheter des biens ou services via l'application.",
              ),
              _buildSectionTitle("5. Limite d'Âge"),
              _buildSectionText(
                "En vous inscrivant à KOUMI, vous confirmez avoir au moins 13 ans. L'inscription est interdite aux personnes n'ayant pas atteint cet âge minimum.",
              ),
              _buildSectionTitle("6. Désinscription"),
              _buildSectionText(
                "Vous pouvez vous désinscrire à tout moment des notifications WhatsApp en envoyant \"STOP\" au +223 51 55 48 51 via WhatsApp. Une confirmation de désinscription vous sera envoyée.",
              ),
              _buildSectionTitle("Engagement de Protection des Données"),
              _buildSectionText(
                "KOUMI s'engage à respecter la confidentialité et la sécurité de vos informations personnelles.",
              ),
              SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Text(
        title,
        style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.orangeAccent),
      ),
    );
  }

  Widget _buildSectionText(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Text(
        text,
        textAlign: TextAlign.justify,
        style: TextStyle(
          fontSize: 16,
          height: 1.5,
        ),
      ),
    );
  }
}
