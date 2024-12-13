import 'package:flutter/material.dart';
import 'package:mess_mate/authorize_page.dart';
import 'package:mess_mate/home_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
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
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 48),
              margin: EdgeInsets.all(30),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
              child: Column(
                children: [
                  Text('Get Started', style: TextStyle(fontSize: 36, fontWeight: FontWeight.w400),),
                  SizedBox(height: 10,),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        side: BorderSide(),
                        borderRadius: BorderRadius.circular(12)
                      ),
                      backgroundColor: Colors.white,
                    ),
                    onPressed: (){
                      Navigator.of(context).push(MaterialPageRoute(builder: (context) => const HomePage()));
                    },
                    child: Text('Continue with Google', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.black),),
                  ),
                  SizedBox(height: 20,),
                  Text('Or sign up with', style: TextStyle(fontSize: 18),),
                  SizedBox(height: 20,),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      elevation: 3,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)
                      ),
                      backgroundColor: Colors.white
                    ),
                    onPressed: (){
                      Navigator.of(context).push(MaterialPageRoute(builder: (context) => const Authorizepage()));
                    },
                    child: Text('Continue as authorizer', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.black),),
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