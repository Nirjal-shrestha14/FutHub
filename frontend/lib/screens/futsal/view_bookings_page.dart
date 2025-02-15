import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../../services/auth_service.dart';

class ViewBookingsPage extends StatefulWidget {
  const ViewBookingsPage({super.key});

  @override
  _BookOwnFutsalPageState createState() => _BookOwnFutsalPageState();
}

class _BookOwnFutsalPageState extends State<ViewBookingsPage> {
  bool isLoading = true;
  List<dynamic> bookings = [];

  // Function to fetch booking data
  Future<void> fetchBookings() async {
    String? token = await AuthService().getToken();
    debugPrint('Token: $token');
    const apiUrl = '${AuthService.baseUrl}/bookings';
    try {
      final response = await http.get(
        Uri.parse(apiUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );
      debugPrint('Response data: ${response.body}');
      if (response.statusCode == 200) {
        setState(() {
          bookings = json.decode(response.body);
          isLoading = false;
        });
      } else {
        setState(() {
          isLoading = false;
        });
        // Handle error response
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Failed to fetch bookings."),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      // Handle network or API error
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("An error occurred. Please try again."),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    fetchBookings();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:
            const Text('View Bookings', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      backgroundColor: Colors.black,
      body: isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.orange))
          : bookings.isEmpty
              ? const Center(
                  child: Text(
                    "No bookings available.",
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                        color: Colors.orange),
                  ),
                )
              : Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: DataTable(
                      headingRowColor: WidgetStateColor.resolveWith(
                          (states) => Colors.orange),
                      columns: const [
                        DataColumn(
                            label: Text('ID',
                                style: TextStyle(color: Colors.white))),
                        DataColumn(
                            label: Text('Futsal Name',
                                style: TextStyle(color: Colors.white))),
                        DataColumn(
                            label: Text('User Name',
                                style: TextStyle(color: Colors.white))),
                        DataColumn(
                            label: Text('User Email',
                                style: TextStyle(color: Colors.white))),
                        DataColumn(
                            label: Text('Date',
                                style: TextStyle(color: Colors.white))),
                        DataColumn(
                            label: Text('Time Slot',
                                style: TextStyle(color: Colors.white))),
                        DataColumn(
                            label: Text('Payment Method',
                                style: TextStyle(color: Colors.white))),
                        DataColumn(
                            label: Text('Status',
                                style: TextStyle(color: Colors.white))),
                      ],
                      rows: bookings.map((booking) {
                        return DataRow(
                          cells: [
                            DataCell(Text(booking['_id']?.toString() ?? 'N/A',
                                style: const TextStyle(color: Colors.white))),
                            DataCell(Text(
                                booking['futsalId']?['name']?.toString() ??
                                    'N/A',
                                style: const TextStyle(color: Colors.white))),
                            DataCell(Text(
                                booking['user']?['name']?.toString() ?? 'N/A',
                                style: const TextStyle(color: Colors.white))),
                            DataCell(Text(
                                booking['user']?['email']?.toString() ?? 'N/A',
                                style: const TextStyle(color: Colors.white))),
                            DataCell(Text(booking['bookingDate'] ?? 'N/A',
                                style: const TextStyle(color: Colors.white))),
                            DataCell(Text(booking['timeSlot'] ?? 'N/A',
                                style: const TextStyle(color: Colors.white))),
                            DataCell(Text(booking['paymentMethod'] ?? 'N/A',
                                style: const TextStyle(color: Colors.white))),
                            DataCell(Text(booking['status'] ?? 'N/A',
                                style: const TextStyle(color: Colors.white))),
                          ],
                        );
                      }).toList(),
                    ),
                  ),
                ),
    );
  }
}
