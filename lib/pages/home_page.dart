import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:mess_mate/pages/home/global_complaints.dart';
import 'package:mess_mate/pages/home/status_page.dart';
import 'package:mess_mate/pages/home/my_complaints.dart';
import 'package:mess_mate/pages/home/raise_complaint.dart';
import 'package:mess_mate/pages/profile.dart';
import 'package:mess_mate/pages/info.dart';
import 'package:mess_mate/objects/user.dart' as _User;

class HomePage extends StatefulWidget {
  const HomePage({super.key});
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 0;
  _User.User? u;
  bool isLoading = true;
  final List<Widget> _pages = [
    const HomePageContent(), // Card-based content for Home Page
    const InfoPage(),
    const ProfilePage(),
  ];

  @override
  void initState() {
    super.initState();
    getUser();
  }

  void getUser() async {
    String? email = FirebaseAuth.instance.currentUser?.email;
    _User.UserService us = _User.UserService();
    _User.User? _u = await us.fetchUserByEmail(email ?? "");
    setState(() {
      u = _u;
      isLoading = false;
    });
  }

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: _onTabTapped,
        items: [
          const BottomNavigationBarItem(
            icon: Icon(
              Icons.home,
              size: 32,
            ),
            label: 'Home',
          ),
            const BottomNavigationBarItem(
              icon: Icon(
                Icons.info,
                size: 32,
              ),
              label: 'Info',
            ),
          const BottomNavigationBarItem(
            icon: Icon(
              Icons.person,
              size: 32,
            ),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}

class HomePageContent extends StatelessWidget {
  const HomePageContent({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blueAccent,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        child: CircleAvatar(
                          child: FirebaseAuth.instance.currentUser?.photoURL !=
                                  null
                              ? ClipOval(
                                  child: Image.network(
                                    FirebaseAuth
                                        .instance.currentUser!.photoURL!,
                                    fit: BoxFit.cover,
                                    width:
                                        36, // Match twice the inner CircleAvatar radius
                                    height: 36,
                                  ),
                                )
                              : const Icon(
                                  Icons.person,
                                  size: 24, // Adjust the size to fit nicely
                                ),
                          radius: 18,
                        ),
                        radius: 20,
                        backgroundColor: Colors.green,
                      ),
                      const SizedBox(width: 10),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Welcome Back",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                            ),
                          ),
                          ConstrainedBox(
                            constraints: BoxConstraints(
                                maxWidth:
                                    MediaQuery.of(context).size.width * 0.6),
                            child: Text(
                              FirebaseAuth.instance.currentUser?.displayName ??
                                  "User",
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow
                                  .ellipsis, // Ensures text is truncated
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(30),
                    topRight: Radius.circular(30),
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: ListView(
                    children: [
                      GestureDetector(
                        onTap: () {
                          Navigator.of(context)
                              .push(MaterialPageRoute(builder: (context) {
                            return const GlobalComplaints();
                          }));
                        },
                        child: _buildCategoryCard(
                            'All Complaints',
                            'All complaints raised by students',
                            Icons.report,
                            Colors.orange),
                      ),
                      GestureDetector(
                        onTap: () {
                          Navigator.of(context)
                              .push(MaterialPageRoute(builder: (context) {
                            return const StatusPage();
                          }));
                        },
                        child: _buildCategoryCard(
                            'Reports',
                            'Overall Statistics',
                            Icons.pie_chart,
                            Colors.green),
                      ),
                      GestureDetector(
                        onTap: () {
                          Navigator.of(context)
                              .push(MaterialPageRoute(builder: (context) {
                            return const MyComplaints();
                          }));
                        },
                        child: _buildCategoryCard(
                            'My Activity',
                            'My activities in this app',
                            Icons.timer_sharp,
                            Colors.purple),
                      ),
                      GestureDetector(
                        onTap: () {
                          Navigator.of(context)
                              .push(MaterialPageRoute(builder: (context) {
                            return const RaiseComplaints();
                          }));
                        },
                        child: _buildCategoryCard('Add Complaint',
                            'Raise an issue', Icons.add, Colors.deepPurple),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryCard(
      String title, String subtitle, IconData icon, Color color) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      color: color,
      child: ListTile(
        contentPadding:
            const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
        trailing: Container(
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            shape: BoxShape.circle,
          ),
          padding: const EdgeInsets.all(8),
          child: Icon(
            icon,
            color: Colors.white,
            size: 40,
          ),
        ),
        title: Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 12,
          ),
        ),
      ),
    );
  }
}
