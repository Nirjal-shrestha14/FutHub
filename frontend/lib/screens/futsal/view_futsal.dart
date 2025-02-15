import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../services/auth_service.dart';

class ViewFutsal extends StatefulWidget {
  const ViewFutsal({super.key});

  @override
  State<ViewFutsal> createState() => _ViewFutsalState();
}

class _ViewFutsalState extends State<ViewFutsal> {
  List<dynamic> futsals = [];
  bool isLoading = true;

  // Update controllers to match AddFutsal
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  TimeOfDay _openingTime = const TimeOfDay(hour: 9, minute: 0);
  TimeOfDay _closingTime = const TimeOfDay(hour: 21, minute: 0);
  final List<String> _timeSlots = [];

  @override
  void initState() {
    super.initState();
    fetchFutsals();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _locationController.dispose();
    _priceController.dispose();
    _descriptionController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> fetchFutsals() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    setState(() {
      isLoading = true;
    });

    try {
      final response = await http.get(
        Uri.parse('${AuthService.baseUrl}/futsals/view-futsal'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        setState(() {
          futsals = responseData['futsals'];
          isLoading = false;
        });
      } else {
        print('Failed to load futsals: ${response.statusCode}');
        setState(() {
          isLoading = false;
        });
      }
    } catch (error) {
      print('Error fetching futsals: $error');
      setState(() {
        isLoading = false;
      });
    }
  }

  void _showEditDialog(Map<String, dynamic> futsal) {
    _nameController.text = futsal['name'];
    _locationController.text = futsal['location'];
    _priceController.text = futsal['price'].toString();
    _descriptionController.text = futsal['description'] ?? '';
    _phoneController.text = futsal['phone'] ?? '';

    if (futsal['timeSlots'] != null && futsal['timeSlots'].isNotEmpty) {
      String timeSlot = futsal['timeSlots'][0];
      List<String> times = timeSlot.split(' - ');
      if (times.length == 2) {
        try {
          List<String> openingHourMin = times[0].split(':');
          List<String> closingHourMin = times[1].split(':');
          _openingTime = TimeOfDay(
            hour: int.parse(openingHourMin[0]),
            minute: int.parse(openingHourMin[1]),
          );
          _closingTime = TimeOfDay(
            hour: int.parse(closingHourMin[0]),
            minute: int.parse(closingHourMin[1]),
          );
        } catch (e) {
          print('Error parsing time slots: $e');
        }
      }
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.grey[100],
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Container(
            width: MediaQuery.of(context).size.width *
                0.9, // Set width to 90% of screen width
            padding: const EdgeInsets.all(16),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Edit Futsal',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.deepPurpleAccent,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildTextField(_nameController, "Futsal Name"),
                  const SizedBox(height: 16),
                  _buildTextField(_locationController, "Location"),
                  const SizedBox(height: 16),
                  _buildTextField(
                    _priceController,
                    "Price",
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  ),
                  const SizedBox(height: 16),
                  _buildTextField(_descriptionController, "Description",
                      maxLines: 3),
                  const SizedBox(height: 16),
                  _buildTextField(
                    _phoneController,
                    "Phone Number",
                    keyboardType: TextInputType.phone,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  ),
                  const SizedBox(height: 16),
                  _buildTimePickerRow(
                    "Opening Time",
                    _openingTime,
                    () => _selectTime(context, true),
                  ),
                  const SizedBox(height: 16),
                  _buildTimePickerRow(
                    "Closing Time",
                    _closingTime,
                    () => _selectTime(context, false),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          height: 50,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            gradient: const LinearGradient(
                              colors: [
                                Colors.deepPurpleAccent,
                                Colors.pinkAccent
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                          ),
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.transparent,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            onPressed: () {
                              Navigator.of(context).pop();
                              _updateFutsal(futsal['_id']);
                            },
                            child: const Text(
                              'Update Futsal',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      TextButton(
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.grey,
                        ),
                        onPressed: () => Navigator.of(context).pop(),
                        child: const Text('Cancel'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    String label, {
    TextInputType? keyboardType,
    int maxLines = 1,
    List<TextInputFormatter>? inputFormatters,
  }) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.deepPurpleAccent),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
      keyboardType: keyboardType,
      maxLines: maxLines,
      inputFormatters: inputFormatters,
    );
  }

  Widget _buildTimePickerRow(String label, TimeOfDay time, VoidCallback onTap) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          '$label: ${time.format(context)}',
          style: const TextStyle(
            fontSize: 16,
            color: Colors.deepPurpleAccent,
          ),
        ),
        IconButton(
          icon: const Icon(
            Icons.access_time,
            color: Colors.deepPurpleAccent,
          ),
          onPressed: onTap,
        ),
      ],
    );
  }

