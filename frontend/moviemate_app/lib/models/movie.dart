class Movie {
  final String id;
  final String name;
  final String poster;
  final String genre;
  final String duration;
  final double rating;
  final String description;
  final String trailerUrl;
  final String releaseDate;
  final bool trending;
  final bool upcoming;

  Movie({
    required this.id,
    required this.name,
    required this.poster,
    required this.genre,
    required this.duration,
    required this.rating,
    required this.description,
    required this.trailerUrl,
    required this.releaseDate,
    this.trending = false,
    this.upcoming = false,
  });

  factory Movie.fromJson(Map<String, dynamic> json) {
    return Movie(
      id: json['id']?.toString() ?? '',
      name: json['name'] ?? '',
      poster: json['poster'] ?? '',
      genre: json['genre'] ?? '',
      duration: json['duration'] ?? '',
      rating: (json['rating'] is int)
          ? (json['rating'] as int).toDouble()
          : (json['rating'] ?? 0.0).toDouble(),
      description: json['description'] ?? '',
      trailerUrl: json['trailerUrl'] ?? '',
      releaseDate: json['releaseDate'] ?? '',
      trending: json['trending'] ?? false,
      upcoming: json['upcoming'] ?? false,
    );
  }
}
