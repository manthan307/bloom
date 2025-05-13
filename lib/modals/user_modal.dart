class UserModel {
  final String uid;
  final String name;
  final String? bio;
  final String? goal;
  final String email;
  final String? photoURL;
  final String? username;

  UserModel(
      {required this.uid,
      required this.name,
      required this.bio,
      required this.goal,
      required this.email,
      this.photoURL,
      required this.username});

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      uid: map['uid'],
      name: map['name'],
      bio: map['bio'],
      goal: map['goal'],
      email: map['email'],
      photoURL: map['photoURL'],
      username: map['username'],
    );
  }
}
