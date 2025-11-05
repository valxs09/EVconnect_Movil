import 'package:flutter/material.dart';

class VirtualCardScreen extends StatelessWidget {
  const VirtualCardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tarjeta Virtual'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
      ),
      body: const Center(
        child: Text('Tarjeta Virtual'),
      ),
    );
  }
}