  Future<void> _selectTime(BuildContext context, bool isOpeningTime) async {
    final TimeOfDay? selectedTime = await showTimePicker(
      context: context,
      initialTime: isOpeningTime ? _openingTime : _closingTime,
    );
    if (selectedTime != null) {
      setState(() {
        if (isOpeningTime) {
          _openingTime = selectedTime;
        } else {
          _closingTime = selectedTime;
        }
      });
    }
  }

  Future<void> _updateFutsal(String futsalId) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    String timeSlot =
        '${DateFormat('H:mm').format(DateTime(0, 0, 0, _openingTime.hour, _openingTime.minute))} - '
        '${DateFormat('H:mm').format(DateTime(0, 0, 0, _closingTime.hour, _closingTime.minute))}';

    try {
      final response = await http.put(
        Uri.parse('${AuthService.baseUrl}/futsals/edit/$futsalId'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'name': _nameController.text,
          'location': _locationController.text,
          'price': int.parse(_priceController.text),
          'description': _descriptionController.text,
          'phone': _phoneController.text,
          'timeSlots': [timeSlot],
        }),
      );

      debugPrint('Response status code: ${response.statusCode}');
      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Futsal updated successfully')),
        );
        fetchFutsals(); // Refresh the list
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to update futsal')),
        );
      }
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error updating futsal: $error')),
      );
    }
  }

  Future<void> deleteFutsal(String futsalId) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    try {
      final response = await http.delete(
        Uri.parse('${AuthService.baseUrl}/futsals/delete/$futsalId'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Futsal deleted successfully')),
        );
        setState(() {
          futsals.removeWhere((futsal) => futsal['_id'] == futsalId);
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to delete futsal')),
        );
      }
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error deleting futsal')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:
            const Text("List of Futsal", style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      backgroundColor: Colors.black,
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: futsals.length,
              itemBuilder: (context, index) {
                final futsal = futsals[index];
                return Card(
                  color: Colors.grey[900],
                  margin: const EdgeInsets.only(bottom: 16),
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              futsal['name'],
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.orange,
                              ),
                            ),
                            Row(
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.edit,
                                      color: Colors.orange),
                                  onPressed: () => _showEditDialog(futsal),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete,
                                      color: Colors.red),
                                  onPressed: () =>
                                      _showDeleteDialog(futsal['_id']),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Location: ${futsal['location']}',
                          style: const TextStyle(
                              fontSize: 16, color: Colors.white),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Price: Rs.${futsal['price']}',
                          style: const TextStyle(
                              fontSize: 16, color: Colors.white),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Status: ${futsal['approvalStatus']}',
                          style: TextStyle(
                            fontSize: 16,
                            color: futsal['approvalStatus'] == 'approved'
                                ? Colors.green
                                : Colors.orange,
                          ),
                        ),
                        const SizedBox(height: 8),
                        if (futsal['timeSlots'].isNotEmpty) ...[
                          const Text(
                            'Time Slots:',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          ...List<Widget>.from(
                            futsal['timeSlots'].map(
                              (slot) => Text(
                                '• $slot',
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: Colors.white70,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }

  void _showDeleteDialog(String futsalId) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.grey[900],
          title: const Text('Confirm Delete',
              style: TextStyle(color: Colors.white)),
          content: const Text('Are you sure you want to delete this futsal?',
              style: TextStyle(color: Colors.white)),
          actions: [
            TextButton(
              child:
                  const Text('Cancel', style: TextStyle(color: Colors.orange)),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: const Text('Delete', style: TextStyle(color: Colors.red)),
              onPressed: () {
                Navigator.of(context).pop();
                deleteFutsal(futsalId);
              },
            ),
          ],
        );
      },
    );
  }
}
