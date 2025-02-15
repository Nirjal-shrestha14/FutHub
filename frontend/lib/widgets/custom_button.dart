import 'package:flutter/material.dart';

class CustomButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;
  final Color color;
  final Color textColor;

  // Constructor
  const CustomButton({super.key, 
    required this.label,
    required this.onPressed,
    this.color = Colors.blue,  // Default button color
    this.textColor = Colors.white,  // Default text color
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,  // Action to execute on button press
      style: ElevatedButton.styleFrom(
        backgroundColor: color,  // Set button color
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),  // Rounded corners
        ),
        padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 30),
      ),
      child: Text(
        label,
        style: TextStyle(color: textColor, fontSize: 16),
      ),
    );
  }
}
