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
  // Movie data management
  List<Movie> _movies = [];
  bool _isLoading = false;
  bool _isLoadingMore = false;
  bool _hasMoreData = true;
  int _currentPage = 1;
  String? _error;
  
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
    _tabController = TabController(length: 3, vsync: this);
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
        _error = e.toString();
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
    }
  }

  Future<List<Movie>> _getMoviesForCurrentCategory({int page = 1}) async {
    if (_currentSearchQuery.isNotEmpty) {
      return ApiService.searchMovies(_currentSearchQuery, page: page);
    }
    
    switch (_currentCategory) {
      case MovieCategory.popular:
        return ApiService.fetchPopularMovies(page: page);
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
        _error = e.toString();
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
        child: _buildMoviesList(),
      ),
    );
  }

  Widget _buildMoviesList() {
    if (_isLoading && _movies.isEmpty) {
      return _buildShimmerLoading();
    } else if (_error != null && _movies.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.red[400],
            ),
            SizedBox(height: 16),
            Text(
              'Error loading movies',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            Text(
              _error!,
              style: TextStyle(color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadInitialMovies,
              child: Text('Retry'),
            ),
          ],
        ),
      );
    } else if (_movies.isEmpty) {
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
  }

  Widget _buildLoadingCard() {
    return Card(
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
            valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
          ),
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
