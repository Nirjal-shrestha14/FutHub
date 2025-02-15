import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:khalti/khalti.dart';

import '../../services/auth_service.dart';
import '../../services/khalti_services.dart'; // Import http package

class PaymentPage extends StatefulWidget {
  const PaymentPage({super.key, this.amount = 0, this.futsalId});

  final int amount;
  final String? futsalId;

  @override
  _PaymentPageState createState() => _PaymentPageState();
}

class _PaymentPageState extends State<PaymentPage> {
  DateTime? selectedDate;
  String? selectedTimeSlot;

  final List<String> timeSlots = [
    "06:00 AM - 07:00 AM",
    "07:00 AM - 08:00 AM",
    "08:00 AM - 09:00 AM",
    "05:00 PM - 06:00 PM",
    "06:00 PM - 07:00 PM",
    "07:00 PM - 08:00 PM",
  ];

  void _selectDate() async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 30)),
    );

    setState(() {
      selectedDate = pickedDate;
    });
  }

  // Function to call the API
  Future<void> makePayment(String paymentMethod) async {
    if (selectedDate == null || selectedTimeSlot == null) {
      _showErrorSnackbar();
      return;
    }

    final futsalId = ModalRoute.of(context)?.settings.arguments as String?;

    const apiUrl = '${AuthService.baseUrl}/bookings';
    String? token = await AuthService().getToken();
    final data = json.encode({
      'futsalId': futsalId ?? '',
      'paymentMethod': paymentMethod,
      'bookingDate': DateFormat('yyyy-MM-dd').format(selectedDate!),
      'timeSlot': selectedTimeSlot!,
      'status': 'confirmed'
    });

    debugPrint('Data: $data');
    final response = await http.post(
      Uri.parse(apiUrl),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: data,
    );
    print(response.statusCode);

    if (response.statusCode == 201) {
      print('Payment successful');
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Booking successful!"),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(response.body),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _showErrorSnackbar() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Booking already exists for this time slot"),
        backgroundColor: Colors.red,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Book Your Futsal'),
        backgroundColor: Colors.deepPurple,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Select Booking Date',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            InkWell(
              onTap: _selectDate,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.grey),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      selectedDate == null
                          ? 'Choose a date'
                          : DateFormat('yyyy-MM-dd').format(selectedDate!),
                      style: const TextStyle(fontSize: 16),
                    ),
                    const Icon(Icons.calendar_today, color: Colors.deepPurple),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Select Time Slot',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.grey),
              ),
              child: DropdownButton<String>(
                isExpanded: true,
                underline: const SizedBox(),
                hint: const Text("Choose a time slot"),
                value: selectedTimeSlot,
                onChanged: (newValue) {
                  setState(() {
                    selectedTimeSlot = newValue;
                  });
                },
                items: timeSlots.map((slot) {
                  return DropdownMenuItem(
                    value: slot,
                    child: Text(slot, style: const TextStyle(fontSize: 16)),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 30),
            const Text(
              'Select Payment Method',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            _buildPaymentButton(
              label: "Pay with Khalti",
              imageUrl:
                  'data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAQ4AAACUCAMAAABV5TcGAAAAsVBMVEX///9gu0coKT0AAABdukP8/P0lJjsAACAhIjgdHjWpqa9buUAaGzMqKz4AACPy8vMAABwGCSnc3N7Q0NO9vcFdXWrl5ecAAAoAACbG5b+xsbZJtCdWuDkAABjGxsqamqGw2qWKipL2+/UPES2RzYM0NUYAABLQ6cp3d4Fsv1Zvb3k9Pk5ywV5ISFbq9ehRUl+JynrZ7dW637Kf05N8xWk+sRJ/f38ZGSsTEylERERPT1HtBU3YAAALoklEQVR4nO2ba5uiuBaFEQEDBJGrFCKIiGWBiFrWmT7n//+wk3AzRLRmpsuZqZ68H/ppEShY7Oy9sokcx2AwGAwGg8FgMBgMBoPBYDAYDAaDwWAwGAwGg8FgMBgMBoPBYDAYDAaD8c9ijfkD++uIp13M38r65f2yr7gcV6+/QxNXycoCUWaRiT9b9i+jzPq8HwmCqqrNP8Lo+Pr4CDcDACbe1EugLIM01s2idP+ai302h80iQAqQCOoieH8QIj5MQGKUu3jnQEOWQDIxkuKXkOPwjsQY3SIsFuc7gojRFMi8ItafLEcGGs+D/BeQY/0qBANa1Cz2p6FjRCWRYElkCj+FPC/x31+Ow+pjKDJa1GAoQEIN9NRAAZJDXkq+vRyH4+KBGHjEBO8H+iDdSSQ57G+zNZlfWn/VZT+J0+X+QOn02FB6iP5SS3ZUURWjhN9SEn03Thf1MzVwjaH00FPAT336XG6WTHzxL7v0J3A40moIahDcKCRQFdeaa5J0Gwh2Oom+sxzr9/5IUReLYH/c7IMFrUhwJo+Lprxc3KYJPdvG31mOl14WDT5G5wOOgjX3+kbn1wU5XBzIy6V5e77I231jOQ497xUcyTteUXqoI+LLXNZAOlBE3LL4xpMWcqgIoxcUFofV8biqVXmlfOqCGC65jCzGUBH5T/l95TgQAaBi87l+/wiCYIGFQbyolB7XIwuZ5weLyPcVg+MIx6G+odnrujFkqlr5cjrPBqvuSCfRNJh9ewfagwwOYcURYyc4VmX1tO/VF+GaPWKP5/nkxnh8a4iHr+L7J+6+KSOrfngIL+2h9hbJIef233btT2AkXJ87vtHVtd/xUafN17de9hCO7aEuloOHufJ3XfvXQ4wVdY83bHAsIE+6+AgudXRQnlXYt9ZUR8YD66Htfpn8QYyEKkkeLovFx2K/Wb0eDs1tncHiZ2P//Mno7UtZf77U0xWzxlGei3lgBzcYAAkZaFbzywF1PQQ2TT31mH5M1N2dRz0TATf7wAEAAAAElFTkSuQmCC',
              paymentMethod: 'Khalti',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentButton(
      {required String label,
      required String imageUrl,
      required String paymentMethod}) {
    return ElevatedButton(
      onPressed: () async {
        if (selectedDate == null || selectedTimeSlot == null) {
          _showErrorSnackbar();
          return;
        }
        final futsalId = widget.futsalId;
        const apiUrl = '${AuthService.baseUrl}/bookings';
        String? token = await AuthService().getToken();
        final data = json.encode({
          'futsalId': futsalId ?? '',
          'paymentMethod': paymentMethod,
          'bookingDate': DateFormat('yyyy-MM-dd').format(selectedDate!),
          'timeSlot': selectedTimeSlot!,
          'status': 'confirmed'
        });

        debugPrint('Data: $data');
        final response = await http.post(
          Uri.parse(apiUrl),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token',
          },
          body: data,
        );
        print(response.statusCode);

        if (response.statusCode == 201) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Booking successful!"),
              backgroundColor: Colors.green,
            ),
          );
          KhaltiRepository().makePayment(
            context: context,
            amount: widget.amount * 100,
            productIdentity: "court",
            productName: "Futsal",
            onSuccess: (PaymentSuccessModel response) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text("Payment successful"),
                  backgroundColor: Colors.green,
                ),
              );
            },
            onFailure: (PaymentFailureModel response) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text("Payment failed"),
                  backgroundColor: Colors.red,
                ),
              );
            },
            onCancel: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text("Payment canceled"),
                  backgroundColor: Colors.red,
                ),
              );
            },
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(response.body),
              backgroundColor: Colors.red,
            ),
          );
        }
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 25),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(width: 10),
          Text(
            label,
            style: const TextStyle(fontSize: 16),
          ),
        ],
      ),
    );
  }
}
