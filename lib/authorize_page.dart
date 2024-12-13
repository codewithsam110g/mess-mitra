import 'package:flutter/material.dart';
import 'package:mess_mate/home_page.dart';

class Authorizepage extends StatefulWidget {
  const Authorizepage({super.key});

  @override
  State<Authorizepage> createState() => _AuthorizepageState();
}

class _AuthorizepageState extends State<Authorizepage> {
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
            colors: [Color.fromARGB(255, 94, 164, 255), Color.fromARGB(237, 223, 96, 255)],
          )
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Spacer(),
            Text('Mess Mate', style: TextStyle(color: Colors.white, fontSize: 36),),
            Spacer(),
            Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 24),
              margin: EdgeInsets.all(30),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
              child: Column(
                children: [
                  Text('Welcome Back', style: TextStyle(fontSize: 36, fontWeight: FontWeight.w400),),
                  SizedBox(height: 10,),
                  TextField(
                    decoration: InputDecoration(
                      hintText: 'Email',
                      border: OutlineInputBorder()
                    ),
                  ),
                  SizedBox(height: 20,),
                  TextField(
                    obscureText: false,
                    decoration: InputDecoration(
                      hintText: 'Password',
                      border: OutlineInputBorder()
                    ),
                  ),
                  SizedBox(height: 20,),
                  Container(
                    height: 40,
                    width: 200,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        elevation: 3,
                        backgroundColor: const Color(0xFFF5F5F8),
                      ),
                      onPressed: (){
                        Navigator.of(context).push(MaterialPageRoute(builder: (context) => const HomePage()));
                      },
                      child: Text('Sign In', style: TextStyle(color: Colors.black),),
                    ),
                  ),
                  SizedBox(height: 10,),
                  Text('Or sign up with', style: TextStyle(fontSize: 18),),
                  SizedBox(height: 10,),
                  Container(
                    height: 40,
                    width: 160,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        elevation: 3,
                        backgroundColor: const Color(0xFFF5F5F8),
                      ),
                      onPressed: (){
                        Navigator.of(context).pop();
                      },
                      child: Text('Forgot Password', style: TextStyle(color: Colors.black),),
                    ),
                  ),
                ],
              ),
            ),
            Spacer(flex: 2,),
          ],
        ),
      ),
    );
  }
}