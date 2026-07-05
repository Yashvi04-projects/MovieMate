import 'dart:async';
import 'dart:convert';
import 'dart:io' show Platform, SocketException;

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:http/http.dart' as http;

import '../models/booking.dart';
import '../models/movie.dart';
import '../models/user.dart';

class ApiService {
  /// USB debugging (default): use 127.0.0.1 + run `adb reverse tcp:3000 tcp:3000`
  /// Android emulator: flutter run --dart-define=API_HOST=10.0.2.2
  /// Same Wi-Fi (no USB): flutter run --dart-define=API_HOST=192.168.43.133
  static const String _host = '127.0.0.1';
  static const int _port = 3000;
  static const Duration _timeout = Duration(seconds: 15);

  static String get baseUrl {
    if (kIsWeb) return 'http://localhost:$_port/api';
    if (Platform.isAndroid) {
      const override = String.fromEnvironment('API_HOST');
      final host = override.isNotEmpty ? override : _host;
      return 'http://$host:$_port/api';
    }
    return 'http://localhost:$_port/api';
  }

  String? _token;
  String? get token => _token;

  void setToken(String? token) => _token = token;

  Map<String, String> get _headers => {
        'Content-Type': 'application/json',
        if (_token != null) 'Authorization': 'Bearer $_token',
      };

  Future<http.Response> _request(Future<http.Response> Function() send) async {
    try {
      return await send().timeout(_timeout);
    } on SocketException {
      throw Exception(
        'Cannot reach server at $baseUrl. Start the backend (npm start in moviemate/backend). '
        'If using USB: run "adb reverse tcp:3000 tcp:3000" then hot-restart the app.',
      );
    } on TimeoutException {
      throw Exception(
        'Connection timed out. Make sure the backend is running on port $_port '
        'and Windows Firewall allows incoming connections.',
      );
    }
  }

  Future<Map<String, dynamic>> login(String email, String password) async {
    final response = await _request(() => http.post(
          Uri.parse('$baseUrl/login'),
          headers: _headers,
          body: jsonEncode({'email': email, 'password': password}),
        ));
    return _handleResponse(response);
  }

  Future<Map<String, dynamic>> register({
    required String name,
    required String email,
    required String password,
    String? mobile,
  }) async {
    final response = await _request(() => http.post(
          Uri.parse('$baseUrl/register'),
          headers: _headers,
          body: jsonEncode({
            'name': name,
            'email': email,
            'password': password,
            'mobile': mobile,
          }),
        ));
    return _handleResponse(response);
  }

  Future<List<Movie>> getMovies({bool? trending, bool? upcoming}) async {
    var url = '$baseUrl/movies';
    final params = <String, String>{};
    if (trending == true) params['trending'] = 'true';
    if (upcoming == true) params['upcoming'] = 'true';
    if (params.isNotEmpty) {
      url += '?${params.entries.map((e) => '${e.key}=${e.value}').join('&')}';
    }

    final response =
        await _request(() => http.get(Uri.parse(url), headers: _headers));
    final data = _handleResponse(response);
    final list = data['data'] as List? ?? [];
    return list.map((m) => Movie.fromJson(m)).toList();
  }

  Future<Movie?> getMovieById(String id) async {
    final response = await _request(() => http.get(
          Uri.parse('$baseUrl/movies/$id'),
          headers: _headers,
        ));
    final data = _handleResponse(response);
    if (data['data'] != null) {
      return Movie.fromJson(data['data']);
    }
    return null;
  }

  Future<List<Movie>> searchMovies(String query) async {
    final response = await _request(() => http.get(
          Uri.parse('$baseUrl/movies/search?q=$query'),
          headers: _headers,
        ));
    final data = _handleResponse(response);
    final list = data['data'] as List? ?? [];
    return list.map((m) => Movie.fromJson(m)).toList();
  }

  Future<Map<String, dynamic>> createBooking({
    required String userId,
    required String movieId,
    required List<String> seats,
    required double amount,
  }) async {
    final response = await _request(() => http.post(
          Uri.parse('$baseUrl/booking'),
          headers: _headers,
          body: jsonEncode({
            'userId': userId,
            'movieId': movieId,
            'seats': seats,
            'amount': amount,
          }),
        ));
    return _handleResponse(response);
  }

  Future<List<Booking>> getBookingHistory(String userId) async {
    final response = await _request(() => http.get(
          Uri.parse('$baseUrl/booking/user/$userId'),
          headers: _headers,
        ));
    final data = _handleResponse(response);
    final list = data['data'] as List? ?? [];
    return list.map((b) => Booking.fromJson(b)).toList();
  }

  Future<Map<String, dynamic>> processPayment({
    required double amount,
    required String method,
    String? cardNumber,
    String? cvv,
    String? upiId,
    String? bookingId,
  }) async {
    final response = await _request(() => http.post(
          Uri.parse('$baseUrl/payment'),
          headers: _headers,
          body: jsonEncode({
            'amount': amount,
            'method': method,
            'cardNumber': cardNumber,
            'cvv': cvv,
            'upiId': upiId,
            'bookingId': bookingId,
          }),
        ));
    return _handleResponse(response);
  }

  Future<User?> getProfile() async {
    final response = await _request(() => http.get(
          Uri.parse('$baseUrl/profile'),
          headers: _headers,
        ));
    final data = _handleResponse(response);
    if (data['data'] != null) {
      return User.fromJson(data['data']);
    }
    return null;
  }

  Future<Map<String, dynamic>> updateProfile({
    String? name,
    String? email,
    String? mobile,
    String? profileImage,
  }) async {
    final response = await _request(() => http.put(
          Uri.parse('$baseUrl/profile'),
          headers: _headers,
          body: jsonEncode({
            if (name != null) 'name': name,
            if (email != null) 'email': email,
            if (mobile != null) 'mobile': mobile,
            if (profileImage != null) 'profileImage': profileImage,
          }),
        ));
    return _handleResponse(response);
  }

  Map<String, dynamic> _handleResponse(http.Response response) {
    final body = jsonDecode(response.body) as Map<String, dynamic>;
    if (response.statusCode >= 400) {
      throw Exception(body['message'] ?? 'Request failed');
    }
    return body;
  }
}
