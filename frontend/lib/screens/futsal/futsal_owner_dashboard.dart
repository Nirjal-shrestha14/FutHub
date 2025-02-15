import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:futhub2/screens/futsal/add_futsal.dart';
import 'package:futhub2/screens/futsal/view_bookings_page.dart';
import 'package:futhub2/screens/futsal/profile_page.dart';
import 'package:futhub2/screens/futsal/view_futsal.dart';
import 'package:futhub2/services/auth_service.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class FutsalOwnerDashboard extends StatefulWidget {
  const FutsalOwnerDashboard({super.key});

  @override
  _FutsalOwnerDashboardState createState() => _FutsalOwnerDashboardState();
}

class _FutsalOwnerDashboardState extends State<FutsalOwnerDashboard> {
  List<dynamic> futsals = [];
  final List<String> _notifications = [
    "New booking at 3:00 PM",
    "Payment received: \$50",
    "Futsal maintenance scheduled for Sunday",
    "Upcoming match reminder",
  ];
  bool isLoading = true;
  bool _showNotifications = false;

  @override
  void initState() {
    fetchFutsals();
    super.initState();
  }

  Future<void> fetchFutsals() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    debugPrint('Token Data: $token');
    setState(() {
      isLoading = true;
    });

    try {
      final response = await http.get(
        Uri.parse('${AuthService.baseUrl}/bookings'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        var decodedResponse = jsonDecode(response.body);

        if (decodedResponse is List) {
          setState(() {
            futsals = decodedResponse;
            isLoading = false;
          });
        } else {
          debugPrint("Unexpected API response format: $decodedResponse");
          setState(() {
            isLoading = false;
          });
        }
      } else {
        debugPrint('Failed to load futsals: ${response.statusCode}');
        setState(() {
          isLoading = false;
        });
      }
    } catch (error) {
      debugPrint('Error fetching futsals: $error');
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    int totalBookings = futsals.length;
    Set<String> uniqueFutsalIds = futsals
        .map((booking) => booking['futsalId']?['_id']?.toString() ?? "Unknown")
        .where((id) => id != "Unknown")
        .toSet();
    int totalFutsals = uniqueFutsalIds.length;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Futsal Owner Dashboard",
          style: TextStyle(
              color: Colors.orange, fontSize: 24, fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFF1E1E1E),
        iconTheme: const IconThemeData(color: Colors.orange),
        actions: [
          Stack(
            children: [
              IconButton(
                icon: const Icon(Icons.notifications, color: Colors.orange),
                onPressed: () {
                  setState(() {
                    _showNotifications = !_showNotifications;
                  });
                },
              ),
              if (_notifications.isNotEmpty)
                Positioned(
                  right: 10,
                  top: 10,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      _notifications.length.toString(),
                      style: const TextStyle(color: Colors.white, fontSize: 12),
                    ),
                  ),
                ),
            ],
          ),
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const OwnerProfilePage()),
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
      drawer: Drawer(
        backgroundColor: const Color(0xFF121212),
        child: ListView(
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(
                color: Color(0xFF121212),
              ),
              child: Text(
                'FUTHUB Owner',
                style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.orange),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.add_business, color: Colors.orange),
              title: const Text('Add Futsal',
                  style: TextStyle(color: Colors.white)),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const AddFutsalPage()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.calendar_today, color: Colors.orange),
              title: const Text('View Bookings',
                  style: TextStyle(color: Colors.white)),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const ViewBookingsPage()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.sports_soccer, color: Colors.orange),
              title: const Text('View Futsal',
                  style: TextStyle(color: Colors.white)),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ViewFutsal()),
                );
              },
            ),
            // const Divider(color: Colors.grey),
            // ListTile(
            //   leading: const Icon(Icons.logout, color: Colors.red),
            //   title: const Text('Logout', style: TextStyle(color: Colors.red)),
            //   onTap: () async {
            //     final prefs = await SharedPreferences.getInstance();
            //     await prefs.clear();
            //     Navigator.pushReplacementNamed(context, '/login');
            //   },
            // ),
          ],
        ),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Stack(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Analytics",
                        style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.orange),
                      ),
                      const SizedBox(height: 20),
                      Expanded(
                        child: GridView.count(
                          crossAxisCount: 2,
                          crossAxisSpacing: 10,
                          mainAxisSpacing: 10,
                          children: [
                            _buildAnalyticsCard(
                                "Total Bookings", totalBookings.toString()),
                            _buildAnalyticsCard(
                                "Total Futsals", totalFutsals.toString()),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                if (_showNotifications)
                  Positioned(
                    top: 60,
                    right: 10,
                    child: Material(
                      color: const Color(0xFF121212),
                      elevation: 5,
                      borderRadius: BorderRadius.circular(10),
                      child: Container(
                        width: 250,
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1E1E1E),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: _notifications.map((notif) {
                            return ListTile(
                              title: Text(notif,
                                  style: const TextStyle(color: Colors.white)),
                              leading: const Icon(Icons.notifications,
                                  color: Colors.orange),
                              onTap: () {
                                setState(() {
                                  _notifications.remove(notif);
                                });
                              },
                            );
                          }).toList(),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
      backgroundColor: const Color(0xFF121212),
    );
  }

  Widget _buildAnalyticsCard(String title, String value) {
    return Card(
      color: const Color(0xFF1E1E1E),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(title,
                style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.white)),
            const SizedBox(height: 10),
            Text(value,
                style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.orange)),
          ],
        ),
      ),
    );
  }
}
