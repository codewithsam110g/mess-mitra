import 'package:firebase_database/firebase_database.dart';

class User {
  final String userId;
  final String firstname;
  final String middlename;
  final String lastname;
  final String email;
  final String loginType;
  final String accountType;

  User({
    required this.userId,
    required this.firstname,
    required this.middlename,
    required this.lastname,
    required this.email,
    required this.loginType,
    required this.accountType,
  });

  // Convert User object to a Map for Firebase
  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'firstname': firstname,
      'middlename': middlename,
      'lastname': lastname,
      'email': email,
      'loginType': loginType,
      'accountType': accountType,
    };
  }

  // Create a User object from a Firebase snapshot
  factory User.fromSnapshot(DataSnapshot snapshot) {
    final map = Map<String, dynamic>.from(snapshot.value as Map);
    return User(
      userId: map['userId'] ?? '',
      firstname: map['firstname'] ?? '',
      middlename: map['middlename'] ?? '',
      lastname: map['lastname'] ?? '',
      email: map['email'] ?? '',
      loginType: map['loginType'] ?? '',
      accountType: map['accountType'] ?? '',
    );
  }

  // Factory constructor to create a User object with basic fields
  factory User.createUser({
    required String userId,
    required String firstname,
    required String middlename,
    required String lastname,
    required String email,
    required String loginType,
    required String accountType,
  }) {
    return User(
      userId: userId,
      firstname: firstname,
      middlename: middlename,
      lastname: lastname,
      email: email,
      loginType: loginType,
      accountType: accountType,
    );
  }
}

// Functions to interact with Firebase Realtime Database
class UserService {
  final DatabaseReference _database = FirebaseDatabase.instance.ref();

  // Create a new user
  Future<void> createUser(User user) async {
    final userRef = _database.child('users').child(user.userId).child('user');
    await userRef.set(user.toMap());
  }

  // Fetch a user by email
  Future<User?> fetchUserByEmail(String email) async {
    final usersRef = _database.child('users');
    final snapshot = await usersRef.once();
    if (snapshot.snapshot.exists) {
      final usersMap =
          Map<String, dynamic>.from(snapshot.snapshot.value as Map);
      for (final uid in usersMap.keys) {
        final userMap = Map<String, dynamic>.from(usersMap[uid]['user'] ?? {});
        if (userMap['email'] == email) {
          return User(
            userId: userMap['userId'] ?? '',
            firstname: userMap['firstname'] ?? '',
            middlename: userMap['middlename'] ?? '',
            lastname: userMap['lastname'] ?? '',
            email: userMap['email'] ?? '',
            loginType: userMap['loginType'] ?? '',
            accountType: userMap['accountType'] ?? '',
          );
        }
      }
    }
    return null; // User not found
  }
}
