import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../models/movie.dart';

class ApiService {
  static const String _baseUrl = 'https://api.themoviedb.org/3';

  static String? get _apiKey {
    try {
      return dotenv.env['TMDB_API_KEY'];
    } catch (e) {
      print('Error accessing API key from .env: $e');
      return null;
    }
  }

  static Future<List<Movie>> fetchPopularMovies() async {
    return _fetchMoviesByCategory('popular');
  }

  static Future<List<Movie>> fetchTopRatedMovies() async {
    return _fetchMoviesByCategory('top_rated');
  }

  static Future<List<Movie>> fetchUpcomingMovies() async {
    return _fetchMoviesByCategory('upcoming');
  }

  static Future<List<Movie>> _fetchMoviesByCategory(String category) async {
    final apiKey = _apiKey;
    if (apiKey == null || apiKey.isEmpty) {
      throw Exception('API key is missing. Please check your .env file.');
    }

    final response = await http.get(
      Uri.parse('$_baseUrl/movie/$category?api_key=$apiKey'),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final List movies = data['results'];

      return movies.map((json) => Movie.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load $category movies');
    }
  }

  static Future<List<Movie>> searchMovies(String query) async {
    final apiKey = _apiKey;
    if (apiKey == null || apiKey.isEmpty) {
      throw Exception('API key is missing. Please check your .env file.');
    }

    if (query.isEmpty) {
      return fetchPopularMovies(); // Return popular movies if search is empty
    }

    final response = await http.get(
      Uri.parse('$_baseUrl/search/movie?api_key=$apiKey&query=${Uri.encodeComponent(query)}'),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final List movies = data['results'];

      return movies.map((json) => Movie.fromJson(json)).toList();
    } else {
      throw Exception('Failed to search movies');
    }
  }
}
