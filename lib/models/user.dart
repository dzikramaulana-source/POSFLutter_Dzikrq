class User {
  final String id;
  final String username;
  final String name;
  final String role;

  User({
    required this.id,
    required this.username,
    required this.name,
    required this.role,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['_id']?.toString() ?? '',
      username: json['username']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      role: json['role']?.toString() ?? 'kasir',
    );
  }

  Map<String, dynamic> toJson() => {
        '_id': id,
        'username': username,
        'name': name,
        'role': role,
      };
}
