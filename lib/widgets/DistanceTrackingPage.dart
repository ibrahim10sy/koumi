import 'dart:async';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:koumi/screens/AddSuperficie.dart';

class DistanceTrackerPage extends StatefulWidget {
  @override
  _DistanceTrackerPageState createState() => _DistanceTrackerPageState();
}

const d_colorGreen = Color.fromRGBO(43, 103, 6, 1);
const d_colorOr = Color.fromRGBO(255, 138, 0, 1);

class _DistanceTrackerPageState extends State<DistanceTrackerPage> {
  StreamSubscription<Position>? _positionStream;
  Position? _startPosition;
  double _totalDistance = 0.0;
  bool _isTracking = false;
  String distanceP = "0 mètres";
  String _positionP = "";

  @override
  void initState() {
    super.initState();
    _getPermissions();
  }

  Future<void> _getPermissions() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Vérifie si le service de localisation est activé
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Les services de localisation sont désactivés'),
        ),
      );
      return;
    }

    // Vérifie et demande les autorisations de localisation
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Les autorisations de localisation sont refusées'),
          ),
        );
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
              'Les autorisations de localisation sont refusées de manière permanente.'),
        ),
      );
      return;
    }
  }

  // Fonction de démarrage du suivi de position
  void _startTracking() {
    setState(() {
      _isTracking = true;
      _totalDistance = 0.0;
      _startPosition = null; // Réinitialise la position de départ
    });

    // Commence à écouter les changements de position
    _positionStream = Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 1, // Filtre de distance de 1 mètre
      ),
    ).listen((Position position) {
      log("Nouvelle position reçue: ${position.latitude}, ${position.longitude}");

      // Si c'est la première position, on l'enregistre comme point de départ
      if (_startPosition == null) {
        _startPosition = position;
        log("Position initiale: $_startPosition");
      } else {
        // Calcule la distance parcourue entre la position de départ et la nouvelle position
        double distance = Geolocator.distanceBetween(
          _startPosition!.latitude,
          _startPosition!.longitude,
          position.latitude,
          position.longitude,
        );

        setState(() {
          _totalDistance += distance;
          _startPosition = position;
          distanceP = "${_totalDistance.toStringAsFixed(2)} mètres";
          _positionP = "${_startPosition.toString()}";
          log("Distance incrémentée: $_totalDistance mètres");
        });
      }
    });
  }

  // Fonction pour arrêter le suivi de position
  void _stopTracking() {
    _positionStream?.cancel(); // Arrête le flux de position
    _positionStream = null;    // Libère le flux pour éviter les conflits

    setState(() {
      _isTracking = false;
      log("Suivi arrêté. Distance parcourue: $distanceP");
    });

    // Redirection vers la page AddSuperficie
    _getResultFromNextScreen(context);
  }

  // Fonction pour récupérer le résultat après avoir ajouté la superficie
  Future<void> _getResultFromNextScreen(BuildContext context) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddSuperficie(
          distanceParcourue: distanceP,
          positionInitiale: _positionP,
        ),
      ),
    );
    log(result.toString());

    // Vérifie si le résultat est vrai pour éventuellement rafraîchir des données
    if (result == true) {
      print("Rafraîchissement en cours");
      // setState(() {
      //   _liste = getCampListe(acteur.idActeur!);
      // });
    }
  }

  @override
  void dispose() {
    _positionStream?.cancel();
    super.dispose();
  }

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
          "Distance Tracker",
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Affichage de la distance parcourue
            const Text(
              "Distance parcourue:",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 22,
              ),
            ),
            Text(
              "${_totalDistance.toStringAsFixed(2)} mètres",
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 25,
              ),
            ),
            const SizedBox(height: 20),
            // Bouton pour commencer ou arrêter le suivi
            _isTracking
                ? ElevatedButton(
                    onPressed: _stopTracking,
                    child: const Text(
                      'Arrêter',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.redAccent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      minimumSize: const Size(250, 40),
                    ),
                  )
                : ElevatedButton(
                    onPressed: _startTracking,
                    child: const Text(
                      'Commencer',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: d_colorOr,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      minimumSize: const Size(250, 40),
                    ),
                  ),
          ],
        ),
      ),
    );
  }
}
