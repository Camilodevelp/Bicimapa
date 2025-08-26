import 'package:flutter/material.dart';
import '../widgets/user_info_card.dart';
import '../services/user_service.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final userService = UserService();
    final user = userService.getUserById('1'); // Obtenemos el primer usuario simulado

    return Scaffold(
      appBar: AppBar(
        title: const Text('Perfil de Usuario'),
      ),
      body: user != null
          ? UserInfoCard(user: user)
          : const Center(child: Text('Usuario no encontrado')),
    );
  }
}

