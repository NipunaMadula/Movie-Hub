import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/movie.dart';

class ApiService {
  static const String _baseUrl = 'https://api.themoviedb.org/3';
  static const String _apiKey = '323d76bfc114a12d4105487c4e0af07d';

  static Future<List<Movie>> fetchPopularMovies() async {
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
