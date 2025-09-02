import 'dart:convert';
import 'package:http/http.dart' as http;

class PlacesService {
  final String apiKey;

  PlacesService(this.apiKey);

  Future<List<Map<String, String>>> fetchSuggestions(String input) async {
  final url =
      'https://maps.googleapis.com/maps/api/place/autocomplete/json?'
      'input=$input'
      '&key=$apiKey'
      '&language=es'
      '&location=4.6510,-74.0900'
      '&radius=20000'; // 20km alrededor de Bogotá

    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final jsonResult = json.decode(response.body);
      if (jsonResult['status'] == 'OK') {
        final predictions = jsonResult['predictions'] as List;
        return predictions
            .map((p) => {
                  'description': p['description'] as String,
                  'place_id': p['place_id'] as String,
                })
            .toList();
      } else {
        return [];
      }
    } else {
      throw Exception('Error fetching places');
    }
  }

  Future<Map<String, double>?> getPlaceLocation(String placeId) async {
    final url =
        'https://maps.googleapis.com/maps/api/place/details/json?place_id=$placeId&fields=geometry&key=$apiKey';

    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      final jsonResult = json.decode(response.body);
      if (jsonResult['status'] == 'OK') {
        final location =
            jsonResult['result']['geometry']['location'] as Map<String, dynamic>;
        return {
          'lat': location['lat'] as double,
          'lng': location['lng'] as double,
        };
      }
    }
    return null;
  }
}