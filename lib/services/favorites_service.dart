import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/movie.dart';

class FavoritesService {
  static const String _favoritesKey = 'favorite_movies';
  static FavoritesService? _instance;
  static SharedPreferences? _prefs;

  FavoritesService._();

  static Future<FavoritesService> getInstance() async {
    if (_instance == null) {
      _instance = FavoritesService._();
      _prefs = await SharedPreferences.getInstance();
    }
    return _instance!;
  }

  // Get all favorite movies
  Future<List<Movie>> getFavoriteMovies() async {
    try {
      final String? favoritesJson = _prefs?.getString(_favoritesKey);
      if (favoritesJson == null || favoritesJson.isEmpty) {
        return [];
      }

      final List<dynamic> favoritesList = json.decode(favoritesJson);
      return favoritesList.map((movieJson) => Movie.fromJson(movieJson)).toList();
    } catch (e) {
      print('Error getting favorite movies: $e');
      return [];
    }
  }

  // Get favorite movie IDs for quick lookup
  Future<Set<int>> getFavoriteMovieIds() async {
    try {
      final List<Movie> favorites = await getFavoriteMovies();
      return favorites.map((movie) => movie.id).toSet();
    } catch (e) {
      print('Error getting favorite movie IDs: $e');
      return {};
    }
  }

  // Add a movie to favorites
  Future<bool> addToFavorites(Movie movie) async {
    try {
      final List<Movie> currentFavorites = await getFavoriteMovies();
      
      // Check if movie is already in favorites
      if (currentFavorites.any((fav) => fav.id == movie.id)) {
        return false; // Already in favorites
      }

      currentFavorites.add(movie);
      return await _saveFavorites(currentFavorites);
    } catch (e) {
      print('Error adding movie to favorites: $e');
      return false;
    }
  }

  // Remove a movie from favorites
  Future<bool> removeFromFavorites(int movieId) async {
    try {
      final List<Movie> currentFavorites = await getFavoriteMovies();
      final int initialLength = currentFavorites.length;
      
      currentFavorites.removeWhere((movie) => movie.id == movieId);
      
      if (currentFavorites.length == initialLength) {
        return false; // Movie was not in favorites
      }

      return await _saveFavorites(currentFavorites);
    } catch (e) {
      print('Error removing movie from favorites: $e');
      return false;
    }
  }

  // Check if a movie is in favorites
  Future<bool> isInFavorites(int movieId) async {
    try {
      final Set<int> favoriteIds = await getFavoriteMovieIds();
      return favoriteIds.contains(movieId);
    } catch (e) {
      print('Error checking if movie is in favorites: $e');
      return false;
    }
  }

  // Toggle favorite status
  Future<bool> toggleFavorite(Movie movie) async {
    try {
      final bool isCurrentlyFavorite = await isInFavorites(movie.id);
      
      if (isCurrentlyFavorite) {
        return await removeFromFavorites(movie.id);
      } else {
        return await addToFavorites(movie);
      }
    } catch (e) {
      print('Error toggling favorite: $e');
      return false;
    }
  }

  // Clear all favorites
  Future<bool> clearAllFavorites() async {
    try {
      return await _prefs?.remove(_favoritesKey) ?? false;
    } catch (e) {
      print('Error clearing favorites: $e');
      return false;
    }
  }

  // Get favorites count
  Future<int> getFavoritesCount() async {
    try {
      final List<Movie> favorites = await getFavoriteMovies();
      return favorites.length;
    } catch (e) {
      print('Error getting favorites count: $e');
      return 0;
    }
  }

  // Private method to save favorites to SharedPreferences
  Future<bool> _saveFavorites(List<Movie> favorites) async {
    try {
      final List<Map<String, dynamic>> favoritesJson = 
          favorites.map((movie) => movie.toJson()).toList();
      final String jsonString = json.encode(favoritesJson);
      return await _prefs?.setString(_favoritesKey, jsonString) ?? false;
    } catch (e) {
      print('Error saving favorites: $e');
      return false;
    }
  }
}
