import 'dart:convert';
import 'package:http/http.dart' as http;

class PlacesService {
  final String apiKey;

  PlacesService(this.apiKey);

  Future<List<String>> fetchSuggestions(String input) async {
    final url =
        'https://maps.googleapis.com/maps/api/place/autocomplete/json?input=$input&types=geocode&key=$apiKey&language=es';

    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final jsonResult = json.decode(response.body);
      if (jsonResult['status'] == 'OK') {
        final predictions = jsonResult['predictions'] as List;
        return predictions.map((p) => p['description'] as String).toList();
      } else {
        return [];
      }
    } else {
      throw Exception('Error fetching places');
    }
  }
}