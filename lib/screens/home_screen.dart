import 'dart:async';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import '../models/movie.dart';
import '../services/api_service.dart';
import '../services/favorites_service.dart';
import '../utils/page_transitions.dart';
import '../widgets/fade_in_widget.dart';
import 'movie_detail_screen.dart';
import 'favorites_screen.dart';

enum MovieCategory { popular, nowPlaying, topRated, upcoming }

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  // Movie data management
  List<Movie> _movies = [];
  bool _isLoading = false;
  bool _isLoadingMore = false;
  bool _hasMoreData = true;
  int _currentPage = 1;
  String? _error;
  bool _isNetworkError = false;
  
  // Search and navigation
  final TextEditingController _searchController = TextEditingController();
  String _currentSearchQuery = '';
  late TabController _tabController;
  MovieCategory _currentCategory = MovieCategory.popular;
  Timer? _debounceTimer;
  
  // Scroll controller for infinite scroll
  final ScrollController _scrollController = ScrollController();
  
  // Favorites
  late FavoritesService _favoritesService;
  Set<int> _favoriteMovieIds = {};

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _initializeFavorites();
    _loadInitialMovies();
    _setupScrollListener();
    
    _tabController.addListener(() {
      if (_tabController.indexIsChanging) {
        _onCategoryChanged(_tabController.index);
      }
    });
  }

  void _setupScrollListener() {
    _scrollController.addListener(() {
      if (_scrollController.position.pixels >= 
          _scrollController.position.maxScrollExtent - 200) {
        _loadMoreMovies();
      }
    });
  }

  Future<void> _loadInitialMovies() async {
    setState(() {
      _isLoading = true;
      _error = null;
      _isNetworkError = false;
      _movies.clear();
      _currentPage = 1;
      _hasMoreData = true;
    });

    try {
      final movies = await _getMoviesForCurrentCategory(page: 1);
      setState(() {
        _movies = movies;
        _isLoading = false;
        _currentPage = 2;
        _hasMoreData = movies.length >= 20; // TMDB typically returns 20 items per page
      });
    } catch (e) {
      setState(() {
        _error = _getErrorMessage(e);
        _isNetworkError = _isNetworkException(e);
        _isLoading = false;
      });
    }
  }

  Future<void> _loadMoreMovies() async {
    if (_isLoadingMore || !_hasMoreData || _currentSearchQuery.isNotEmpty) return;

    setState(() {
      _isLoadingMore = true;
    });

    try {
      final newMovies = await _getMoviesForCurrentCategory(page: _currentPage);
      setState(() {
        _movies.addAll(newMovies);
        _currentPage++;
        _hasMoreData = newMovies.length >= 20;
        _isLoadingMore = false;
      });
    } catch (e) {
      setState(() {
        _isLoadingMore = false;
      });
      
      // Show a snackbar for load more errors instead of replacing the whole UI
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(Icons.error_outline, color: Colors.white, size: 20),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    _isNetworkException(e) 
                        ? 'Connection error. Pull down to refresh.' 
                        : 'Failed to load more movies.',
                    style: TextStyle(fontSize: 14),
                  ),
                ),
              ],
            ),
            backgroundColor: Colors.red[600],
            duration: Duration(seconds: 3),
            action: SnackBarAction(
              label: 'Retry',
              textColor: Colors.white,
              onPressed: _loadMoreMovies,
            ),
          ),
        );
      }
    }
  }

  Future<List<Movie>> _getMoviesForCurrentCategory({int page = 1}) async {
    if (_currentSearchQuery.isNotEmpty) {
      return ApiService.searchMovies(_currentSearchQuery, page: page);
    }
    
    switch (_currentCategory) {
      case MovieCategory.popular:
        return ApiService.fetchPopularMovies(page: page);
      case MovieCategory.nowPlaying:
        return ApiService.fetchNowPlayingMovies(page: page);
      case MovieCategory.topRated:
        return ApiService.fetchTopRatedMovies(page: page);
      case MovieCategory.upcoming:
        return ApiService.fetchUpcomingMovies(page: page);
    }
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
    _scrollController.dispose();
    _debounceTimer?.cancel();
    super.dispose();
  }

  void _onCategoryChanged(int index) {
    setState(() {
      _currentCategory = MovieCategory.values[index];
      _currentSearchQuery = ''; 
      _searchController.clear(); 
    });
    _loadInitialMovies(); // Reload movies for new category
  }

  Future<void> _searchMovies(String query) async {
    setState(() {
      _currentSearchQuery = query;
      _isLoading = true;
      _error = null;
      _isNetworkError = false;
      _movies.clear();
      _currentPage = 1;
      _hasMoreData = true;
    });

    try {
      final movies = await _getMoviesForCurrentCategory(page: 1);
      setState(() {
        _movies = movies;
        _isLoading = false;
        _currentPage = 2;
        _hasMoreData = movies.length >= 20;
      });
    } catch (e) {
      setState(() {
        _error = _getErrorMessage(e);
        _isNetworkError = _isNetworkException(e);
        _isLoading = false;
      });
    }
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
    await _loadInitialMovies();
  }

  String _getErrorMessage(dynamic error) {
    String errorString = error.toString().toLowerCase();
    
    if (errorString.contains('socketexception') || 
        errorString.contains('network') ||
        errorString.contains('connection') ||
        errorString.contains('unreachable')) {
      return 'No internet connection. Please check your network and try again.';
    } else if (errorString.contains('timeout')) {
      return 'Request timed out. Please try again.';
    } else if (errorString.contains('404')) {
      return 'Content not found. Please try again later.';
    } else if (errorString.contains('500') || errorString.contains('server')) {
      return 'Server error. Please try again later.';
    } else if (errorString.contains('api key')) {
      return 'Service temporarily unavailable. Please try again later.';
    } else if (errorString.contains('failed to load')) {
      return 'Failed to load movies. Please check your connection.';
    } else {
      return 'Something went wrong. Please try again.';
    }
  }

  bool _isNetworkException(dynamic error) {
    String errorString = error.toString().toLowerCase();
    return errorString.contains('socketexception') || 
           errorString.contains('network') ||
           errorString.contains('connection') ||
           errorString.contains('unreachable') ||
           errorString.contains('timeout');
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
        title: Row(
          children: [
            Text('Movie Hub'),
            if (_isNetworkError && _movies.isEmpty) ...[
              SizedBox(width: 8),
              Icon(
                Icons.wifi_off,
                size: 16,
                color: Colors.orange[300],
              ),
            ],
          ],
        ),
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
                    SlidePageRoute(
                      child: FavoritesScreen(),
                      beginOffset: const Offset(1.0, 0.0),
                    ),
                  ).then((_) => _loadFavoriteIds()); 
                },
                child: Center(
                  child: Hero(
                    tag: 'favorites-icon',
                    child: Icon(
                      Icons.favorite,
                      size: 24,
                    ),
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
                  labelStyle: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                  unselectedLabelStyle: TextStyle(fontSize: 11),
                  tabs: [
                    Tab(
                      icon: Icon(Icons.trending_up, size: 20),
                      text: 'Popular',
                    ),
                    Tab(
                      icon: Icon(Icons.play_circle_outline, size: 20),
                      text: 'Now Playing',
                    ),
                    Tab(
                      icon: Icon(Icons.star, size: 20),
                      text: 'Top Rated',
                    ),
                    Tab(
                      icon: Icon(Icons.upcoming, size: 20),
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
        child: _buildMoviesList(),
      ),
    );
  }

  Widget _buildMoviesList() {
    if (_isLoading && _movies.isEmpty) {
      return _buildShimmerLoading();
    } else if (_error != null && _movies.isEmpty) {
      return _buildErrorWidget();
    } else if (_movies.isEmpty) {
      return _buildEmptyStateWidget();
    }

    return GridView.builder(
      controller: _scrollController,
      padding: EdgeInsets.all(16),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2, 
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 0.6, 
      ),
      itemCount: _movies.length + (_isLoadingMore ? 2 : 0), // Add loading items
      itemBuilder: (context, index) {
        if (index >= _movies.length) {
          // Show loading indicator at the bottom
          return _buildLoadingCard();
        }
        
        final movie = _movies[index];
        return FadeInWidget(
          delay: Duration(milliseconds: (index % 6) * 100), // Stagger by visible items
          duration: Duration(milliseconds: 600),
          slideOffset: Offset(0, 0.3),
          child: GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                ScalePageRoute(
                  child: MovieDetailScreen(movie: movie),
                ),
              ).then((_) => _loadFavoriteIds()); // Refresh favorites when returning
            },
            child: buildMovieCard(movie, index),
          ),
        );
      },
    );
  }

  Widget _buildErrorWidget() {
    return SingleChildScrollView(
      physics: AlwaysScrollableScrollPhysics(),
      child: Container(
        height: MediaQuery.of(context).size.height - 200,
        padding: EdgeInsets.all(24),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                _isNetworkError ? Icons.wifi_off : Icons.error_outline,
                size: 80,
                color: _isNetworkError ? Colors.orange[400] : Colors.red[400],
              ),
              SizedBox(height: 24),
              Text(
                _isNetworkError ? 'No Internet Connection' : 'Oops! Something went wrong',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[800],
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 12),
              Text(
                _error!,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[600],
                  height: 1.4,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 32),
              Column(
                children: [
                  ElevatedButton.icon(
                    onPressed: _loadInitialMovies,
                    icon: Icon(Icons.refresh),
                    label: Text('Try Again'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepPurple,
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25),
                      ),
                    ),
                  ),
                  if (_isNetworkError) ...[
                    SizedBox(height: 16),
                    Text(
                      'Check your internet connection and try again',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[500],
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyStateWidget() {
    return SingleChildScrollView(
      physics: AlwaysScrollableScrollPhysics(),
      child: Container(
        height: MediaQuery.of(context).size.height - 200,
        padding: EdgeInsets.all(24),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                _currentSearchQuery.isNotEmpty ? Icons.search_off : Icons.movie_outlined,
                size: 80,
                color: Colors.grey[400],
              ),
              SizedBox(height: 24),
              Text(
                _currentSearchQuery.isNotEmpty 
                    ? 'No Results Found' 
                    : 'No ${_getCategoryDisplayName().toUpperCase()} Movies',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[700],
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 12),
              Text(
                _currentSearchQuery.isNotEmpty
                    ? 'We couldn\'t find any movies matching\n"${_currentSearchQuery}"'
                    : 'No ${_getCategoryDisplayName()} movies are available right now.',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[600],
                  height: 1.4,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 32),
              if (_currentSearchQuery.isNotEmpty) ...[
                Column(
                  children: [
                    ElevatedButton.icon(
                      onPressed: () {
                        _searchController.clear();
                        _onSearchChanged('');
                      },
                      icon: Icon(Icons.clear),
                      label: Text('Clear Search'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.deepPurple,
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25),
                        ),
                      ),
                    ),
                    SizedBox(height: 16),
                    Text(
                      'Try different keywords or browse categories',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[500],
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ] else ...[
                Column(
                  children: [
                    ElevatedButton.icon(
                      onPressed: _loadInitialMovies,
                      icon: Icon(Icons.refresh),
                      label: Text('Refresh'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.deepPurple,
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25),
                        ),
                      ),
                    ),
                    SizedBox(height: 16),
                    Text(
                      'Pull down to refresh or try a different category',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[500],
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingCard() {
    return FadeInWidget(
      duration: Duration(milliseconds: 300),
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: Colors.grey[300],
          ),
          child: Center(
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(Colors.deepPurple),
            ),
          ),
        ),
      ),
    );
  }

  Widget buildMovieCard(Movie movie, int index) {
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
              Hero(
                tag: 'movie-poster-${movie.id}',
                child: ClipRRect(
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

          Expanded(
            child: Padding(
              padding: EdgeInsets.all(8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Hero(
                    tag: 'movie-title-${movie.id}',
                    child: Material(
                      color: Colors.transparent,
                      child: Text(
                        movie.title,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
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
      case MovieCategory.nowPlaying:
        return 'now playing';
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
      case MovieCategory.nowPlaying:
        return 'Now Playing Movie';
      case MovieCategory.topRated:
        return 'Top Rated Movie';
      case MovieCategory.upcoming:
        return 'Upcoming Movie';
    }
  }
}
