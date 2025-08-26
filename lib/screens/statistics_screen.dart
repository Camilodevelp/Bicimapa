import 'package:flutter/material.dart';
import '../services/user_service.dart';

class StatisticsScreen extends StatelessWidget {
  const StatisticsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final userService = UserService();
    final user = userService.getUserById('1'); // Obtenemos el primer usuario simulado

    return Scaffold(
      appBar: AppBar(
        title: const Text('Estadísticas de Recorridos'),
      ),
      body: user != null
          ? Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Rutas completadas: ${user.completedRoutes}',
                    style: const TextStyle(fontSize: 18),
                  ),
                  const SizedBox(height: 8),
                  // Valores simulados por ahora
                  const Text(
                    'Distancia total recorrida: 85 km',
                    style: TextStyle(fontSize: 18),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Tiempo total de pedaleo: 6h 30m',
                    style: TextStyle(fontSize: 18),
                  ),
                ],
              ),
            )
          : const Center(child: Text('Usuario no encontrado')),
    );
  }
}

