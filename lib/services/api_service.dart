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

  static Future<List<Movie>> fetchPopularMovies({int page = 1}) async {
    return _fetchMoviesByCategory('popular', page: page);
  }

  static Future<List<Movie>> fetchTopRatedMovies({int page = 1}) async {
    return _fetchMoviesByCategory('top_rated', page: page);
  }

  static Future<List<Movie>> fetchUpcomingMovies({int page = 1}) async {
    return _fetchMoviesByCategory('upcoming', page: page);
  }

  static Future<List<Movie>> fetchNowPlayingMovies({int page = 1}) async {
    return _fetchMoviesByCategory('now_playing', page: page);
  }

  static Future<List<Movie>> _fetchMoviesByCategory(String category, {int page = 1}) async {
    final apiKey = _apiKey;
    if (apiKey == null || apiKey.isEmpty) {
      throw Exception('API key is missing. Please check your .env file.');
    }

    final response = await http.get(
      Uri.parse('$_baseUrl/movie/$category?api_key=$apiKey&page=$page'),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final List movies = data['results'];

      return movies.map((json) => Movie.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load $category movies');
    }
  }

  static Future<List<Movie>> searchMovies(String query, {int page = 1}) async {
    final apiKey = _apiKey;
    if (apiKey == null || apiKey.isEmpty) {
      throw Exception('API key is missing. Please check your .env file.');
    }

    if (query.isEmpty) {
      return fetchPopularMovies(page: page); // Return popular movies if search is empty
    }

    final response = await http.get(
      Uri.parse('$_baseUrl/search/movie?api_key=$apiKey&query=${Uri.encodeComponent(query)}&page=$page'),
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
