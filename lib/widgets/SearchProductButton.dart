import 'package:flutter/material.dart';

class SearchProductButton extends StatelessWidget {
  final VoidCallback onTap;

  const SearchProductButton({Key? key, required this.onTap}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Container(
          width: MediaQuery.of(context).size.width * 0.9,
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
          decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: BorderRadius.circular(15.0),
          ),
          child: Row(
            children: [
              // Icône de recherche
              Icon(
                Icons.search, // Icône de recherche
                color: Colors.black54,
                size: 24.0,
              ),
              const SizedBox(width: 12.0),
              // Texte
              Expanded(
                child: Text(
                  "Quel produit recherchez-vous ?", // Texte mis à jour
                  style: TextStyle(
                    color: Colors.black87,
                    fontSize: 16.0,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              // Icône de flèche
              Icon(
                Icons.arrow_forward_ios,
                color: Colors.black54,
                size: 16.0,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
