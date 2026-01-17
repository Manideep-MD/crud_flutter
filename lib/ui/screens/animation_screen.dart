import 'dart:ffi';

import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class AnimationScreen extends StatefulWidget {
  const AnimationScreen({super.key});

  @override
  State<AnimationScreen> createState() => _AnimationScreenState();
}

class _AnimationScreenState extends State<AnimationScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(seconds: 5),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(_controller);
    _slideAnimation = Tween<Offset>(
      begin: Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInBack));
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Lottie.asset(
              'assets/Lottie Lego.json',
              width: 200,
              height: 200,
              // repeat: true,
              // reverse: true,
              controller: _controller,
              onLoaded: (com) {
                _controller.duration = com.duration;
              },
            ),
            ElevatedButton(
              onPressed: () {
                _controller.forward(from: 0);
              },
              child: Text('Play'),
            ),
          ],
        ),
      ),
      // Center(
      //   child: FadeTransition(
      //     opacity: _fadeAnimation,
      //     child: SlideTransition(
      //       position: _slideAnimation,
      //       child: Container(
      //         color: Colors.blue,
      //         padding: EdgeInsets.all(25),
      //         child: Text(
      //           'Hello Flutter',
      //           style: TextStyle(color: Colors.white, fontSize: 24),
      //         ),
      //       ),
      //     ),
      //   ),
      // ),
    );
  }
}
