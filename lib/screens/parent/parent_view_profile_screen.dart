import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:napphy_services/services/auth_service.dart';
import 'package:napphy_services/services/firestore_service.dart';
import 'package:napphy_services/models/parent_model.dart';

class ParentViewProfileScreen extends StatelessWidget {
  const ParentViewProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authService = context.read<AuthService>();
    final firestoreService = context.read<FirestoreService>();
    final userId = authService.currentUser!.uid;

    return Scaffold(
      appBar: AppBar(title: const Text('Mi Perfil')),
      body: FutureBuilder<ParentModel?>(
        future: firestoreService.getParentProfile(userId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final parent = snapshot.data;

          if (parent == null) {
            return const Center(child: Text('Perfil no encontrado'));
          }

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              const CircleAvatar(
                radius: 60,
                child: Icon(Icons.person, size: 60),
              ),
              const SizedBox(height: 24),
              _InfoTile(
                icon: Icons.person,
                label: 'Nombre',
                value: authService.currentUserModel?.fullName ?? '',
              ),
              _InfoTile(
                icon: Icons.email,
                label: 'Correo',
                value: authService.currentUserModel?.email ?? '',
              ),
              _InfoTile(
                icon: Icons.phone,
                label: 'Teléfono',
                value: parent.phoneNumber,
              ),
              _InfoTile(
                icon: Icons.location_on,
                label: 'Dirección',
                value: parent.address,
              ),
            ],
          );
        },
      ),
    );
  }
}

class _InfoTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String? value;

  const _InfoTile({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: Icon(icon),
        title: Text(label),
        subtitle: Text(value ?? '—'),
      ),
    );
  }
}
