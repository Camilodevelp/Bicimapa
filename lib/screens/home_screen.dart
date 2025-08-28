import 'package:flutter/material.dart';
import '../services/route_service.dart';
import '../widgets/route_card.dart';
import '../services/location_service.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'dart:async';
import 'package:geolocator/geolocator.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'dart:convert';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final routeService = RouteService();
  final locationService = LocationService();

  late final routes = routeService.getAllRoutes();
  Completer<GoogleMapController> _controller = Completer();
  LatLng? _currentPosition;

  Set<Polyline> _polylines = {};

  

  @override
  void initState() {
    super.initState();
    _loadLocation();
    _loadGeoJson();
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

    Future<void> _loadGeoJson() async {
  final String data = await rootBundle.loadString('assets/ciclorruta.geojson');
  final geoJson = json.decode(data);

  Set<Polyline> polylines = {};

  int polylineId = 1;
  for (var feature in geoJson['features']) {
    final geometry = feature['geometry'];
    if (geometry['type'] == 'LineString') {
      List<LatLng> points = (geometry['coordinates'] as List)
          .map((coord) => LatLng(coord[1], coord[0]))
          .toList();

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
      // Solo toma el primer anillo del polígono (en general suficiente para ciclorutas)
      List<dynamic> rings = geometry['coordinates'];
      if (rings.isNotEmpty) {
        List<LatLng> points = (rings[0] as List)
            .map((coord) => LatLng(coord[1], coord[0]))
            .toList();

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
          : Column(
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
                      zoom: 14,
                    ),
                    polylines: _polylines,
                    myLocationEnabled: true,
                    onMapCreated: (GoogleMapController controller) {
                      if (!_controller.isCompleted) {
                        _controller.complete(controller);
                      }
                    },
                    markers: {
                      Marker(
                        markerId: const MarkerId("current_location"),
                        position: _currentPosition!,
                        infoWindow: const InfoWindow(title: "Tu ubicación"),
                      ),
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
                        onTap: () => _showRouteOnMap(route.points, route.id),
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
    );
  }
}
