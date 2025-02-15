// player_profile_page.dart
import 'package:flutter/material.dart';
import '../profile/base_profile_page.dart';

class PlayerProfilePage extends StatelessWidget {
  const PlayerProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return const BaseProfilePage(
      title: "Player Profile",
      primaryColor: Colors.orange,
    );
  }
}