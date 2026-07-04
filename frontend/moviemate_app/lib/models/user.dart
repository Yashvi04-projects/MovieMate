class User {
  final String id;
  final String name;
  final String email;
  final String mobile;
  final String? profileImage;

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.mobile,
    this.profileImage,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id']?.toString() ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      mobile: json['mobile'] ?? '',
      profileImage: json['profileImage'],
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'email': email,
        'mobile': mobile,
        'profileImage': profileImage,
      };

  User copyWith({
    String? name,
    String? email,
    String? mobile,
    String? profileImage,
  }) {
    return User(
      id: id,
      name: name ?? this.name,
      email: email ?? this.email,
      mobile: mobile ?? this.mobile,
      profileImage: profileImage ?? this.profileImage,
    );
  }
}
