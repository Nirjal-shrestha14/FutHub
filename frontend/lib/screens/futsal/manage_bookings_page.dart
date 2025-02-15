import 'package:flutter/material.dart';

class ManageBookingsPage extends StatelessWidget {
  const ManageBookingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Bookings', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      backgroundColor: Colors.black,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Upcoming Bookings",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.orange),
            ),
            const SizedBox(height: 16),
            
            Expanded(
              child: ListView.builder(
                itemCount: 5, // Replace with actual data
                itemBuilder: (context, index) {
                  return Card(
                    color: Colors.grey[900],
                    elevation: 3,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    child: ListTile(
                      leading: const Icon(Icons.sports_soccer, color: Colors.orange),
                      title: Text("Booking ${index + 1}", style: const TextStyle(color: Colors.white)),
                      subtitle: const Text("Date: YYYY-MM-DD\nTime: HH:MM AM/PM", style: TextStyle(color: Colors.grey)),
                      trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.orange),
                      onTap: () {
                        // Handle booking details click
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
