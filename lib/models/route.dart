import 'package:google_maps_flutter/google_maps_flutter.dart';

class RouteModel {
  final String id;
  final String name;
  final double distance; // en km
  final String duration; // formato "1h 30m"
  final List<LatLng> points; // cordenada de ruta

  RouteModel({
    required this.id,
    required this.name,
    required this.distance,
    required this.duration,
    required this.points,
  });
}
