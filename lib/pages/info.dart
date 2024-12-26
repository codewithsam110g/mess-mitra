import 'package:flutter/material.dart';
import 'package:mess_mate/objects/user.dart'; // Import your UserService class here

class InfoScreen extends StatefulWidget {
  const InfoScreen({super.key});

  @override
  State<InfoScreen> createState() => _InfoScreenState();
}

class _InfoScreenState extends State<InfoScreen> {
  final UserService _userService = UserService();
  List<User> _users = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchUsers();
  }

  Future<void> _fetchUsers() async {
    final snapshot = await _userService.fetchAllUsers();
    setState(() {
      _users = snapshot.where((e) => e.accountType == "mcor").toList();
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blueAccent,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
           const Padding(
              padding:  EdgeInsets.symmetric(vertical: 12.0),
              child: Row(
                children: [
                  Padding(
                    padding: EdgeInsets.only(left:16.0),
                    child: Text(
                      "Mess Co-ordinators Info",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                      ),
                    ),
                  ),
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
                padding: const EdgeInsets.all(8.0),
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : _users.isEmpty
                        ? const Center(
                            child: Text(
                              'No users found.',
                              style: TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                          )
                        : ListView.builder(
                            itemCount: _users.length,
                            itemBuilder: (context, index) {
                              final user = _users[index];
                              return DesignerCard(
                                name:
                                    '${user.firstname} ${user.middlename} ${user.lastname}'
                                        .trim(),
                                title: user.mess,
                                phone: user.mobileno,
                                colorIndex: index,
                              );
                            },
                          ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class DesignerCard extends StatelessWidget {
  final String name;
  final String title;
  final String phone;
  final int colorIndex;

  const DesignerCard({
    required this.name,
    required this.title,
    required this.phone,
    required this.colorIndex,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final colors = [
      Colors.blue[100]!, // Light Blue
      Colors.orange[100]!, // Light Orange
      Colors.pink[100]!, // Light Pink
      Colors.purple[100]!, // Light Purple
      Colors.green[100]!, // Light Green
    ];

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: colors[colorIndex % colors.length], // Softer colors
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const CircleAvatar(
              radius: 30,
              child: Icon(Icons.person, color: Colors.white),
              backgroundColor: Colors.grey,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Mess: $title',
                    style: const TextStyle(fontSize: 14, color: Colors.black87),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Mobile: $phone',
                    style: const TextStyle(fontSize: 14, color: Colors.black87),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
