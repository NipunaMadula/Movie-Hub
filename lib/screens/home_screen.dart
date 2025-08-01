import 'dart:async';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import '../models/movie.dart';
import '../services/api_service.dart';
import '../services/favorites_service.dart';
import 'movie_detail_screen.dart';
import 'favorites_screen.dart';

enum MovieCategory { popular, topRated, upcoming }

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  late Future<List<Movie>> _movies;
  final TextEditingController _searchController = TextEditingController();
  String _currentSearchQuery = '';
  late TabController _tabController;
  MovieCategory _currentCategory = MovieCategory.popular;
  Timer? _debounceTimer;
  
  late FavoritesService _favoritesService;
  Set<int> _favoriteMovieIds = {};

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _movies = ApiService.fetchPopularMovies();
    _initializeFavorites();
    
    _tabController.addListener(() {
      if (_tabController.indexIsChanging) {
        _onCategoryChanged(_tabController.index);
      }
    });
  }

  Future<void> _initializeFavorites() async {
    _favoritesService = await FavoritesService.getInstance();
    _loadFavoriteIds();
  }

  Future<void> _loadFavoriteIds() async {
    final favoriteIds = await _favoritesService.getFavoriteMovieIds();
    setState(() {
      _favoriteMovieIds = favoriteIds;
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _tabController.dispose();
    _debounceTimer?.cancel();
    super.dispose();
  }

  void _onCategoryChanged(int index) {
    setState(() {
      _currentCategory = MovieCategory.values[index];
      _currentSearchQuery = ''; 
      _searchController.clear(); 
      
      switch (_currentCategory) {
        case MovieCategory.popular:
          _movies = ApiService.fetchPopularMovies();
          break;
        case MovieCategory.topRated:
          _movies = ApiService.fetchTopRatedMovies();
          break;
        case MovieCategory.upcoming:
          _movies = ApiService.fetchUpcomingMovies();
          break;
      }
    });
  }

  void _searchMovies(String query) {
    setState(() {
      _currentSearchQuery = query;
      if (query.isEmpty) {
        // Return to current category when search is cleared
        switch (_currentCategory) {
          case MovieCategory.popular:
            _movies = ApiService.fetchPopularMovies();
            break;
          case MovieCategory.topRated:
            _movies = ApiService.fetchTopRatedMovies();
            break;
          case MovieCategory.upcoming:
            _movies = ApiService.fetchUpcomingMovies();
            break;
        }
      } else {
        _movies = ApiService.searchMovies(query);
      }
    });
  }

  void _onSearchChanged(String query) {
    // Cancel the previous timer
    _debounceTimer?.cancel();
    
    // Start a new timer
    _debounceTimer = Timer(Duration(milliseconds: 500), () {
      _searchMovies(query);
    });
  }

  Future<void> _refreshMovies() async {
    setState(() {
      if (_currentSearchQuery.isEmpty) {
        // Refresh based on current category
        switch (_currentCategory) {
          case MovieCategory.popular:
            _movies = ApiService.fetchPopularMovies();
            break;
          case MovieCategory.topRated:
            _movies = ApiService.fetchTopRatedMovies();
            break;
          case MovieCategory.upcoming:
            _movies = ApiService.fetchUpcomingMovies();
            break;
        }
      } else {
        _movies = ApiService.searchMovies(_currentSearchQuery);
      }
    });
  }

  Future<void> _toggleFavorite(Movie movie) async {
    final bool success = await _favoritesService.toggleFavorite(movie);
    if (success) {
      await _loadFavoriteIds(); // Refresh favorite IDs
      
      final bool isNowFavorite = _favoriteMovieIds.contains(movie.id);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            isNowFavorite 
                ? '${movie.title} added to favorites' 
                : '${movie.title} removed from favorites'
          ),
          backgroundColor: isNowFavorite ? Colors.green[400] : Colors.red[400],
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Movie Hub'),
        toolbarHeight: 56, 
        actions: [
          Container(
            width: 56,
            height: 56,
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(28),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => FavoritesScreen(),
                    ),
                  ).then((_) => _loadFavoriteIds()); 
                },
                child: Center(
                  child: Icon(
                    Icons.favorite,
                    size: 24,
                  ),
                ),
              ),
            ),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(120),
          child: Column(
            children: [
              // Search Bar
              Padding(
                padding: EdgeInsets.all(16),
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Search movies...',
                    prefixIcon: Icon(Icons.search),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: Icon(Icons.clear),
                            onPressed: () {
                              _searchController.clear();
                              _onSearchChanged(''); // Use real-time search
                            },
                          )
                        : null,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(25),
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                    fillColor: Colors.grey[200],
                    contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  ),
                  onChanged: (value) {
                    setState(() {}); // To update the clear button visibility
                    _onSearchChanged(value); // Real-time search
                  },
                  onSubmitted: _searchMovies, // Keep immediate search on submit
                ),
              ),
              // TabBar
              if (_currentSearchQuery.isEmpty) // Only show tabs when not searching
                TabBar(
                  controller: _tabController,
                  indicatorColor: Colors.deepPurple,
                  labelColor: Colors.deepPurple,
                  unselectedLabelColor: Colors.grey[600],
                  labelStyle: TextStyle(fontWeight: FontWeight.bold),
                  tabs: [
                    Tab(
                      icon: Icon(Icons.trending_up),
                      text: 'Popular',
                    ),
                    Tab(
                      icon: Icon(Icons.star),
                      text: 'Top Rated',
                    ),
                    Tab(
                      icon: Icon(Icons.upcoming),
                      text: 'Upcoming',
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: _refreshMovies,
        child: FutureBuilder<List<Movie>>(
          future: _movies,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return _buildShimmerLoading();
            } else if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return SingleChildScrollView(
                physics: AlwaysScrollableScrollPhysics(),
                child: Container(
                  height: MediaQuery.of(context).size.height - 200,
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.movie_outlined,
                          size: 64,
                          color: Colors.grey[400],
                        ),
                        SizedBox(height: 16),
                        Text(
                          _currentSearchQuery.isEmpty 
                              ? 'No ${_getCategoryDisplayName()} movies found.' 
                              : 'No movies found for "$_currentSearchQuery"',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[600],
                          ),
                        ),
                        if (_currentSearchQuery.isNotEmpty) ...[
                          SizedBox(height: 8),
                          Text(
                            'Try searching with different keywords.',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[500],
                            ),
                          ),
                        ],
                        SizedBox(height: 16),
                        Text(
                          'Pull down to refresh',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[400],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }

            final movies = snapshot.data!;
            return GridView.builder(
              padding: EdgeInsets.all(16),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2, 
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 0.6, 
              ),
              itemCount: movies.length,
              itemBuilder: (context, index) {
                final movie = movies[index];
                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => MovieDetailScreen(movie: movie),
                      ),
                    ).then((_) => _loadFavoriteIds()); // Refresh favorites when returning
                  },
                  child: buildMovieCard(movie),
                );
              },
            );
          },
        ),
      ),
    );
  }

  Widget buildMovieCard(Movie movie) {
    final bool isFavorite = _favoriteMovieIds.contains(movie.id);
    
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
                child: Image.network(
                  movie.posterUrl,
                  height: 180,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) =>
                      Container(
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
              Positioned(
                top: 8,
                right: 8,
                child: GestureDetector(
                  onTap: () => _toggleFavorite(movie),
                  child: Container(
                    padding: EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: Colors.black.withAlpha(179), // 179 = 0.7 * 255
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      isFavorite ? Icons.favorite : Icons.favorite_border,
                      color: isFavorite ? Colors.red : Colors.white,
                      size: 22,
                    ),
                  ),
                ),
              ),
            ],
          ),

          Padding(
            padding: EdgeInsets.all(8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  movie.title,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 4),
                Text(
                  _getCategoryLabel(),
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildShimmerLoading() {
    return GridView.builder(
      padding: EdgeInsets.all(16),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 0.6,
      ),
      itemCount: 6, // Show 6 shimmer cards
      itemBuilder: (context, index) {
        return _buildShimmerCard();
      },
    );
  }

  Widget _buildShimmerCard() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Shimmer poster placeholder
            Container(
              height: 180,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
              ),
            ),
            // Shimmer text placeholders
            Padding(
              padding: EdgeInsets.all(8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    height: 16,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  SizedBox(height: 8),
                  Container(
                    height: 12,
                    width: 80,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getCategoryDisplayName() {
    switch (_currentCategory) {
      case MovieCategory.popular:
        return 'popular';
      case MovieCategory.topRated:
        return 'top rated';
      case MovieCategory.upcoming:
        return 'upcoming';
    }
  }

  String _getCategoryLabel() {
    if (_currentSearchQuery.isNotEmpty) {
      return 'Search Result';
    }
    
    switch (_currentCategory) {
      case MovieCategory.popular:
        return 'Popular Movie';
      case MovieCategory.topRated:
        return 'Top Rated Movie';
      case MovieCategory.upcoming:
        return 'Upcoming Movie';
    }
  }
}
