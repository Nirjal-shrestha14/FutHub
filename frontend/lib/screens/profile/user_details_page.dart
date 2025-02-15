// user_details_page.dart
import 'package:flutter/material.dart';
import '../../models/user_model.dart';
import '../../services/api_service.dart';

class UserDetailsPage extends StatelessWidget {
  final String userId;
  const UserDetailsPage({super.key, required this.userId});

  @override
  Widget build(BuildContext context) {
    final ApiService apiService = ApiService();
    return Scaffold(
      appBar: AppBar(
        title: const Text('User Details'),
        backgroundColor: const Color(0xFF1E1E1E),
      ),
      backgroundColor: const Color(0xFF121212),
      body: FutureBuilder<User>(
        future: apiService.getUser(userId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(
                child: Text('Error: ${snapshot.error}',
                    style: const TextStyle(color: Colors.red)));
          } else if (!snapshot.hasData) {
            return const Center(
                child: Text('No user data found',
                    style: TextStyle(color: Colors.white)));
          } else {
            final user = snapshot.data!;
            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundImage: NetworkImage(user.profilePicture?? 'https://example.com/default-profile.png',),
                  ),
                  const SizedBox(height: 16),
                  Text(user.name,
                      style: const TextStyle(fontSize: 24, color: Colors.white)),
                  const SizedBox(height: 8),
                  Text(user.email,
                      style:
                          const TextStyle(fontSize: 16, color: Colors.white70)),
                  const SizedBox(height: 8),
                  Text('Role: ${user.role}',
                      style:
                          const TextStyle(fontSize: 16, color: Colors.white70)),
                  const SizedBox(height: 8),
                  Text('Phone: ${user.phoneNumber}',
                      style: const TextStyle(
                          fontSize: 16, color: Colors.white70)),
                ],
              ),
            );
          }
        },
      ),
    );
  }
}
