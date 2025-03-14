import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:track_in/baseurl.dart';

class TenderService {
  // Replace with your API URL

  Future<Map<String, dynamic>> getTenderCounts() async {
    final response = await http.get(Uri.parse('$baseurl/tenderoverview/'));

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load tender counts');
    }
  }
}
