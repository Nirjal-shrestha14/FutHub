// admin_profile_page.dart
import 'package:flutter/material.dart';
import '../profile/base_profile_page.dart';

class AdminProfilePage extends StatelessWidget {
  const AdminProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return const BaseProfilePage(
      title: "Admin Profile",
      primaryColor: Colors.orange,
    );
  }
}