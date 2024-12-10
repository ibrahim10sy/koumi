import 'package:flutter/material.dart';

class FrostedGlass extends StatelessWidget {
  final double borderRadius;

  final String tempMin;
  final String tempMax;
  final String icon;
  final String description;

  const FrostedGlass({
    Key? key,
    this.borderRadius = 30.0,
    required this.tempMin,
    required this.tempMax,
    required this.icon,
    required this.description,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: Container(
        padding: const EdgeInsets.all(5),
        margin: const EdgeInsets.all(10),
        width: double.infinity,
        height: 150,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(borderRadius),
          color: Color.fromARGB(255, 230, 229, 229),
        ),
        child: Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Image.asset(
                "assets/weather/$icon.png",
                width: 100,
                height: 100,
              ),
              Padding(
                padding: const EdgeInsets.only(
                  top: 10,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Nuages",
                      style: Theme.of(context).textTheme.headlineLarge,
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    Text(
                      "Min: $tempMin°\nMax: $tempMax°",
                      style: Theme.of(context).textTheme.headlineLarge,
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
