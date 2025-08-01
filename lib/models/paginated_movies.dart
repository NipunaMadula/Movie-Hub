class PaginatedMovies {
  final List<dynamic> movies;
  final int page;
  final int totalPages;
  final int totalResults;
  final bool hasNextPage;

  PaginatedMovies({
    required this.movies,
    required this.page,
    required this.totalPages,
    required this.totalResults,
  }) : hasNextPage = page < totalPages;

  factory PaginatedMovies.fromJson(Map<String, dynamic> json) {
    return PaginatedMovies(
      movies: json['results'] ?? [],
      page: json['page'] ?? 1,
      totalPages: json['total_pages'] ?? 1,
      totalResults: json['total_results'] ?? 0,
    );
  }
}
