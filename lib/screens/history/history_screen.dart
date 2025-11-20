import 'package:flutter/material.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F2F2),
      appBar: AppBar(
        title: const Text('Historial', style: TextStyle(color: Colors.black87)),
        backgroundColor: const Color(0xFFF2F2F2),
        elevation: 0,
      ),
      body: const Center(
        child: Text(
          'Próximamente: Historial de Cargas',
          style: TextStyle(fontSize: 20, color: Colors.black54),
        ),
      ),
    );
  }
}
