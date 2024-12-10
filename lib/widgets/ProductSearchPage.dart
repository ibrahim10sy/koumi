import 'package:flutter/material.dart';
import 'package:koumi/constants.dart';
import 'package:koumi/models/Stock.dart';
import 'package:koumi/screens/DetailProduits.dart';
import 'package:koumi/service/StockService.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:developer';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';

class ProductSearchPage extends StatefulWidget {
  const ProductSearchPage({super.key});

  @override
  State<ProductSearchPage> createState() => _ProductSearchPageState();
}

const d_colorGreen = Color.fromRGBO(43, 103, 6, 1);
const d_colorOr = Color.fromRGBO(255, 138, 0, 1);

class _ProductSearchPageState extends State<ProductSearchPage> {
  final TextEditingController _searchController = TextEditingController();
  List<String> _recentSearches = [];
  List<Stock> _filteredResults = [];
  List<Stock> stockListe = [];
  bool hasMore = true;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadSearchHistory();
  }

  // Charger les historiques depuis SharedPreferences
  Future<void> _loadSearchHistory() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _recentSearches = prefs.getStringList('search_history') ?? [];
    });
  }

  // Sauvegarder une recherche et limiter l'historique à 5
  Future<void> _saveSearchHistory(String query) async {
    if (query.isEmpty) return;

    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      // Ajouter la recherche uniquement si elle n'existe pas déjà
      if (!_recentSearches.contains(query)) {
        _recentSearches.insert(0, query);
        if (_recentSearches.length > 5) {
          _recentSearches = _recentSearches.sublist(0, 5);
        }
        //voir 
        prefs.setStringList('search_history', _recentSearches);
      }
    });
  }

  Future<void> fetchStock(String query) async {
    if (query.isEmpty) return;

    // Efface les résultats précédents avant une nouvelle recherche
    setState(() {
      _filteredResults.clear();
      isLoading = true; // Indiquer que la recherche est en cours
    });

    try {
      final response = await http
          .get(Uri.parse('$apiOnlineUrl/Stock/search?nomProduit=$query'));
      debugPrint('$apiOnlineUrl/Stock/search?nomProduit=$query');
      if (response.statusCode == 200) {
        List<dynamic> body = jsonDecode(utf8.decode(response.bodyBytes));
        setState(() {
          _filteredResults = body.map((e) => Stock.fromMap(e)).toList();
        });
      } else {
        debugPrint('Erreur ${response.statusCode}: ${response.body}');
      }
    } catch (e) {
      debugPrint('Erreur lors de la recherche: $e');
    } finally {
      setState(() {
        isLoading = false; // Indiquer que la recherche est terminée
      });
    }
  }

  // Future<void> fetchStock(String query) async {
  //   final response = await http
  //       .get(Uri.parse('$apiOnlineUrl/Stock/search?nomProduit=$query'));
  //   debugPrint('$apiOnlineUrl/Stock/search?nomProduit=$query');
  //   if (response.statusCode == 200) {
  //     List<dynamic> body = jsonDecode(utf8.decode(response.bodyBytes));
  //     setState(() {
  //       List<Stock> newStocks = body.map((e) => Stock.fromMap(e)).toList();
  //       _filteredResults.addAll(newStocks);
  //     });
  //   } else {
  //     print(
  //         'Échec de la requête avec le code d\'état: ${response.statusCode} |  ${response.body}');
  //   }
  // }

  // Supprimer l'historique de recherche
  Future<void> _clearSearchHistory() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('search_history');
    setState(() {
      _recentSearches.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        toolbarHeight: 78,
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_sharp, size: 30, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Container(
          height: 50,
          decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            children: [
              const SizedBox(width: 15.0),
              Icon(
                Icons.search, // Icône de recherche
                color: Colors.black54,
                size: 24.0,
              ),
              // const SizedBox(width: 8.0),
              Expanded(
                child: TextField(
                  controller: _searchController,
                  enableSuggestions: true,
                  autofocus: true,
                  onChanged: (query) async {
                    if (!isLoading) {
                      setState(() {
                        _filteredResults
                            .clear(); // Effacer les anciens résultats
                      });
                      fetchStock(query); // Charger les nouveaux résultats
                      // await _saveSearchHistory(query);
                    }
                  },
                  onSubmitted: (query) async {
                    if (!isLoading) {
                      setState(() {
                        _filteredResults
                            .clear(); // Effacer les anciens résultats
                      });
                      await _saveSearchHistory(query);
                      fetchStock(query);
                    }
                  },
                  decoration: InputDecoration(
                    hintText: 'Rechercher un produit...',
                    contentPadding: const EdgeInsets.symmetric(
                        vertical: 10, horizontal: 20),
                    border: InputBorder.none,
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: Icon(Icons.clear, color: Colors.black),
                            onPressed: () {
                              _searchController.clear();
                              setState(() {
                                _filteredResults
                                    .clear(); // Effacer les résultats
                              });
                            },
                          )
                        : null,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Historique des recherches
              if (_recentSearches.isNotEmpty) ...[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Recherche récent',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[700],
                      ),
                    ),
                    TextButton(
                      onPressed: _clearSearchHistory,
                      child: Text(
                        'Effacer',
                        style: TextStyle(color: d_colorOr),
                      ),
                    ),
                  ],
                ),
                Wrap(
                  spacing: 8.0,
                  children: _recentSearches.map((search) {
                    return GestureDetector(
                      onTap: () {
                        _searchController.text = search;
                        fetchStock(search);
                        // _performSearch(search);
                      },
                      child: Chip(
                        label: Text(search),
                        backgroundColor: Colors.grey[200],
                      ),
                    );
                  }).toList(),
                ),
                SizedBox(height: 16),
              ],

              // Résultats de la recherche
              isLoading
                  ? Center(
                      child: CircularProgressIndicator(
                        color: d_colorOr,
                      ),
                    )
                  : _filteredResults.isEmpty
                      ? Center(
                          child: Text(
                            'Aucun resultat trouvé',
                            style: TextStyle(color: Colors.grey[600]),
                          ),
                        )
                      : GridView.builder(
                          shrinkWrap: true,
                          physics: NeverScrollableScrollPhysics(),
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            mainAxisSpacing: 5,
                            crossAxisSpacing: 5,
                            childAspectRatio: 0.8,
                          ),
                          itemCount: _filteredResults.length,
                          // itemCount: stockListe.length + (isLoading ? 1 : 0),
                          itemBuilder: (context, index) {
                            if (index < _filteredResults.length) {
                              return GestureDetector(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => DetailProduits(
                                          stock: _filteredResults[index],
                                        ),
                                      ),
                                    );
                                  },
                                  child: Card(
                                    color: Color(0xFFFAFAFA),
                                    elevation: 1,
                                    margin: EdgeInsets.all(8),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.stretch,
                                      children: [
                                        ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(8.0),
                                          child: Container(
                                            height: 78,
                                            child: _filteredResults[index]
                                                            .photo ==
                                                        null ||
                                                    _filteredResults[index]
                                                        .photo!
                                                        .isEmpty
                                                ? Image.asset(
                                                    "assets/images/default_image.png",
                                                    fit: BoxFit.cover,
                                                  )
                                                : CachedNetworkImage(
                                                    imageUrl:
                                                        "https://koumi.ml/api-koumi/Stock/${_filteredResults[index].idStock}/image",
                                                    fit: BoxFit.cover,
                                                    placeholder: (context,
                                                            url) =>
                                                        const Center(
                                                            child:
                                                                CircularProgressIndicator()),
                                                    errorWidget:
                                                        (context, url, error) =>
                                                            Image.asset(
                                                      'assets/images/default_image.png',
                                                      fit: BoxFit.cover,
                                                    ),
                                                  ),
                                          ),
                                        ),
                                        // SizedBox(height: 8),
                                        ListTile(
                                          title: Text(
                                            _filteredResults[index].nomProduit!,
                                            style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.black87,
                                            ),
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          subtitle: Text(
                                            overflow: TextOverflow.ellipsis,
                                            "${_filteredResults[index].quantiteStock!.toString()} ${_filteredResults[index].unite!.nomUnite} ",
                                            style: TextStyle(
                                              overflow: TextOverflow.ellipsis,
                                              fontSize: 15,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.black87,
                                            ),
                                          ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 15),
                                          child: Row(
                                            children: [
                                              Text(
                                                "${_filteredResults[index].prix.toString()} ",
                                                style: TextStyle(
                                                  fontSize: 15,
                                                  color: d_colorOr,
                                                ),
                                              ),
                                              Text(
                                                _filteredResults[index]
                                                            .monnaie !=
                                                        null
                                                    ? " ${_filteredResults[index].monnaie!.libelle}"
                                                    : " FCFA ",
                                                style: TextStyle(
                                                  fontSize: 15,
                                                  color: d_colorOr,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ));
                            } else {
                              return isLoading == true
                                  ? Padding(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 32),
                                      child: Center(
                                          child: const Center(
                                        child: CircularProgressIndicator(
                                          color: d_colorOr,
                                        ),
                                      )),
                                    )
                                  : Container();
                            }
                          },
                        ),
            ],
          ),
        ),
      ),
    );
  }
}
