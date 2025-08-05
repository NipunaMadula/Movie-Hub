import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/movie.dart';

class MovieUtils {
  // Share movie details (using clipboard for now)
  static void shareMovie(Movie movie, BuildContext context) {
    final String shareText = '''
🎬 ${movie.title}

⭐ Rating: ${movie.voteAverage}/10
📅 Release: ${movie.releaseDate ?? 'Unknown'}
🎭 Genres: ${movie.genres.join(', ')}

${movie.overview ?? 'No description available.'}

#MovieHub #${movie.title.replaceAll(' ', '')}
''';

    Clipboard.setData(ClipboardData(text: shareText));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.copy, color: Colors.white),
            SizedBox(width: 8),
            Text('Movie details copied to clipboard'),
          ],
        ),
        backgroundColor: Colors.green,
        duration: Duration(seconds: 2),
      ),
    );
  }

  // Open movie on TMDB website (show info for now)
  static void openOnTMDB(Movie movie) {
    // For now, we'll just show the TMDB URL in a dialog
    // In a real app with url_launcher, this would open the browser
  }

  // Show movie details bottom sheet
  static void showMovieActions(BuildContext context, Movie movie, {
    VoidCallback? onAddToFavorites,
    VoidCallback? onAddToWatchlist,
    VoidCallback? onRemoveFromFavorites,
    bool isFavorite = false,
    bool isInWatchlist = false,
  }) {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            SizedBox(height: 20),
            
            Text(
              movie.title,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 20),
            
            // Action buttons
            _buildActionButton(
              icon: Icons.share,
              label: 'Share Movie',
              onTap: () {
                Navigator.pop(context);
                shareMovie(movie, context);
              },
            ),
            
            _buildActionButton(
              icon: isFavorite ? Icons.favorite : Icons.favorite_border,
              label: isFavorite ? 'Remove from Favorites' : 'Add to Favorites',
              onTap: () {
                Navigator.pop(context);
                if (isFavorite) {
                  onRemoveFromFavorites?.call();
                } else {
                  onAddToFavorites?.call();
                }
              },
            ),
            
            _buildActionButton(
              icon: isInWatchlist ? Icons.bookmark : Icons.bookmark_border,
              label: isInWatchlist ? 'Remove from Watchlist' : 'Add to Watchlist',
              onTap: () {
                Navigator.pop(context);
                onAddToWatchlist?.call();
              },
            ),
            
            _buildActionButton(
              icon: Icons.open_in_browser,
              label: 'View on TMDB',
              onTap: () {
                Navigator.pop(context);
                openOnTMDB(movie);
              },
            ),
            
            SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  static Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 4),
      child: ListTile(
        leading: Icon(icon),
        title: Text(label),
        onTap: onTap,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        contentPadding: EdgeInsets.symmetric(horizontal: 16),
      ),
    );
  }
}
