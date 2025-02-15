import 'package:flutter/material.dart';

class PlayerTeamSearchPage extends StatelessWidget {
  const PlayerTeamSearchPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Find a Team')),
      body: ListView.builder(
        itemCount: 5, // Replace with API data count
        itemBuilder: (context, index) {
          return Card(
            margin: const EdgeInsets.all(10),
            child: ListTile(
              title: Text('Team ${index + 1}'),
              subtitle: const Text('Looking for 2 players'),
              trailing: ElevatedButton(
                onPressed: () {
                  print('Request sent to join Team ${index + 1}');
                },
                child: const Text('Request to Join'),
              ),
            ),
          );
        },
      ),
    );
  }
}
