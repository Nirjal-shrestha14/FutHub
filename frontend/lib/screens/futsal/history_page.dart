import 'package:flutter/material.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  _HistoryPageState createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  bool _isLoading = true;
  List<Map<String, String>> _bookingHistory = [];

  @override
  void initState() {
    super.initState();
    _fetchBookingHistory();
  }

  Future<void> _fetchBookingHistory() async {
    await Future.delayed(const Duration(seconds: 2));

    setState(() {
      _isLoading = false;
      _bookingHistory = [
        {'futsal': 'Futsal A', 'date': '2025-01-28', 'time': '10:00 AM'},
        {'futsal': 'Futsal B', 'date': '2025-01-29', 'time': '2:00 PM'},
        {'futsal': 'Futsal C', 'date': '2025-01-30', 'time': '5:00 PM'},
      ];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Booking History',
            style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      backgroundColor: Colors.black,
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.orange))
          : _bookingHistory.isEmpty
              ? const Center(
                  child: Text(
                    "No booking history available.",
                    style: TextStyle(fontSize: 16, color: Colors.white70),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16.0),
                  itemCount: _bookingHistory.length,
                  itemBuilder: (context, index) {
                    final booking = _bookingHistory[index];
                    return Card(
                      color: Colors.grey[900],
                      elevation: 3,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      child: ListTile(
                        leading:
                            const Icon(Icons.history, color: Colors.orange),
                        title: Text(
                          booking['futsal']!,
                          style: const TextStyle(
                              color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text(
                          'Date: ${booking['date']} | Time: ${booking['time']}',
                          style: const TextStyle(color: Colors.white70),
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
