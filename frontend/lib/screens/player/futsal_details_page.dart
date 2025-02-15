import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:khalti/khalti.dart';
import '../../services/auth_service.dart';
import '../../services/khalti_services.dart';
import '../../models/futsal_model.dart';

class FutsalDetailsPage extends StatefulWidget {
  const FutsalDetailsPage({super.key, this.futsal});
  final Futsal? futsal;

  @override
  _FutsalDetailsPageState createState() => _FutsalDetailsPageState();
}

class _FutsalDetailsPageState extends State<FutsalDetailsPage> {
  DateTime? selectedDate;
  String? selectedTimeSlot;
  int _currentImageIndex = 0;
  Timer? _timer;

  final List<String> timeSlots = [
    "06:00 AM - 07:00 AM",
    "07:00 AM - 08:00 AM",
    "08:00 AM - 09:00 AM",
    "05:00 PM - 06:00 PM",
    "06:00 PM - 07:00 PM",
    "07:00 PM - 08:00 PM",
  ];

  final List<String> imageUrls = [
    'assets/f1.jpeg',
    'assets/f2.jpeg',
    'assets/f3.jpeg',
  ];

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 3), (Timer timer) {
      if (_currentImageIndex < imageUrls.length - 1) {
        setState(() {
          _currentImageIndex++;
        });
      } else {
        setState(() {
          _currentImageIndex = 0;
        });
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _selectDate() async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 30)),
      builder: (context, child) {
        return Theme(
          data: ThemeData.dark().copyWith(
            colorScheme: const ColorScheme.dark(
              primary: Colors.orange,
              onPrimary: Colors.white,
              surface: Color(0xFF1E1E1E),
              onSurface: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );

    setState(() {
      selectedDate = pickedDate;
    });
  }

  void _showErrorSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  Future<void> _processBooking() async {
    if (selectedDate == null || selectedTimeSlot == null) {
      _showErrorSnackbar("Please select both date and time slot");
      return;
    }

    final futsalId = widget.futsal?.id;
    const apiUrl = '${AuthService.baseUrl}/bookings';
    String? token = await AuthService().getToken();
    final data = json.encode({
      'futsalId': futsalId ?? '',
      'paymentMethod': 'Khalti',
      'bookingDate': DateFormat('yyyy-MM-dd').format(selectedDate!),
      'timeSlot': selectedTimeSlot!,
      'status': 'confirmed'
    });

    final response = await http.post(
      Uri.parse(apiUrl),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: data,
    );

    if (response.statusCode == 201) {
      KhaltiRepository().makePayment(
        context: context,
        amount: (widget.futsal?.price ?? 0) * 100,
        productIdentity: "court",
        productName: "Futsal",
        onSuccess: (PaymentSuccessModel response) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Payment successful"),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.pop(context);
        },
        onFailure: (PaymentFailureModel response) {
          _showErrorSnackbar("Payment failed");
        },
        onCancel: () {
          _showErrorSnackbar("Payment canceled");
        },
      );
    } else {
      _showErrorSnackbar(response.body);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.futsal == null) {
      return const Scaffold(
        body: Center(child: Text('No futsal details available')),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        title: Text(
          widget.futsal!.name ?? 'Futsal Details',
          style: const TextStyle(color: Colors.orange),
        ),
        backgroundColor: const Color(0xFF1E1E1E),
        iconTheme: const IconThemeData(color: Colors.orange),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image Carousel
            Stack(
              children: [
                SizedBox(
                  height: 200,
                  width: double.infinity,
                  child: PageView.builder(
                    itemCount: imageUrls.length,
                    onPageChanged: (index) {
                      setState(() {
                        _currentImageIndex = index;
                      });
                    },
                    itemBuilder: (context, index) {
                      return Image.asset(
                        imageUrls[index],
                        fit: BoxFit.cover,
                      );
                    },
                  ),
                ),
                Positioned(
                  bottom: 10,
                  left: 0,
                  right: 0,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: imageUrls.asMap().entries.map((entry) {
                      return Container(
                        width: 8.0,
                        height: 8.0,
                        margin: const EdgeInsets.symmetric(horizontal: 4.0),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.orange.withOpacity(
                            _currentImageIndex == entry.key ? 0.9 : 0.4,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),

            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Name and Price
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          widget.futsal?.name ?? 'Unknown Futsal',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.orange,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          'NPR ${widget.futsal!.price ?? 'N/A'}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Location
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1E1E1E),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.location_on, color: Colors.orange),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            widget.futsal!.location ?? 'Location not available',
                            style: const TextStyle(
                                color: Colors.white, fontSize: 16),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Date Selection
                  const Text(
                    'Select Booking Date',
                    style: TextStyle(
                      color: Colors.orange,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  InkWell(
                    onTap: _selectDate,
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1E1E1E),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.orange),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            selectedDate == null
                                ? 'Choose a date'
                                : DateFormat('yyyy-MM-dd').format(selectedDate!),
                            style: const TextStyle(
                                color: Colors.white, fontSize: 16),
                          ),
                          const Icon(Icons.calendar_today, color: Colors.orange),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Time Slot Selection
                  const Text(
                    'Select Time Slot',
                    style: TextStyle(
                      color: Colors.orange,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1E1E1E),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.orange),
                    ),
                    child: DropdownButton<String>(
                      isExpanded: true,
                      dropdownColor: const Color(0xFF1E1E1E),
                      underline: const SizedBox(),
                      hint: const Text("Choose a time slot",
                          style: TextStyle(color: Colors.white)),
                      value: selectedTimeSlot,
                      style: const TextStyle(color: Colors.white),
                      onChanged: (newValue) {
                        setState(() {
                          selectedTimeSlot = newValue;
                        });
                      },
                      // items: widget.futsal!.timeSlots.map((slot) {
                      //   return DropdownMenuItem(
                      //     value: slot,
                      //     child: Text(slot),
                      //   );
                      items: timeSlots.map((slot) {
                  return DropdownMenuItem(
                    value: slot,
                    child: Text(slot, style: const TextStyle(fontSize: 16)),
                  );
                      }).toList(),
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Book Now Button
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _processBooking,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25),
                        ),
                      ),
                      child: const Text(
                        'Pay with Khalti',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}