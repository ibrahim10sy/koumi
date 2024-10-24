import 'dart:async';
import 'dart:developer' as l;
import 'dart:math';
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
  List<Position> _positions = [];
  double _totalDistance = 0.0;
  double _area = 0.0;
  bool _isTracking = false;
  Timer? _timer;
  String distanceP = "0 m²";
  String _positionP = "";

  Future<void> _checkLocationPermissions() async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission != LocationPermission.whileInUse &&
          permission != LocationPermission.always) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("L'accès à la localisation est requis.")),
        );
        return;
      }
    }
  }

  Future<Position?> _getCurrentLocation() async {
    try {
      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);
      return position;
    } catch (e) {
      print("Erreur lors de l'obtention de la localisation : $e");
      return null;
    }
  }

  void _startTracking() async {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text("Suivi commencé")));
    await _checkLocationPermissions();

    if (_isTracking) return;

    Position? initialPosition = await _getCurrentLocation();
    if (initialPosition != null) {
      _positions.add(initialPosition);
      print("Position initiale ajoutée : $initialPosition");
      setState(() {
        _isTracking = true;
        _totalDistance = 0.0;
      });

      // Démarrer le Timer pour obtenir la position régulièrement
      _timer = Timer.periodic(Duration(seconds: 5), (timer) async {
        Position? currentPosition = await _getCurrentLocation();
        if (currentPosition != null) {
          double distance = Geolocator.distanceBetween(
            _positions.last.latitude,
            _positions.last.longitude,
            currentPosition.latitude,
            currentPosition.longitude,
          );
          _totalDistance += distance;
          _positions.add(currentPosition);
          print(
              "Nouvelle position ajoutée : $currentPosition, Distance : $_totalDistance m");
          setState(() {});
        } else {
          print("Impossible d'obtenir la position actuelle.");
        }
      });
    } else {
      print("Impossible d'obtenir la position initiale.");
    }
  }

  // void _stopTracking() {
  //   _timer?.cancel();
  //   setState(() {
  //     _isTracking = false;
  //     if (_positions.length > 2) {
  //       _area = _calculateArea(_positions);
  //       distanceP = "${_area.toStringAsFixed(2)} m²";
  //       _positionP = _positions.toString();
  //       print(
  //           "Suivi arrêté. Surface calculée : ${_area.toStringAsFixed(2)} m² et distance : $distanceP");
  //     } else {
  //       _area = 0.0;
  //       print("Pas assez de points pour calculer la surface.");
  //     }
  //   });
  //   ScaffoldMessenger.of(context)
  //       .showSnackBar(SnackBar(content: Text("Suivi Arrêté")));
  // }

void _stopTracking() {
  _timer?.cancel();
  setState(() {
    _isTracking = false;
    if (_positions.length > 2) {
      _area = _calculateArea(_positions);
      distanceP = "${_area.toStringAsFixed(2)} m²";
      _positionP = _positions.toString();
      print(
          "Suivi arrêté. Surface calculée : ${_area.toStringAsFixed(2)} m² et distance : $distanceP");
    } else {
      _area = 0.0;
      print("Pas assez de points pour calculer la surface.");
    }
  });
  ScaffoldMessenger.of(context)
      .showSnackBar(SnackBar(content: Text("Suivi Arrêté")));
}

double _calculateArea(List<Position> positions) {
  if (positions.length < 3) return 0.0; // Pas assez de points pour former une zone.

  double totalArea = 0.0;
  const double radiusOfEarth = 6371000; // Rayon de la terre en mètres.

  // Convertir les latitudes et longitudes en radians.
  List<double> latitudes = positions.map((p) => p.latitude * (3.14159 / 180)).toList();
  List<double> longitudes = positions.map((p) => p.longitude * (3.14159 / 180)).toList();

  // Calcul de l'aire en utilisant la formule sphérique.
  for (int i = 0; i < latitudes.length; i++) {
    int j = (i + 1) % latitudes.length;
    totalArea += (longitudes[j] - longitudes[i]) * (2 + sin(latitudes[i]) + sin(latitudes[j]));
  }

  totalArea = totalArea.abs() * (radiusOfEarth * radiusOfEarth) / 2.0;
  return totalArea;
}


//  double _calculateArea(List<Position> positions) {
//     double distance = 0.0;
//     int n = positions.length;

//     for (int i = 0; i < n; i++) {
//       int j = (i + 1) % n;
//       distance += positions[i].latitude * positions[j].longitude;
//       distance -= positions[j].latitude * positions[i].longitude;
//     }
//     distance = distance.abs() / 2.0;
//     return distance;
//   }

  Future<void> _getResultFromNextScreen(BuildContext context) async {
    final result = await Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => AddSuperficie(
                  distanceParcourue: distanceP,
                  positionInitiale: _positionP,
                )));
    l.log(result.toString());
    if (result == true) {
      print("Rafraichissement en cours");
      setState(() {});
    }
  }

  void valider() {
    // Code pour valider les données et effectuer une action en fonction des données reçues
    print(
        "Les données sont validées. Positions :, Surface : $distanceP , $_positionP");
    _getResultFromNextScreen(context);
  }

 

  @override
  void dispose() {
    _timer?.cancel();
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
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text("Distance Totale : ${_totalDistance.toStringAsFixed(2)} m",
                  style: TextStyle(fontSize: 20)),
                
              Text("Superficie Estimée : ${_area.toStringAsFixed(2)} m²",
                  style: TextStyle(fontSize: 20)),
              SizedBox(height: 20),
              _isTracking
                  ? ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: d_colorOr,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        minimumSize: const Size(250, 40),
                      ),
                      onPressed: _stopTracking,
                      child: Text(
                        "Arrêter le Suivi",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    )
                  : Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: d_colorOr,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15),
                              ),
                              minimumSize: const Size(150, 40),
                            ),
                            onPressed: _startTracking,
                            child: Text(
                              "Commencer",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 17,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(
                          width: 10,
                        ),
                        Expanded(
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: d_colorGreen,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15),
                              ),
                              minimumSize: const Size(150, 40),
                            ),
                            onPressed: _area != 0.0 ? valider : null,
                            child: Text(
                              "Valider",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 17,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
