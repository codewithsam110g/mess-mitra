import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mess_mate/auth/auth.dart';
import 'package:mess_mate/pages/authorize_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  @override
  void initState() {
    super.initState();
    // Ensure the status bar allows content underneath it
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent, // Make status bar transparent
        statusBarIconBrightness: Brightness.dark, // Adjust icon brightness
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // White background for the rest of the screen
        Container(
          color: Colors.white,
        ),
        // Purple background design (should stay on top)
        Positioned.fill(
          child: Stack(
            children: [
              Positioned(
                top: 0,
                left: 0,
                child: Container(
                  height: 120,
                  width: 100,
                  decoration: const BoxDecoration(
                    color: Color(0xFF6B5BD2),
                    borderRadius: BorderRadius.only(
                      bottomRight: Radius.circular(100),
                    ),
                  ),
                ),
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  height: 120,
                  width: 100,
                  decoration: const BoxDecoration(
                    color: Color(0xFF6B5BD2),
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(100),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        // Main Content
        Scaffold(
          backgroundColor: Colors.transparent, // Allow the background to show
          body: Column(
            children: [
              Expanded(
                flex: 2,
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircleAvatar(
                        backgroundColor: Colors.white,
                        radius: 80,
                        child: Image.asset('assets/logo.png'),
                      ),
                      const SizedBox(height: 60),
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.2),
                              blurRadius: 8,
                              spreadRadius: 2,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: SizedBox(
                          width: 280,
                          child: Column(
                            children: [
                              const Text(
                                'Login',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF6B5BD2),
                                ),
                              ),
                              const SizedBox(height: 16),
                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF6B5BD2),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                  onPressed: () {
                                    GoogleSignInProvider().googleLogin(context);
                                  },
                                  child: const Text(
                                    'Login as Student',
                                    style: TextStyle(color: Colors.white, fontSize: 16),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 12),
                              SizedBox(
                                width: double.infinity,
                                child: OutlinedButton(
                                  style: OutlinedButton.styleFrom(
                                    side: const BorderSide(color: Color(0xFF6B5BD2)),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                  onPressed: () {
                                    Navigator.of(context).push(
                                      MaterialPageRoute(
                                        builder: (context) => const Authorizepage(),
                                      ),
                                    );
                                  },
                                  child: const Text(
                                    'Login as Authorizer',
                                    style: TextStyle(
                                      color: Color(0xFF6B5BD2),
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
