import 'package:flutter/material.dart';

class AdminPlayersPage extends StatelessWidget {
  const AdminPlayersPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Players List')),
      body: ListView.builder(
        itemCount: 10, // Replace with API data count
        itemBuilder: (context, index) {
          return ListTile(
            title: Text('Player ${index + 1}'),
            subtitle: Text('Email: player${index + 1}@example.com'),
          );
        },
      ),
    );
  }
}
