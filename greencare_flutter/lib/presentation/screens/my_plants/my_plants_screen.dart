import 'package:flutter/material.dart';

class MyPlantsScreen extends StatelessWidget {
  const MyPlantsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Mis Plantas')),
      body: const Center(
        child: Text('Mis Plantas'),
      ),
    );
  }
}