import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../services/auth_service.dart';

class AddFutsalPage extends StatefulWidget {
  const AddFutsalPage({super.key});

  @override
  _AddFutsalPageState createState() => _AddFutsalPageState();
}

class _AddFutsalPageState extends State<AddFutsalPage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final List<String> _timeSlots = [];

  TimeOfDay _openingTime = TimeOfDay(hour: 9, minute: 0);
  TimeOfDay _closingTime = TimeOfDay(hour: 21, minute: 0);

  File? _imageFile;
  final List<File> _imageFiles = [];
  Uint8List? _webImage;
  final List<Uint8List> _webImages = [];

  bool _isLoading = false;

  // All the existing methods remain the same
  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      if (kIsWeb) {
        final bytes = await pickedFile.readAsBytes();
        setState(() {
          _webImages.add(bytes);
        });
      } else {
        setState(() {
          _imageFiles.add(File(pickedFile.path));
        });
      }
    }
  }

  bool _validateFields() {
    return _nameController.text.isNotEmpty &&
        _addressController.text.isNotEmpty &&
        _priceController.text.isNotEmpty &&
        _descriptionController.text.isNotEmpty &&
        _phoneController.text.isNotEmpty &&
        (_imageFiles.isNotEmpty || _webImages.isNotEmpty);
  }

  Future<void> _saveFutsal() async {
    if (_validateFields()) {
      setState(() {
        _isLoading = true;
      });
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      if (token == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('You need to log in again.')),
        );
        return;
      }
      String timeSlot =
          '${DateFormat('H:mm').format(DateTime(0, 0, 0, _openingTime.hour, _openingTime.minute))} - '
          '${DateFormat('H:mm').format(DateTime(0, 0, 0, _closingTime.hour, _closingTime.minute))}';
      _timeSlots.add(timeSlot);

      final data = json.encode({
        'name': _nameController.text,
        'location': _addressController.text,
        'price': _priceController.text,
        'description': _descriptionController.text,
        'phone': _phoneController.text,
        'timeSlots': _timeSlots,
      });

      try {
        final uri = Uri.parse('${AuthService.baseUrl}/futsals/add');
        var response = await http.post(
          uri,
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token',
          },
          body: data,
        );
        if (response.statusCode == 201) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Futsal details saved successfully!')),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Failed to save futsal details!')),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Something went wrong. Please try again!')),
        );
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text(
                'Please fill in all fields and upload at least one image.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        title: const Text(
          'Add Futsal',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color(0xFF1E1E1E),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Card(
            color: const Color(0xFF1E1E1E),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildTextField(_nameController, "Futsal Name"),
                  const SizedBox(height: 16),
                  _buildTextField(_addressController, "Address"),
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
                  _buildImagePicker(),
                  const SizedBox(height: 16),
                  _buildTimePickerRow("Opening Time", _openingTime,
                      () => _selectTime(context, true)),
                  const SizedBox(height: 16),
                  _buildTimePickerRow("Closing Time", _closingTime,
                      () => _selectTime(context, false)),
                  const SizedBox(height: 24),
                  _isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFFFC107),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            onPressed: _saveFutsal,
                            child: const Text(
                              'Save Futsal',
                              style: TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label,
      {TextInputType? keyboardType,
      int maxLines = 1,
      List<TextInputFormatter>? inputFormatters}) {
    return TextField(
      controller: controller,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.grey),
        filled: true,
        fillColor: const Color(0xFF2E2E2E),
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

  Widget _buildImagePicker() {
    return GestureDetector(
      onTap: _pickImage,
      child: Container(
        width: double.infinity,
        height: 150,
        decoration: BoxDecoration(
          color: const Color(0xFF2E2E2E),
          borderRadius: BorderRadius.circular(12),
        ),
        child: _webImages.isNotEmpty || _imageFiles.isNotEmpty
            ? ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: _webImages.isNotEmpty
                    ? _webImages.length
                    : _imageFiles.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image(
                        image: kIsWeb
                            ? MemoryImage(_webImages[index])
                            : FileImage(_imageFiles[index]) as ImageProvider,
                        fit: BoxFit.cover,
                        width: 80,
                        height: 80,
                      ),
                    ),
                  );
                },
              )
            : const Center(
                child: Icon(Icons.add_a_photo, color: Colors.grey, size: 40),
              ),
      ),
    );
  }

  Widget _buildTimePickerRow(String label, TimeOfDay time, VoidCallback onTap) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          '$label: ${time.format(context)}',
          style: const TextStyle(fontSize: 16, color: Colors.grey),
        ),
        IconButton(
          icon: const Icon(Icons.access_time, color: Color(0xFFFFC107)),
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
}