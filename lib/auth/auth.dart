import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:mess_mate/objects/user.dart' as _User;

class GoogleSignInProvider extends ChangeNotifier {
  final googleSignIn = GoogleSignIn();
  GoogleSignInAccount? _user;
  GoogleSignInAccount get user => _user!;

  void emailLogin(String email, String password) async {
    try {
      final credential = await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: email, password: password);
          
          Fluttertoast.showToast(
            msg: "Logged In Successfully",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
          );
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        // Check for specific passwords and create the account.
        if (password == 'mcom123' || password == 'mcor123') {
          try {
            // Create a new Firebase user.
            final newCredential = await FirebaseAuth.instance
                .createUserWithEmailAndPassword(email: email, password: password);

            final userId = newCredential.user?.uid ?? "";

            // Determine account type based on the password.
            final accountType = password == 'mcom123' ? 'mcom' : 'mcor';

            // Create the user object using _User.User and the UserService.
            final _User.UserService userService = _User.UserService();
            final _User.User user = _User.User.createUser(
              accountType: accountType,
              email: email,
              firstname: "Complete", // Replace with actual data if available.
              middlename: "Your", // Replace with actual data if available.
              lastname: "Profile", // Replace with actual data if available.
              loginType: "email",
              userId: userId,
              mess:"DH",
              mobileno:"1231231321"
            );

            // Save the user object to the database using the UserService.
            await userService.createUser(user);

            Fluttertoast.showToast(
              msg: "Account created successfully.",
              toastLength: Toast.LENGTH_SHORT,
              gravity: ToastGravity.BOTTOM,
            );
          } catch (creationError) {
            Fluttertoast.showToast(
              msg: "Failed to create account: ${creationError.toString()}",
              toastLength: Toast.LENGTH_SHORT,
              gravity: ToastGravity.BOTTOM,
            );
          }
        } else {
          Fluttertoast.showToast(
            msg: "No user found for that email.",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
          );
        }
      } else if (e.code == 'wrong-password') {
        Fluttertoast.showToast(
          msg: "Wrong password provided for that user.",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
        );
      }
    }
  }

  Future googleLogin(BuildContext context) async {
    try {
      final googleUser = await googleSignIn.signIn();
      if (googleUser == null) return;

      _user = googleUser;

      if (!googleUser.email.contains("@rgukt")) {
        await googleSignIn.disconnect();
        Fluttertoast.showToast(
          msg: "Please login with an RGUKT email.",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
        );
        return;
      }

      final googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken, idToken: googleAuth.idToken);

      final userCredential =
          await FirebaseAuth.instance.signInWithCredential(credential);
      final firebaseUser = userCredential.user;

      if (firebaseUser == null) return;

      final userId = firebaseUser.uid;
      final email = firebaseUser.email ?? googleUser.email;
      final fullName = googleUser.displayName ?? '';

      // Split the full name into parts
      final nameParts = fullName.split(' ');
      final firstname = nameParts.isNotEmpty ? nameParts.first : '';
      final lastname = nameParts.length > 1 ? nameParts.last : '';
      final middlename = nameParts.length > 2
          ? nameParts.sublist(1, nameParts.length - 1).join(' ')
          : '';

      // Check if the user exists in the database
      final databaseRef = FirebaseDatabase.instance.ref();
      final userRef = databaseRef.child('users').child(userId).child('user');
      final snapshot = await userRef.get();

      if (!snapshot.exists) {
        // If the user doesn't exist, create the user in the database
        final userMap = {
          'userId': userId,
          'firstname': firstname,
          'middlename': middlename,
          'lastname': lastname,
          'email': email,
          'loginType': 'google',
          'accountType': 'student', // Default account type
        };

        await userRef.set(userMap);
      }
      Fluttertoast.showToast(
        msg: "Login successful.",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
      );

      notifyListeners();
    } catch (error) {
      Fluttertoast.showToast(
        msg: "Login failed: ${error.toString()}",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
      );
    }
  }

  Future logout() async {
    await googleSignIn.signOut();
    FirebaseAuth.instance.signOut();
  }
}
