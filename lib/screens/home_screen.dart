import 'package:flutter/material.dart';
import '../services/route_service.dart';
import '../widgets/route_card.dart';
import '../services/location_service.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'dart:async';
import 'package:geolocator/geolocator.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'dart:convert';

List<LatLng> simplify(List<LatLng> points, double tolerance) {
  if (points.length < 3) return points;

  double distance(LatLng p, LatLng p1, LatLng p2) {
    final dx = p2.longitude - p1.longitude;
    final dy = p2.latitude - p1.latitude;
    if (dx == 0 && dy == 0) {
      return ((p.longitude - p1.longitude) * (p.longitude - p1.longitude)) +
          ((p.latitude - p1.latitude) * (p.latitude - p1.latitude));
    }
    final t =
        ((p.longitude - p1.longitude) * dx + (p.latitude - p1.latitude) * dy) /
        (dx * dx + dy * dy);
    final nearest = LatLng(p1.latitude + t * dy, p1.longitude + t * dx);
    return ((p.longitude - nearest.longitude) *
            (p.longitude - nearest.longitude)) +
        ((p.latitude - nearest.latitude) * (p.latitude - nearest.latitude));
  }

  int index = 0;
  double maxDist = 0;
  for (int i = 1; i < points.length - 1; i++) {
    final dist = distance(points[i], points[0], points.last);
    if (dist > maxDist) {
      index = i;
      maxDist = dist;
    }
  }

  if (maxDist > tolerance * tolerance) {
    final rec1 = simplify(points.sublist(0, index + 1), tolerance);
    final rec2 = simplify(points.sublist(index, points.length), tolerance);
    return rec1.sublist(0, rec1.length - 1) + rec2;
  } else {
    return [points.first, points.last];
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final routeService = RouteService();
  final locationService = LocationService();
  final TextEditingController _searchController = TextEditingController();

  late final routes = routeService.getAllRoutes();
  final Completer<GoogleMapController> _controller = Completer();
  LatLng? _currentPosition;

  Set<Polyline> _polylines = {};

  @override
  void initState() {
    super.initState();
    _loadLocation();
    _loadGeoJson(); // Solo llama a la versión principal
  }

  Future<void> _loadGeoJson() async {
    final String data = await rootBundle.loadString(
      'assets/ciclorruta.geojson',
    );
    final geoJson = json.decode(data);

    Set<Polyline> polylines = {};

    int polylineId = 1;
    for (var feature in geoJson['features']) {
      final geometry = feature['geometry'];
      if (geometry['type'] == 'LineString') {
        List<LatLng> points = (geometry['coordinates'] as List)
            .map((coord) => LatLng(coord[1], coord[0]))
            .toList();
        points = simplify(points, 0.0005); // <-- Usa simplify aquí

        polylines.add(
          Polyline(
            polylineId: PolylineId('cicloruta_$polylineId'),
            points: points,
            color: Colors.green,
            width: 4,
          ),
        );
        polylineId++;
      } else if (geometry['type'] == 'Polygon') {
        List<dynamic> rings = geometry['coordinates'];
        if (rings.isNotEmpty) {
          List<LatLng> points = (rings[0] as List)
              .map((coord) => LatLng(coord[1], coord[0]))
              .toList();
          points = simplify(points, 0.0005); // <-- Y aquí también

          polylines.add(
            Polyline(
              polylineId: PolylineId('cicloruta_$polylineId'),
              points: points,
              color: Colors.green,
              width: 4,
            ),
          );
          polylineId++;
        }
      }
    }

    setState(() {
      _polylines = polylines;
    });
  }

  Future<void> _loadLocation() async {
    try {
      final position = await locationService.getCurrentLocation();
      setState(() {
        _currentPosition = LatLng(position.latitude, position.longitude);
      });
    } catch (e) {
      print("Error obteniendo ubicación: $e");
    }
  }

  void _showRouteOnMap(List<LatLng> points, String routeId) async {
    if (points.isEmpty) return;

    final controller = await _controller.future;

    final polyline = Polyline(
      polylineId: PolylineId(routeId),
      points: points,
      width: 5,
      color: Colors.blue,
      consumeTapEvents: false,
    );

    setState(() {
      _polylines = {polyline};
    });

    final bounds = _calculateBounds(points);
    controller.animateCamera(CameraUpdate.newLatLngBounds(bounds, 50));
  }

  LatLngBounds _calculateBounds(List<LatLng> points) {
    double minLat = points.first.latitude;
    double maxLat = points.first.latitude;
    double minLng = points.first.longitude;
    double maxLng = points.first.longitude;

    for (final p in points) {
      if (p.latitude < minLat) minLat = p.latitude;
      if (p.latitude > maxLat) maxLat = p.latitude;
      if (p.longitude < minLng) minLng = p.longitude;
      if (p.longitude > maxLng) maxLng = p.longitude;
    }

    return LatLngBounds(
      southwest: LatLng(minLat, minLng),
      northeast: LatLng(maxLat, maxLng),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Bicimapa')),
      body: _currentPosition == null
          ? const Center(child: CircularProgressIndicator())
          : Stack(
              children: [
                Positioned(
                  top: 16,
                  left: 16,
                  right: 16,
                  child: Material(
                    elevation: 4,
                    borderRadius: BorderRadius.circular(8),
                    child: TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        hintText: 'Buscar dirección o lugar...',
                        prefixIcon: Icon(Icons.search),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(vertical: 15),
                      ),
                      onSubmitted: (value) {
                        print('Buscando: $value');
                      },
                    ),
                  ),
                ),
                Column(
                  children: [
                    // Texto con la ubicación actual
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Text(
                        'Ubicación actual: Lat ${_currentPosition!.latitude}, Lon ${_currentPosition!.longitude}',
                        style: const TextStyle(fontSize: 16),
                      ),
                    ),
                    // Mapa de Google
                    SizedBox(
                      height: 250,
                      child: GoogleMap(
                        initialCameraPosition: CameraPosition(
                          target: _currentPosition!,
                          zoom: 13,
                        ),
                        polylines: _polylines,
                        myLocationEnabled: true,
                        onMapCreated: (controller) {
                          _controller.complete(controller);
                        },
                      ),
                    ),
                    // Lista de rutas
                    Expanded(
                      child: ListView.builder(
                        itemCount: routes.length,
                        itemBuilder: (context, index) {
                          final route = routes[index];
                          return InkWell(
                            onTap: () {
                              _showRouteOnMap(route.points, route.id);
                            },
                            child: RouteCard(
                              routeName: route.name,
                              distance: '${route.distance} km',
                              duration: route.duration,
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
    );
  }
}
