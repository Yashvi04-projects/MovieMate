import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user.dart';
import '../models/movie.dart';
import '../models/booking.dart';
import '../services/api_service.dart';

class AuthProvider extends ChangeNotifier {
  final ApiService _api = ApiService();
  User? _user;
  String? _token;
  bool _isLoading = false;
  String? _error;

  User? get user => _user;
  String? get token => _token;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isLoggedIn => _token != null;
  ApiService get apiService => _api;

  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString('token');
    if (_token != null) {
      _api.setToken(_token);
      try {
        _user = await _api.getProfile();
      } catch (_) {
        await logout();
      }
    }
    notifyListeners();
  }

  Future<bool> login(String email, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final result = await _api.login(email, password);
      _token = result['token'];
      _api.setToken(_token);
      _user = User.fromJson(result['user']);

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('token', _token!);

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString().replaceAll('Exception: ', '');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> register({
    required String name,
    required String email,
    required String password,
    String? mobile,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _api.register(
        name: name,
        email: email,
        password: password,
        mobile: mobile,
      );
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString().replaceAll('Exception: ', '');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> logout() async {
    _user = null;
    _token = null;
    _api.setToken(null);
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
    notifyListeners();
  }

  void updateLocalUser(User updatedUser) {
    _user = updatedUser;
    notifyListeners();
  }
}

class MovieProvider extends ChangeNotifier {
  final ApiService _api;
  List<Movie> _movies = [];
  List<Movie> _searchResults = [];
  Movie? _selectedMovie;
  bool _isLoading = false;

  MovieProvider(this._api);

  List<Movie> get movies => _movies;
  List<Movie> get searchResults => _searchResults;
  Movie? get selectedMovie => _selectedMovie;
  bool get isLoading => _isLoading;

  List<Movie> get trendingMovies =>
      _movies.where((m) => m.trending).toList();

  List<Movie> get upcomingMovies =>
      _movies.where((m) => m.upcoming).toList();

  Future<void> fetchMovies() async {
    _isLoading = true;
    notifyListeners();
    try {
      _movies = await _api.getMovies();
    } catch (_) {}
    _isLoading = false;
    notifyListeners();
  }

  Future<void> fetchMovieById(String id) async {
    _isLoading = true;
    notifyListeners();
    try {
      _selectedMovie = await _api.getMovieById(id);
    } catch (_) {}
    _isLoading = false;
    notifyListeners();
  }

  Future<void> searchMovies(String query) async {
    _isLoading = true;
    notifyListeners();
    try {
      _searchResults = await _api.searchMovies(query);
    } catch (_) {
      _searchResults = [];
    }
    _isLoading = false;
    notifyListeners();
  }

  void clearSearch() {
    _searchResults = [];
    notifyListeners();
  }
}

class BookingProvider extends ChangeNotifier {
  final ApiService _api;
  List<String> _selectedSeats = [];
  List<Booking> _bookingHistory = [];
  Movie? _bookingMovie;
  bool _isLoading = false;

  BookingProvider(this._api);

  List<String> get selectedSeats => _selectedSeats;
  List<Booking> get bookingHistory => _bookingHistory;
  Movie? get bookingMovie => _bookingMovie;
  bool get isLoading => _isLoading;

  // BUG-12: Seat counter displays incorrect total (off by one when multiple seats)
  int get seatCount => _selectedSeats.isEmpty ? 0 : _selectedSeats.length - 1;

  double get totalAmount => _selectedSeats.length * 250.0;

  void setBookingMovie(Movie movie) {
    _bookingMovie = movie;
    _selectedSeats = [];
    notifyListeners();
  }

  void toggleSeat(String seat) {
    if (_selectedSeats.contains(seat)) {
      _selectedSeats.remove(seat);
    } else {
      _selectedSeats.add(seat);
    }
    notifyListeners();
  }

  void clearSeats() {
    _selectedSeats = [];
    notifyListeners();
  }

  Future<bool> createBooking(String userId) async {
    if (_selectedSeats.isEmpty || _bookingMovie == null) return false;

    _isLoading = true;
    notifyListeners();

    try {
      await _api.createBooking(
        userId: userId,
        movieId: _bookingMovie!.id,
        seats: _selectedSeats,
        amount: totalAmount,
      );
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (_) {
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> fetchBookingHistory(String userId) async {
    _isLoading = true;
    notifyListeners();
    try {
      _bookingHistory = await _api.getBookingHistory(userId);
    } catch (_) {
      _bookingHistory = [];
    }
    _isLoading = false;
    notifyListeners();
  }
}
