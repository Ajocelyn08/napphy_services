import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:napphy_services/services/auth_service.dart';
import 'package:napphy_services/services/firestore_service.dart';
import 'package:napphy_services/models/nanny_model.dart';

class NannyViewProfileScreen extends StatelessWidget {
  const NannyViewProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.read<AuthService>();
    final firestore = context.read<FirestoreService>();
    final userId = auth.currentUser!.uid;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mi Perfil'),
      ),
      body: FutureBuilder<NannyModel?>(
        future: firestore.getNannyProfile(userId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Text(
                'Error al obtener perfil:\n${snapshot.error}',
                textAlign: TextAlign.center,
              ),
            );
          }

          if (!snapshot.hasData || snapshot.data == null) {
            return const Center(child: Text('Perfil no encontrado'));
          }

          final nanny = snapshot.data!;

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Center(
                child: CircleAvatar(
                  radius: 60,
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  child: nanny.photoUrl != null
                      ? ClipOval(
                          child: Image.network(
                            nanny.photoUrl!,
                            width: 120,
                            height: 120,
                            fit: BoxFit.cover,
                          ),
                        )
                      : const Icon(Icons.person, size: 60, color: Colors.white),
                ),
              ),
              const SizedBox(height: 16),
              _card('Biografía', nanny.bio),
              _card('Dirección', nanny.address),
              _card('Tarifa por hora', '\$${nanny.hourlyRate}'),
              _card('Años de experiencia', '${nanny.yearsOfExperience}'),
              _card(
                'Disponibilidad',
                nanny.isAvailable ? 'Disponible' : 'No disponible',
              ),
              _card(
                'Calificación',
                '${nanny.rating.toStringAsFixed(1)} ⭐ (${nanny.totalReviews} reseñas)',
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _card(String title, String value) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        title: Text(title),
        subtitle: Text(value),
      ),
    );
  }
}
