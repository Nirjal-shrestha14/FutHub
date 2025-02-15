import 'package:flutter/material.dart';
import 'admin_profile_page.dart';
import 'package:futhub2/services/api_service.dart';
import 'package:futhub2/models/user_model.dart'; // Import the User model

void main() {
  runApp(const AdminDashboard());
}

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  _AdminDashboardState createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  final String apiUrl = 'http://127.0.0.1:4001/api/admin/analytics';
  late ApiService _apiService;
  Map<String, dynamic> _dashboardData = {};
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _apiService = ApiService();
    _fetchDashboardData();
  }

  // Fetch dashboard data from the backend
  void _fetchDashboardData() async {
    try {
      final stats = await _apiService.fetchStats();
      setState(() {
        _dashboardData = stats;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load dashboard data';
        _isLoading = false;
      });
    }
  }

  void _logout(BuildContext context) async {
    // Clear user session or token if needed
    Navigator.pushReplacementNamed(context, '/login');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: AdminSideMenu(
        onPageSelected: (Widget page) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => page),
          );
        },
        onLogout: () => _logout(context),
      ),
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        title: const Text(
          'Admin Dashboard',
          style: TextStyle(
              color: Colors.orange, fontSize: 24, fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFF1E1E1E),
        iconTheme: const IconThemeData(color: Colors.orange),
        actions: [
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const AdminProfilePage()),
              );
            },
            child: const Padding(
              padding: EdgeInsets.all(8.0),
              child: CircleAvatar(
                backgroundColor: Colors.orange,
                child: Icon(Icons.person, color: Colors.white),
              ),
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Dashboard Summary',
              style: TextStyle(
                color: Colors.orange,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _errorMessage != null
                    ? Center(
                        child: Text(_errorMessage!,
                            style: const TextStyle(color: Colors.red)))
                    : Expanded(
                        child: GridView.count(
                          crossAxisCount: 2,
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                          children: [
                            _buildDashboardCard(
                                'Total Owners',
                                _dashboardData['totalOwners']?.toString() ??
                                    'N/A',
                                Icons.person),
                            _buildDashboardCard(
                                'Total Players',
                                _dashboardData['totalPlayers']?.toString() ??
                                    'N/A',
                                Icons.people),
                            _buildDashboardCard(
                                'Total Futsals',
                                _dashboardData['totalFutsals']?.toString() ??
                                    'N/A',
                                Icons.sports_soccer),
                            _buildDashboardCard(
                                'Total Bookings',
                                _dashboardData['totalBookings']?.toString() ??
                                    'N/A',
                                Icons.calendar_today),
                          ],
                        ),
                      ),
          ],
        ),
      ),
    );
  }

  Widget _buildDashboardCard(String title, String value, IconData icon) {
    return Card(
      color: const Color(0xFF1E1E1E),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.orange, size: 40),
            const SizedBox(height: 8),
            Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(
                color: Colors.orange,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class AdminSideMenu extends StatelessWidget {
  final Function(Widget) onPageSelected;
  final VoidCallback onLogout;

  const AdminSideMenu(
      {super.key, required this.onPageSelected, required this.onLogout});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: const Color(0xFF121212),
      child: ListView(
        children: [
          const DrawerHeader(
            child: Text(
              'FUTHUB Admin',
              style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.orange),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.person, color: Colors.orange),
            title: const Text('View Owners',
                style: TextStyle(color: Colors.white)),
            onTap: () {
              // Navigate to OwnersListPage using the provided snippet:
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const OwnersListPage(),
                ),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.people, color: Colors.orange),
            title: const Text('View Players',
                style: TextStyle(color: Colors.white)),
            onTap: () {
              // Navigate to PlayersListPage
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const PlayersListPage(),
                ),
              );
            },
          ),
          // const Divider(color: Colors.grey),
          // ListTile(
          //   leading: const Icon(Icons.logout, color: Colors.red),
          //   title: const Text('Logout', style: TextStyle(color: Colors.red)),
          //   onTap: onLogout,
          // ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------
// OwnersListPage: Lists all futsal owners (users with role 'futsal_owner')
// ---------------------------------------------------------------------
class OwnersListPage extends StatelessWidget {
  const OwnersListPage({super.key});

  @override
  Widget build(BuildContext context) {
    final ApiService apiService = ApiService();

    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        title:
            const Text('Owners List', style: TextStyle(color: Colors.orange)),
        backgroundColor: const Color(0xFF1E1E1E),
        iconTheme: const IconThemeData(color: Colors.orange),
      ),
      body: FutureBuilder<List<User>>(
        future: apiService.fetchOwners(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: Colors.orange),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, color: Colors.red, size: 60),
                  const SizedBox(height: 16),
                  Text(
                    'Error: ${snapshot.error}',
                    style: const TextStyle(color: Colors.red),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      // Refresh the page
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const OwnersListPage()),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                    ),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.person_off, color: Colors.orange, size: 60),
                  SizedBox(height: 16),
                  Text(
                    'No Owners Found',
                    style: TextStyle(color: Colors.white, fontSize: 18),
                  ),
                ],
              ),
            );
          }

          final owners = snapshot.data!;
          return ListView.builder(
            itemCount: owners.length,
            itemBuilder: (context, index) {
              final owner = owners[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                color: const Color(0xFF1E1E1E),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Colors.orange,
                    backgroundImage: owner.profilePicture != null
                        ? NetworkImage(owner.profilePicture!)
                        : null,
                    child: owner.profilePicture == null
                        ? const Icon(Icons.person, color: Colors.white)
                        : null,
                  ),
                  title: Text(
                    owner.name,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        owner.email,
                        style: const TextStyle(color: Colors.white70),
                      ),
                      Text(
                        owner.phoneNumber,
                        style: const TextStyle(color: Colors.white70),
                      ),
                    ],
                  ),
                  onTap: () {
                    // Show owner details in a modal bottom sheet
                    showModalBottomSheet(
                      context: context,
                      backgroundColor: const Color(0xFF1E1E1E),
                      builder: (context) => Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Owner Details',
                              style: const TextStyle(
                                color: Colors.orange,
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 16),
                            Text('ID: ${owner.id}',
                                style: const TextStyle(color: Colors.white)),
                            Text('Name: ${owner.name}',
                                style: const TextStyle(color: Colors.white)),
                            Text('Email: ${owner.email}',
                                style: const TextStyle(color: Colors.white)),
                            Text('Phone: ${owner.phoneNumber}',
                                style: const TextStyle(color: Colors.white)),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}

// ---------------------------------------------------------------------
// PlayersListPage: Lists all players (users with role 'player')
// ---------------------------------------------------------------------
class PlayersListPage extends StatelessWidget {
  const PlayersListPage({super.key});

  @override
  Widget build(BuildContext context) {
    final ApiService apiService = ApiService();

    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        title:
            const Text('Players List', style: TextStyle(color: Colors.orange)),
        backgroundColor: const Color(0xFF1E1E1E),
        iconTheme: const IconThemeData(color: Colors.orange),
      ),
      body: FutureBuilder<List<User>>(
        future: apiService
            .fetchPlayers(), // Uses the fetchPlayers() from ApiService
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: Colors.orange),
            );
          } else if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, color: Colors.red, size: 60),
                  const SizedBox(height: 16),
                  Text(
                    'Error: ${snapshot.error}',
                    style: const TextStyle(color: Colors.red),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      // Refresh the page
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const PlayersListPage()),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                    ),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.person_off, color: Colors.orange, size: 60),
                  SizedBox(height: 16),
                  Text(
                    'No Players Found',
                    style: TextStyle(color: Colors.white, fontSize: 18),
                  ),
                ],
              ),
            );
          }
          final players = snapshot.data!;
          return ListView.builder(
            itemCount: players.length,
            itemBuilder: (context, index) {
              final player = players[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                color: const Color(0xFF1E1E1E),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Colors.orange,
                    backgroundImage: player.profilePicture != null
                        ? NetworkImage(player.profilePicture!)
                        : null,
                    child: player.profilePicture == null
                        ? const Icon(Icons.person, color: Colors.white)
                        : null,
                  ),
                  title: Text(
                    player.name,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        player.email,
                        style: const TextStyle(color: Colors.white70),
                      ),
                      Text(
                        player.phoneNumber,
                        style: const TextStyle(color: Colors.white70),
                      ),
                    ],
                  ),
                  onTap: () {
                    // Show owner details in a modal bottom sheet
                    showModalBottomSheet(
                      context: context,
                      backgroundColor: const Color(0xFF1E1E1E),
                      builder: (context) => Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Player Details',
                              style: const TextStyle(
                                color: Colors.orange,
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 16),
                            Text('ID: ${player.id}',
                                style: const TextStyle(color: Colors.white)),
                            Text('Name: ${player.name}',
                                style: const TextStyle(color: Colors.white)),
                            Text('Email: ${player.email}',
                                style: const TextStyle(color: Colors.white)),
                            Text('Phone: ${player.phoneNumber}',
                                style: const TextStyle(color: Colors.white)),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
