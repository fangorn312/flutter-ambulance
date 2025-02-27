class User {
  final String id;
  final String username;
  final String name;
  final String? token;
  final String? refreshToken;

  User({
    required this.id,
    required this.username,
    required this.name,
    this.token,
    this.refreshToken,
  });
}