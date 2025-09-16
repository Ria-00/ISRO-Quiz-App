import 'dart:convert';
import 'package:http/http.dart' as http;

class IsroHelper {

  /// Fetch ISRO centres
  Future<List<Map<String,dynamic>>> fetchCentres() async {
    final String url = "https://isro.vercel.app/api/centres";
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        // Convert each element safely to Map<String, dynamic>
        final List<dynamic> list = data['centres'];
        return list.map((e) => Map<String, dynamic>.from(e)).toList();
      } else {
        throw Exception('Failed to fetch centres: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching centres: $e');
    }
  }

  /// Fetch customer satellites
  Future<List<Map<String,dynamic>>> fetchSatellites() async {
    final String url = "https://isro.vercel.app/api/customer_satellites";
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<dynamic> list = data['customer_satellites'];
        return list.map((e) => Map<String, dynamic>.from(e)).toList();
      } else {
        throw Exception('Failed to fetch satellites: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching satellites: $e');
    }
  }

  /// Fetch spacecrafts
  Future<List<Map<String,dynamic>>> fetchSpacecrafts() async {
    final String url = "https://isro.vercel.app/api/spacecrafts";
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<dynamic> list = data['spacecrafts'];
        return list.map((e) => Map<String, dynamic>.from(e)).toList();
      } else {
        throw Exception('Failed to fetch spacecrafts: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching spacecrafts: $e');
    }
  }
}
