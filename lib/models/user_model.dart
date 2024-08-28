const String loggedInUserId = 'test@gmail.com';

class UserModel {
  final String email;
  final String username;

  const UserModel({
    required this.email,
    required this.username,
  });

  // Factory constructor to create a UserModel from a Firestore document snapshot
  factory UserModel.fromMap(Map<String, dynamic> data) {
    return UserModel(
      email: data['email'] as String,
      username: data['username'] as String,
    );
  }

  // Method to convert UserModel to a map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'email': email,
      'username': username,
    };
  }

  @override
  List<Object?> get props => [email, username];
}
