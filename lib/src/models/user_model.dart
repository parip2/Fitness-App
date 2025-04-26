class UserModel {
  final String uid;
  final String username;
  final String email;
  final String bio;

  UserModel({
    required this.uid,
    required this.username,
    required this.email,
    required this.bio,
  });

  factory UserModel.fromMap(Map<String, dynamic> data) {
    return UserModel(
      uid: data['uid'] ?? '',
      username: data['username'] ?? '',
      email: data['email'] ?? '',
      bio: data['bio'] ?? '',
    );
  }
}
