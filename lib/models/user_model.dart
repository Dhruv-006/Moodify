import 'package:firebase_auth/firebase_auth.dart' as fb;

class UserModel {
  final String uid;
  final String name;
  final String email;
  final String? photoUrl;
  final bool isGuest;
  final String? gender;
  final String? dob;

  const UserModel({
    required this.uid,
    required this.name,
    required this.email,
    this.photoUrl,
    this.isGuest = false,
    this.gender,
    this.dob,
  });

  factory UserModel.fromFirebaseUser(fb.User user) {
    final displayName = user.displayName?.trim();
    final name = (displayName != null && displayName.isNotEmpty)
        ? displayName
        : (user.email?.split('@').first ?? 'User');

    return UserModel(
      uid: user.uid,
      name: name,
      email: user.email ?? '',
      photoUrl: user.photoURL,
      isGuest: user.isAnonymous,
    );
  }

  /// Create a copy with updated fields
  UserModel copyWith({
    String? name,
    String? photoUrl,
    String? gender,
    String? dob,
  }) {
    return UserModel(
      uid: uid,
      name: name ?? this.name,
      email: email,
      photoUrl: photoUrl ?? this.photoUrl,
      isGuest: isGuest,
      gender: gender ?? this.gender,
      dob: dob ?? this.dob,
    );
  }

  factory UserModel.guest() {
    return const UserModel(
      uid: '',
      name: 'Guest User',
      email: 'guest@moodify.app',
      isGuest: true,
    );
  }
}
