class Movie {
  final String title;
  final String posterUrl;

  Movie({required this.title, required this.posterUrl});

  factory Movie.fromJson(Map<String, dynamic> json) {
    return Movie(
      title: json['title'],
      posterUrl: 'https://image.tmdb.org/t/p/w500${json['poster_path']}',
    );
  }
}
