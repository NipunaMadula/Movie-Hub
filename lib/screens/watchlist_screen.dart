import 'package:flutter/material.dart';
import '../services/favorites_service.dart';
import '../models/movie.dart';
import 'movie_detail_screen.dart';

class WatchlistScreen extends StatefulWidget {
  @override
  _WatchlistScreenState createState() => _WatchlistScreenState();
}

class _WatchlistScreenState extends State<WatchlistScreen> {
  List<Movie> _favorites = [];
  bool _loading = true;
  late FavoritesService _favoritesService;

  @override
  void initState() {
    super.initState();
    _loadFavorites();
  }

  Future<void> _loadFavorites() async {
    _favoritesService = await FavoritesService.getInstance();
    final favs = await _favoritesService.getFavoriteMovies();
    setState(() {
      _favorites = favs;
      _loading = false;
    });
  }

  Future<void> _remove(int movieId) async {
    await _favoritesService.removeFromFavorites(movieId);
    await _loadFavorites();
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Removed from watchlist')));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Watchlist')),
      body: _loading
          ? Center(child: CircularProgressIndicator())
          : _favorites.isEmpty
              ? Center(child: Text('Your watchlist is empty'))
              : ListView.separated(
                  padding: EdgeInsets.all(12),
                  itemCount: _favorites.length,
                  separatorBuilder: (_, __) => SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final movie = _favorites[index];
                    return ListTile(
                      leading: movie.posterUrl.isNotEmpty
                          ? Image.network(movie.posterUrl, width: 48, fit: BoxFit.cover)
                          : SizedBox(width: 48, child: Icon(Icons.movie)),
                      title: Text(movie.title),
                      subtitle: Text(movie.releaseDate ?? ''),
                      trailing: IconButton(
                        icon: Icon(Icons.delete_outline),
                        onPressed: () => _remove(movie.id),
                      ),
                      onTap: () async {
                        await Navigator.push(context, MaterialPageRoute(builder: (_) => MovieDetailScreen(movie: movie)));
                        await _loadFavorites();
                      },
                    );
                  },
                ),
    );
  }
}
