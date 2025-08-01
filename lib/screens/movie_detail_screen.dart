import 'package:flutter/material.dart';
import '../models/movie.dart';
import '../services/favorites_service.dart';

class MovieDetailScreen extends StatefulWidget {
  final Movie movie;

  MovieDetailScreen({required this.movie});

  @override
  _MovieDetailScreenState createState() => _MovieDetailScreenState();
}

class _MovieDetailScreenState extends State<MovieDetailScreen> {
  late FavoritesService _favoritesService;
  bool _isFavorite = false;

  @override
  void initState() {
    super.initState();
    _initializeFavorites();
  }

  Future<void> _initializeFavorites() async {
    _favoritesService = await FavoritesService.getInstance();
    final isFavorite = await _favoritesService.isInFavorites(widget.movie.id);
    setState(() {
      _isFavorite = isFavorite;
    });
  }

  Future<void> _toggleFavorite() async {
    final bool success = await _favoritesService.toggleFavorite(widget.movie);
    if (success) {
      setState(() {
        _isFavorite = !_isFavorite;
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _isFavorite 
                ? '${widget.movie.title} added to favorites' 
                : '${widget.movie.title} removed from favorites'
          ),
          backgroundColor: _isFavorite ? Colors.green[400] : Colors.red[400],
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // App Bar with Backdrop Image
          SliverAppBar(
            expandedHeight: 300,
            pinned: true,
            actions: [
              IconButton(
                icon: Icon(
                  _isFavorite ? Icons.favorite : Icons.favorite_border,
                  color: _isFavorite ? Colors.red : Colors.white,
                ),
                onPressed: _toggleFavorite,
                tooltip: _isFavorite ? 'Remove from favorites' : 'Add to favorites',
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                widget.movie.title,
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  shadows: [
                    Shadow(
                      offset: Offset(0, 1),
                      blurRadius: 3,
                      color: Colors.black54,
                    ),
                  ],
                ),
              ),
              background: Stack(
                fit: StackFit.expand,
                children: [
                  // Backdrop Image
                  widget.movie.backdropUrl != null && widget.movie.backdropUrl!.isNotEmpty
                      ? Image.network(
                          widget.movie.backdropUrl!,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              Container(
                                color: Colors.grey[300],
                                child: Icon(
                                  Icons.movie,
                                  size: 80,
                                  color: Colors.grey[600],
                                ),
                              ),
                        )
                      : Container(
                          color: Colors.grey[300],
                          child: Icon(
                            Icons.movie,
                            size: 80,
                            color: Colors.grey[600],
                          ),
                        ),
                  // Gradient Overlay
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withAlpha(179), // 179 = 0.7 * 255
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          // Movie Details Content
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Movie Info Row
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Poster
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.network(
                          widget.movie.posterUrl,
                          width: 120,
                          height: 180,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              Container(
                                width: 120,
                                height: 180,
                                color: Colors.grey[300],
                                child: Icon(
                                  Icons.image_not_supported,
                                  size: 40,
                                  color: Colors.grey[600],
                                ),
                              ),
                        ),
                      ),
                      
                      SizedBox(width: 16),
                      
                      // Movie Details
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Rating
                            Row(
                              children: [
                                Icon(
                                  Icons.star,
                                  color: Colors.amber,
                                  size: 20,
                                ),
                                SizedBox(width: 4),
                                Text(
                                  '${widget.movie.voteAverage.toStringAsFixed(1)}/10',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                              ],
                            ),
                            
                            SizedBox(height: 8),
                            
                            // Release Date
                            if (widget.movie.releaseDate != null && widget.movie.releaseDate!.isNotEmpty)
                              Row(
                                children: [
                                  Icon(
                                    Icons.calendar_today,
                                    size: 16,
                                    color: Colors.grey[600],
                                  ),
                                  SizedBox(width: 4),
                                  Text(
                                    _formatReleaseDate(widget.movie.releaseDate!),
                                    style: TextStyle(
                                      color: Colors.grey[600],
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                            
                            SizedBox(height: 8),
                            
                            // Genres
                            if (widget.movie.genres.isNotEmpty)
                              Wrap(
                                spacing: 6,
                                runSpacing: 6,
                                children: widget.movie.genres.take(3).map((genre) {
                                  return Container(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.blue.withAlpha(26), // 26 = 0.1 * 255
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color: Colors.blue.withAlpha(77), // 77 = 0.3 * 255
                                      ),
                                    ),
                                    child: Text(
                                      genre,
                                      style: TextStyle(
                                        color: Colors.blue[700],
                                        fontSize: 12,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  );
                                }).toList(),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  
                  SizedBox(height: 24),
                  
                  // Overview Section
                  if (widget.movie.overview != null && widget.movie.overview!.isNotEmpty) ...[
                    Text(
                      'Overview',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    SizedBox(height: 12),
                    Text(
                      widget.movie.overview!,
                      style: TextStyle(
                        fontSize: 16,
                        height: 1.6,
                        color: Colors.grey[700],
                      ),
                    ),
                  ] else ...[
                    Text(
                      'Overview',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    SizedBox(height: 12),
                    Text(
                      'No overview available for this movie.',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey[500],
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                  
                  SizedBox(height: 32),
                  
                  // Action Buttons
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: _toggleFavorite,
                          icon: Icon(_isFavorite ? Icons.favorite : Icons.favorite_outline),
                          label: Text(_isFavorite ? 'Remove from Favorites' : 'Add to Favorites'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _isFavorite ? Colors.grey[600] : Colors.red[400],
                            foregroundColor: Colors.white,
                            padding: EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () {
                            // TODO: Add share functionality
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Share feature coming soon!'),
                                duration: Duration(seconds: 2),
                              ),
                            );
                          },
                          icon: Icon(Icons.share_outlined),
                          label: Text('Share'),
                          style: OutlinedButton.styleFrom(
                            padding: EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  
                  SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatReleaseDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      final months = [
        '', 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
        'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
      ];
      return '${months[date.month]} ${date.day}, ${date.year}';
    } catch (e) {
      return dateString;
    }
  }
}
