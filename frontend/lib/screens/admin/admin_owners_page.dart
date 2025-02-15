// owners_list_page.dart
import 'package:flutter/material.dart';
import '../../models/user_model.dart';
import '../../services/api_service.dart';
import '../profile/user_details_page.dart';

class OwnersListPage extends StatelessWidget {
  const OwnersListPage({super.key});

  @override
  Widget build(BuildContext context) {
    final ApiService apiService = ApiService();
    return Scaffold(
      appBar: AppBar(
        title: const Text('Futsal Owners'),
        backgroundColor: const Color(0xFF1E1E1E),
      ),
      backgroundColor: const Color(0xFF121212),
      body: FutureBuilder<List<User>>(
        future: apiService.fetchOwners(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(
                child: Text('Error: ${snapshot.error}',
                    style: const TextStyle(color: Colors.red)));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
                child: Text('No owners found',
                    style: TextStyle(color: Colors.white)));
          } else {
            final owners = snapshot.data!;
            return ListView.builder(
              itemCount: owners.length,
              itemBuilder: (context, index) {
                final owner = owners[index];
                return ListTile(
                  leading: CircleAvatar(
                    backgroundImage: NetworkImage(owner.profilePicture?? 'https://example.com/default-profile.png',),
                  ),
                  title: Text(owner.name,
                      style: const TextStyle(color: Colors.white)),
                  subtitle: Text(owner.email,
                      style: const TextStyle(color: Colors.white70)),
                  onTap: () {
                    // Navigate to the user details page for this owner.
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            UserDetailsPage(userId: owner.id),
                      ),
                    );
                  },
                );
              },
            );
          }
        },
      ),
    );
  }
}
