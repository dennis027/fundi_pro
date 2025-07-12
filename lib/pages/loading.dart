import 'package:flutter/material.dart';


class Loading extends StatefulWidget {
  const Loading({super.key});

  @override
  State<Loading> createState() => _LoadingState();
}

class _LoadingState extends State<Loading> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeIn;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: Duration(seconds: 4),
      vsync: this,
    );

    _fadeIn = CurvedAnimation(parent: _controller, curve: Curves.easeIn);

    _controller.forward();

    // Navigate after animation completes
    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        Navigator.pushReplacementNamed(context, '/login');
      }
    });

  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: FadeTransition(
        opacity: _fadeIn,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset('assets/fundi_pro_logo.png', width: 150), // save the image here
            const SizedBox(height: 10),
            const Text(
              'RELIABLE FUNDI TRUST',
              style: TextStyle(
                fontSize: 16,
                color: Colors.blue,
                letterSpacing: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}