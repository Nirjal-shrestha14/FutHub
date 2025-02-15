import 'package:flutter/material.dart';

class PlayerBookingDetailsPage extends StatelessWidget {
  const PlayerBookingDetailsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Booking Details')),
      body: ListView.builder(
        itemCount: 3, // Replace with API data count
        itemBuilder: (context, index) {
          return Card(
            margin: const EdgeInsets.all(10),
            child: ListTile(
              title: Text('Booking ${index + 1}'),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Futsal: Futsal ${index + 1}'),
                  const Text('Schedule: 2:00 PM - 4:00 PM'),
                  const Text('Status: Completed'),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
