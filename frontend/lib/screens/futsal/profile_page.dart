// owner_profile_page.dart
import 'package:flutter/material.dart';
import '../profile/base_profile_page.dart';

class OwnerProfilePage extends StatelessWidget {
  const OwnerProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return const BaseProfilePage(
      title: "Owner Profile",
      primaryColor: Colors.orange,
    );
  }
}