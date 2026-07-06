class UserModel {
  final String uid;
  final String displayName;
  final String email;
  final String photoURL;
  final DateTime createdAt;

  UserModel({
    required this.uid,
    required this.displayName,
    required this.email,
    required this.photoURL,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() => {
    'uid': uid,
    'displayName': displayName,
    'email': email,
    'photoURL': photoURL,
    'createdAt': createdAt.toIso8601String(),
  };

  factory UserModel.fromMap(Map<String, dynamic> map) => UserModel(
    uid: map['uid'] ?? '',
    displayName: map['displayName'] ?? '',
    email: map['email'] ?? '',
    photoURL: map['photoURL'] ?? '',
    createdAt: DateTime.parse(map['createdAt']),
  );
}