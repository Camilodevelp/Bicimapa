import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../models/route.dart';

class RouteService {
  // Lista simulada de rutas
  final List<RouteModel> _routes = [
     RouteModel(
      id: 'r1',
      name: 'Parque Central',
      distance: 5.2,
      duration: '30m',
      points: const [
        LatLng(4.7110, -74.0721),
        LatLng(4.7122, -74.0700),
        LatLng(4.7135, -74.0680),
        LatLng(4.7148, -74.0695),
        LatLng(4.7160, -74.0715),
      ],
    ),
     RouteModel(
      id: 'r2',
      name: 'Calle 50',
      distance: 8.5,
      duration: '45m',
      points: const [
        LatLng(4.6545, -74.0620),
        LatLng(4.6560, -74.0600),
        LatLng(4.6580, -74.0585),
        LatLng(4.6600, -74.0570),
        LatLng(4.6620, -74.0555),
      ],
    ),
  ];

  List<RouteModel> getAllRoutes() => _routes;

  RouteModel? getRouteById(String id) {
    try {
      return _routes.firstWhere((r) => r.id == id);
    } catch (_) {
      return null;
    }
  }

  void addRoute(RouteModel route) => _routes.add(route);
}
