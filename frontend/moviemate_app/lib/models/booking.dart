class Booking {
  final String id;
  final String userId;
  final String movieId;
  final String movieName;
  final List<String> seats;
  final double amount;
  final String status;
  final String bookingDate;

  Booking({
    required this.id,
    required this.userId,
    required this.movieId,
    required this.movieName,
    required this.seats,
    required this.amount,
    required this.status,
    required this.bookingDate,
  });

  factory Booking.fromJson(Map<String, dynamic> json) {
    return Booking(
      id: json['id']?.toString() ?? '',
      userId: json['userId']?.toString() ?? '',
      movieId: json['movieId']?.toString() ?? '',
      movieName: json['movieName'] ?? '',
      seats: List<String>.from(json['seats'] ?? []),
      amount: (json['amount'] ?? 0).toDouble(),
      status: json['status'] ?? '',
      bookingDate: json['bookingDate'] ?? '',
    );
  }
}
