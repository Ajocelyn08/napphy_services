import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:napphy_services/services/auth_service.dart';
import 'package:napphy_services/services/firestore_service.dart';
import 'package:napphy_services/models/nanny_model.dart';
import 'package:napphy_services/config/routes.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final List<Widget> screens = [
      _DashboardTab(),
      _PendingNanniesTab(),
      _UsersTab(),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Panel Administrativo'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              final authService = Provider.of<AuthService>(context, listen: false);
              await authService.signOut();
              Navigator.pushReplacementNamed(context, Routes.login);
            },
          ),
        ],
      ),
      body: screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.pending_actions),
            label: 'Pendientes',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.people),
            label: 'Usuarios',
          ),
        ],
      ),
    );
  }
}

class _DashboardTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Resumen',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            mainAxisSpacing: 16,
            crossAxisSpacing: 16,
            children: const [
              _StatCard(
                title: 'Usuarios Totales',
                value: '150',
                icon: Icons.people,
                color: Colors.blue,
              ),
              _StatCard(
                title: 'Niñeras Activas',
                value: '45',
                icon: Icons.child_care,
                color: Colors.green,
              ),
              _StatCard(
                title: 'Padres',
                value: '105',
                icon: Icons.family_restroom,
                color: Colors.orange,
              ),
              _StatCard(
                title: 'Pendientes',
                value: '8',
                icon: Icons.pending,
                color: Colors.red,
              ),
            ],
          ),
          const SizedBox(height: 24),
          const Text(
            'Actividad Reciente',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          const _ActivityCard(
            icon: Icons.person_add,
            title: 'Nueva niñera registrada',
            subtitle: 'María González - Hace 2 horas',
            color: Colors.green,
          ),
          const _ActivityCard(
            icon: Icons.check_circle,
            title: 'Contratación completada',
            subtitle: 'Juan Pérez - Hace 5 horas',
            color: Colors.blue,
          ),
          const _ActivityCard(
            icon: Icons.report,
            title: 'Reporte recibido',
            subtitle: 'Usuario #1234 - Hace 1 día',
            color: Colors.red,
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 40, color: color),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ActivityCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;

  const _ActivityCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: color.withOpacity(0.1),
          child: Icon(icon, color: color),
        ),
        title: Text(title),
        subtitle: Text(subtitle),
      ),
    );
  }
}

class _PendingNanniesTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final firestoreService = Provider.of<FirestoreService>(context);

    return StreamBuilder<List<NannyModel>>(
      stream: firestoreService.getNanniesStream(isApproved: false),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        final pendingNannies = snapshot.data ?? [];

        if (pendingNannies.isEmpty) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.check_circle_outline,
                  size: 80,
                  color: Colors.grey,
                ),
                SizedBox(height: 16),
                Text(
                  'No hay niñeras pendientes',
                  style: TextStyle(fontSize: 18, color: Colors.grey),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: pendingNannies.length,
          itemBuilder: (context, index) {
            final nanny = pendingNannies[index];
            return _PendingNannyCard(nanny: nanny);
          },
        );
      },
    );
  }
}

class _PendingNannyCard extends StatelessWidget {
  final NannyModel nanny;

  const _PendingNannyCard({required this.nanny});

  @override
  Widget build(BuildContext context) {
    final firestoreService = Provider.of<FirestoreService>(context, listen: false);

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  child: nanny.photoUrl != null
                      ? ClipOval(
                          child: Image.network(
                            nanny.photoUrl!,
                            width: 60,
                            height: 60,
                            fit: BoxFit.cover,
                          ),
                        )
                      : const Icon(Icons.person, size: 30, color: Colors.white),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Niñera #${nanny.id.substring(0, 6)}',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text('Edad: ${nanny.age} años'),
                      Text('Tarifa: \$${nanny.hourlyRate}/hora'),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Text(
              'Biografía:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Text(nanny.bio.isNotEmpty ? nanny.bio : 'Sin biografía'),
            const SizedBox(height: 12),
            Text(
              'Dirección: ${nanny.address}',
              style: TextStyle(color: Colors.grey[600]),
            ),
            const SizedBox(height: 12),
            if (nanny.certifications.isNotEmpty) ...[
              const Text(
                'Certificaciones:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              ...nanny.certifications.map((cert) => Text('• $cert')),
              const SizedBox(height: 12),
            ],
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () async {
                      await firestoreService.approveNanny(nanny.userId);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Niñera aprobada'),
                          backgroundColor: Colors.green,
                        ),
                      );
                    },
                    icon: const Icon(Icons.check),
                    label: const Text('Aprobar'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text('Rechazar solicitud'),
                          content: const Text(
                              '¿Estás seguro de rechazar esta solicitud?'),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: const Text('Cancelar'),
                            ),
                            TextButton(
                              onPressed: () async {
                                // TODO: Implementar rechazo
                                Navigator.pop(context);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Solicitud rechazada')),
                                );
                              },
                              child: const Text('Rechazar'),
                            ),
                          ],
                        ),
                      );
                    },
                    icon: const Icon(Icons.close),
                    label: const Text('Rechazar'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.red,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _UsersTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.people, size: 80, color: Colors.grey),
          SizedBox(height: 16),
          Text(
            'Lista de usuarios',
            style: TextStyle(fontSize: 18, color: Colors.grey),
          ),
          SizedBox(height: 8),
          Text(
            'Funcionalidad próximamente disponible',
            style: TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }
}
