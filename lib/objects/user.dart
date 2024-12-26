import 'package:firebase_database/firebase_database.dart';

class User {
  final String userId;
  final String firstname;
  final String middlename;
  final String lastname;
  final String email;
  final String loginType;
  final String accountType;
  final String mess;
  final String mobileno;
  final List<String> complaintIds; // To track supported complaint IDs

  User({
    required this.userId,
    required this.firstname,
    required this.middlename,
    required this.lastname,
    required this.email,
    required this.loginType,
    required this.accountType,
    required this.mess,
    required this.mobileno,
    required this.complaintIds,
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
      'mess': mess,
      'mobileno': mobileno,
      'complaintIds': complaintIds,
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
      mess: map['mess'] ?? '',
      mobileno: map['mobileno'] ?? '',
      complaintIds: List<String>.from(map['complaintIds'] ?? []),
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
    required String mess,
    required String mobileno,
  }) {
    return User(
      userId: userId,
      firstname: firstname,
      middlename: middlename,
      lastname: lastname,
      email: email,
      loginType: loginType,
      accountType: accountType,
      mess: mess,
      mobileno: mobileno,
      complaintIds: [],
    );
  }
}

class UserService {
  final DatabaseReference _database = FirebaseDatabase.instance.ref();

  // Create a new user
  Future<void> createUser(User user) async {
    final userRef = _database.child('users').child(user.userId).child('user');
    await userRef.set(user.toMap());
  }

  // Add this method in UserService
  Future<List<User>> fetchAllUsers() async {
    final snapshot = await _database.child('users').once();
    if (snapshot.snapshot.exists) {
      final usersMap = Map<String, dynamic>.from(snapshot.snapshot.value as Map);
      return usersMap.entries.map((entry) {
        return User.fromSnapshot(snapshot.snapshot.child(entry.key).child('user'));
      }).toList();
    }
    return []; // Return an empty list if no users found
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
          return User.fromSnapshot(snapshot.snapshot.child(uid).child('user'));
        }
      }
    }
    return null; // User not found
  }

  Future<User?> fetchUserByUID(String userId) async {
    final usersRef = _database.child('users');
    final snapshot = await usersRef.once();
    if (snapshot.snapshot.exists) {
      final usersMap =
          Map<String, dynamic>.from(snapshot.snapshot.value as Map);
      for (final uid in usersMap.keys) {
        if (uid == userId) {
          return User.fromSnapshot(snapshot.snapshot.child(uid).child("user"));
        }
      }
    }
    return null; // User not found
  }

  // Add a complaint ID to a user's supported complaints
  Future<void> addComplaintToUser(String userId, String complaintId) async {
    final userRef = _database.child('users').child(userId).child('user');
    final snapshot = await userRef.once();
    if (snapshot.snapshot.exists) {
      final user = User.fromSnapshot(snapshot.snapshot);
      if (!user.complaintIds.contains(complaintId)) {
        user.complaintIds.add(complaintId);
        await userRef.set(user.toMap());
      }
    }
  }

  // Check if a user supports a specific complaint
  Future<bool> isComplaintSupported(String userId, String complaintId) async {
    final userRef = _database.child('users').child(userId).child('user');
    final snapshot = await userRef.once();
    if (snapshot.snapshot.exists) {
      final user = User.fromSnapshot(snapshot.snapshot);
      return user.complaintIds.contains(complaintId);
    }
    return false;
  }

  Future<void> updateUser(User user) async {
    final userRef = _database.child('users').child(user.userId).child('user');
    final snapshot = await userRef.once();
    if (snapshot.snapshot.exists) {
      // Only update fields that are provided (no overwriting)
      final updatedUser = User(
        userId: user.userId,
        firstname: user.firstname,
        middlename: user.middlename,
        lastname: user.lastname,
        email: user.email,
        loginType: user.loginType,
        accountType: user.accountType,
        mess: user.mess,
        mobileno: user.mobileno,
        complaintIds: user.complaintIds,
      );
      await userRef.set(updatedUser.toMap());
    } else {
      throw Exception("User not found");
    }
  }
}
