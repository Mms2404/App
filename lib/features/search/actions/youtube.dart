import 'dart:convert';
import 'package:app/api/keys.dart';
import 'package:http/http.dart' as http;

Future<List<dynamic>> youtubeSearch(String prompt) async {
  final apiKey = YOUTUBE_API; 
  final url = 'https://www.googleapis.com/youtube/v3/search?part=snippet&q=$prompt&type=video&key=$apiKey';

  final response = await http.get(Uri.parse(url));

  if (response.statusCode == 200) {
    final Map<String, dynamic> data = json.decode(response.body);
    return data['items'];
  } else {
    throw Exception('Failed to load videos');
  }
}