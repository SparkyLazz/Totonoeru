import 'package:flutter/material.dart';

class FocusScreen extends StatelessWidget {
  const FocusScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Focus', style: TextStyle(fontFamily: 'DMSans', fontWeight: FontWeight.w600)),
        centerTitle: false,
      ),
      body: const Center(child: Text('Focus timer — Week 5', style: TextStyle(fontFamily: 'DMSans'))),
    );
  }
}
