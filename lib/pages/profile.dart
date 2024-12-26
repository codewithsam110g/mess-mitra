import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:mess_mate/auth/auth.dart';
import 'package:flutter_custom_tabs/flutter_custom_tabs.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final DatabaseReference _dbRef = FirebaseDatabase.instance.ref();
  Map<String, dynamic>? userData;
  String? feedbackUrl;
  bool isEditing = false;

  // Controllers for editable fields
  final TextEditingController firstnameController = TextEditingController();
  final TextEditingController middlenameController = TextEditingController();
  final TextEditingController lastnameController = TextEditingController();
  final TextEditingController messController = TextEditingController();
  final TextEditingController mobilenoController = TextEditingController();
  final TextEditingController accType = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchUserData();
    fetchFeedbackUrl();
  }

  Future<void> fetchUserData() async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) return;

    final snapshot = await _dbRef.child('users/$userId/user').get();
    if (snapshot.exists) {
      setState(() {
        userData = Map<String, dynamic>.from(snapshot.value as Map);
        firstnameController.text = userData?['firstname'] ?? '';
        middlenameController.text = userData?['middlename'] ?? '';
        lastnameController.text = userData?['lastname'] ?? '';
        messController.text = userData?['mess'] ?? '';
        mobilenoController.text = userData?['mobileno'] ?? '';
        accType.text = userData?['accountType'] ?? '';
      });
    }
  }

  Future<void> fetchFeedbackUrl() async {
    final snapshot = await _dbRef.child('MessFeedbackLink').get();
    if (snapshot.exists) {
      setState(() {
        feedbackUrl = snapshot.value as String?;
      });
    }
  }

  Future<void> saveUserData() async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) return;

    final updatedData = {
      'firstname': firstnameController.text,
      'middlename': middlenameController.text,
      'lastname': lastnameController.text,
      'mess': messController.text,
      'mobileno': mobilenoController.text,
      'accountType':accType.text
    };

    await _dbRef.child('users/$userId/user').update(updatedData);

    setState(() {
      isEditing = false;
      userData = {...?userData, ...updatedData};
    });
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final photoUrl = user?.photoURL;

    return Scaffold(
      backgroundColor: Colors.blueAccent,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12.0),
              child: Row(
                children: [
                  const Expanded(
                    child: Padding(
                      padding: EdgeInsets.only(left: 32.0),
                      child: Text(
                        "Profile",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                        ),
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.exit_to_app, color: Colors.white),
                    onPressed: () {
                      GoogleSignInProvider().logout();
                    },
                  ),
                  const SizedBox(width: 16)
                ],
              ),
            ),
            Expanded(
              child: Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(30),
                    topRight: Radius.circular(30),
                  ),
                ),
                padding: const EdgeInsets.all(16.0),
                child: SingleChildScrollView(
                  child: Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8FAFF),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: const Color(0xFFE0E0E0),
                        width: 1.5,
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: userData == null
                          ? const Center(child: CircularProgressIndicator())
                          : Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    ClipOval(
                                      child: photoUrl != null
                                          ? Image.network(
                                              photoUrl,
                                              fit: BoxFit.cover,
                                              width: 100,
                                              height: 100,
                                            )
                                          : const CircleAvatar(
                                              radius: 50,
                                              child: Icon(
                                                Icons.person,
                                                size: 50,
                                              ),
                                            ),
                                    ),
                                    IconButton(
                                      icon: Icon(
                                        isEditing ? Icons.save : Icons.edit,
                                        color: Colors.blueAccent,
                                      ),
                                      onPressed: () {
                                        if (isEditing) {
                                          saveUserData();
                                        } else {
                                          setState(() {
                                            isEditing = true;
                                          });
                                        }
                                      },
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 16),
                                _buildEditableRow(Icons.person, 'First Name',
                                    firstnameController),
                                _buildEditableRow(Icons.person_outline,
                                    'Middle Name', middlenameController),
                                _buildEditableRow(Icons.person, 'Last Name',
                                    lastnameController),
                                _buildEditableRow(Icons.restaurant, 'Mess',
                                    messController),
                                _buildEditableRow(Icons.phone, 'Mobile Number',
                                    mobilenoController),
                                _buildInfoRow(
                                    Icons.email, 'Email', userData?['email']),
                                _buildInfoRow(Icons.login, 'Login Type',
                                    userData?['loginType']),
                                _buildEditableRow(Icons.account_box, 'Account Type',
                                  accType),
                                const SizedBox(height: 16),
                              ],
                            ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEditableRow(
      IconData icon, String title, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(icon, color: Colors.blueAccent.shade400),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                ),
                isEditing
                    ? TextField(
                        controller: controller,
                        decoration: const InputDecoration(
                          isDense: true,
                          border: OutlineInputBorder(),
                        ),
                      )
                    : Text(
                        controller.text,
                        style: const TextStyle(fontSize: 16),
                      ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String title, String? value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(icon, color: Colors.blueAccent.shade400),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                ),
                Text(
                  value ?? 'N/A',
                  style: const TextStyle(fontSize: 16),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
