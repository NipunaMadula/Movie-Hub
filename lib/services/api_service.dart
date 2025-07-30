import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../models/movie.dart';

class ApiService {
  static const String _baseUrl = 'https://api.themoviedb.org/3';

  static final String? _apiKey = dotenv.env['TMDB_API_KEY'];

  static Future<List<Movie>> fetchPopularMovies() async {
    if (_apiKey == null) {
      throw Exception('API key is missing. Please check your .env file.');
    }

    final response = await http.get(
      Uri.parse('$_baseUrl/movie/popular?api_key=$_apiKey'),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final List movies = data['results'];

      return movies.map((json) => Movie.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load movies');
    }
  }
}
