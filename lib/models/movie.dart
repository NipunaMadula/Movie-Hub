class Movie {
  final int id;
  final String title;
  final String posterUrl;
  final String? backdropUrl;
  final String? overview;
  final double voteAverage;
  final String? releaseDate;
  final List<String> genres;
  final int? runtime;

  Movie({
    required this.id,
    required this.title,
    required this.posterUrl,
    this.backdropUrl,
    this.overview,
    required this.voteAverage,
    this.releaseDate,
    this.genres = const [],
    this.runtime,
  });

  factory Movie.fromJson(Map<String, dynamic> json) {
    return Movie(
      id: _parseInt(json['id']),
      title: json['title'] ?? 'Unknown Title',
      posterUrl: json['poster_path'] != null 
          ? 'https://image.tmdb.org/t/p/w500${json['poster_path']}'
          : '',
      backdropUrl: json['backdrop_path'] != null
          ? 'https://image.tmdb.org/t/p/w1280${json['backdrop_path']}'
          : null,
      overview: json['overview'],
      voteAverage: _parseDouble(json['vote_average']),
      releaseDate: json['release_date'],
      genres: json['genre_ids'] != null 
          ? (json['genre_ids'] as List).map((id) => _getGenreName(_parseInt(id))).where((genre) => genre != 'Unknown').toList()
          : [],
      runtime: json['runtime'],
    );
  }

  // Convert Movie to JSON for storage
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'poster_path': posterUrl.replaceFirst('https://image.tmdb.org/t/p/w500', ''),
      'backdrop_path': backdropUrl?.replaceFirst('https://image.tmdb.org/t/p/w1280', ''),
      'overview': overview,
      'vote_average': voteAverage,
      'release_date': releaseDate,
      'genres': genres,
      'runtime': runtime,
    };
  }

  static double _parseDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) {
      return double.tryParse(value) ?? 0.0;
    }
    return 0.0;
  }

  static int _parseInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) {
      return int.tryParse(value) ?? 0;
    }
    return 0;
  }

  static String _getGenreName(int genreId) {
    const genreMap = {
      28: 'Action',
      12: 'Adventure', 
      16: 'Animation',
      35: 'Comedy',
      80: 'Crime',
      99: 'Documentary',
      18: 'Drama',
      10751: 'Family',
      14: 'Fantasy',
      36: 'History',
      27: 'Horror',
      10402: 'Music',
      9648: 'Mystery',
      10749: 'Romance',
      878: 'Science Fiction',
      10770: 'TV Movie',
      53: 'Thriller',
      10752: 'War',
      37: 'Western',
    };
    return genreMap[genreId] ?? 'Unknown';
  }
}
