import 'package:flutter/material.dart';
import 'package:mess_mate/page_manager.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({Key? key}) : super(key: key);

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _logoPositionAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    // Reduced duration for faster icon animation
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    );

    _logoPositionAnimation = Tween<double>(begin: 0, end: -50).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.bounceIn),
    );

    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInCirc),
    );

    _animationController.forward();

    // Increased delay after animation
    Future.delayed(const Duration(seconds: 6), () {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const PageManager()),
      );
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Background Design
        Scaffold(
          backgroundColor: Colors.white,
          body: Stack(
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
        // Animated Logo and App Name
        Center(
          child: AnimatedBuilder(
            animation: _animationController,
            builder: (context, child) {
              return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Transform.translate(
                    offset: Offset(0, _logoPositionAnimation.value),
                    child: Hero(
                      tag: 'logo',
                      child: CircleAvatar(
                        backgroundColor: Colors.white,
                        radius: 100,
                        child: Image.asset('assets/logo.png'),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Opacity(
                    opacity: _fadeAnimation.value,
                    child: const Text(
                      'Mess Mitra',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF6B5BD2),
                        decoration: TextDecoration.none
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ],
    );
  }
}
