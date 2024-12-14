import 'package:flutter/material.dart';
import 'package:mess_mate/pages/home_page.dart';
import 'package:mess_mate/auth/auth.dart';

class Authorizepage extends StatefulWidget {
  const Authorizepage({super.key});

  @override
  State<Authorizepage> createState() => _AuthorizepageState();
}

class _AuthorizepageState extends State<Authorizepage> {
  // Controllers for email and password
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  void dispose() {
    // Clean up controllers when the widget is disposed
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        height: double.infinity,
        width: double.infinity,
        decoration: BoxDecoration(
            gradient: LinearGradient(
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
          colors: [
            Color.fromARGB(255, 94, 164, 255),
            Color.fromARGB(237, 223, 96, 255)
          ],
        )),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Spacer(),
            Text(
              'Mess Mitra',
              style: TextStyle(color: Colors.white, fontSize: 36),
            ),
            Spacer(),
            Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 24),
              margin: EdgeInsets.all(30),
              decoration: BoxDecoration(
                  color: Colors.white, borderRadius: BorderRadius.circular(16)),
              child: Column(
                children: [
                  Text(
                    'Welcome Back',
                    style: TextStyle(fontSize: 36, fontWeight: FontWeight.w400),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  // Email TextField with controller
                  TextField(
                    controller: _emailController,
                    decoration: InputDecoration(
                        hintText: 'Email', border: OutlineInputBorder()),
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  // Password TextField with controller
                  TextField(
                    controller: _passwordController,
                    obscureText: true, // Hide the password text
                    decoration: InputDecoration(
                        hintText: 'Password', border: OutlineInputBorder()),
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  // Sign In Button
                  Container(
                    height: 40,
                    width: 200,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        elevation: 3,
                        backgroundColor: const Color(0xFFF5F5F8),
                      ),
                      onPressed: () {
                        // Get the text from controllers
                        String email = _emailController.text;
                        String password = _passwordController.text;

                        GoogleSignInProvider().emailLogin(email, password);
                        Navigator.of(context).pop();
                      },
                      child: Text(
                        'Sign In',
                        style: TextStyle(color: Colors.black),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Spacer(
              flex: 2,
            ),
          ],
        ),
      ),
    );
  }
}
