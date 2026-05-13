// models/user_model.dart
class UserModel {
  final int? id;
  final String username;
  final String? token;

  UserModel({
    this.id,
    required this.username,
    this.token,
  });

  // Convert JSON → Model (from API response)
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'],
      username: json['username'],
      token: json['token'] ?? json['access_token'],
    );
  }

  // Convert Model → JSON (to send to API)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'token': token,
    };
  }
}