class UserModel {
  final String uid;
  final String name;
  final String? bio;
  final String? goal;
  final String email;
  final String? photoURL;
  final String? username;

  UserModel({
    required this.uid,
    required this.name,
    this.bio,
    this.goal,
    required this.email,
    this.photoURL,
    this.username,
  });

  factory UserModel.fromMap(Map<String, dynamic> map, String uid) {
    return UserModel(
      uid: map['uid'] as String,
      name: map['name'] as String,
      bio: map['bio'] as String?,
      goal: map['goal'] as String?,
      email: map['email'] as String,
      photoURL: map['photoURL'] as String?,
      username: map['username'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'name': name,
      'bio': bio,
      'goal': goal,
      'email': email,
      'photoURL': photoURL,
      'username': username,
    };
  }

  UserModel copyWith({
    String? name,
    String? bio,
    String? goal,
    String? photoURL,
    String? username,
  }) {
    return UserModel(
      uid: uid,
      name: name ?? this.name,
      bio: bio ?? this.bio,
      goal: goal ?? this.goal,
      email: email,
      photoURL: photoURL ?? this.photoURL,
      username: username ?? this.username,
    );
  }
}
