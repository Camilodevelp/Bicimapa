import 'package:flutter/material.dart';

class RouteCard extends StatelessWidget {
  final String routeName;
  final String distance;
  final String duration;

  const RouteCard({
    Key? key,
    required this.routeName,
    required this.distance,
    required this.duration,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              routeName,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text('Distancia: $distance'),
            const SizedBox(height: 4),
            Text('Duración: $duration'),
          ],
        ),
      ),
    );
  }
}
