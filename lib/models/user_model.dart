class UserModel {
  final String userEmail;
  final String userId;
  final String username;

  const UserModel({
    required this.userEmail,
    required this.userId,
    required this.username,
  });

  // Factory constructor to create a UserModel from a map
  factory UserModel.fromMap(Map<String, dynamic> data) {
    return UserModel(
      userEmail: data['userEmail'] as String,
      userId: data['userId'] as String,
      username: data['username'] as String,
    );
  }

  // Method to convert UserModel to a map
  Map<String, dynamic> toMap() {
    return {
      'userEmail': userEmail,
      'userId': userId,
      'username': username,
    };
  }

  @override
  List<Object?> get props => [userEmail, userId, username];
}
