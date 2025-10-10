import 'package:flutter/material.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Datos de ejemplo - en producción, estos vendrían de Firebase
    final notifications = [
      {
        'title': 'Nueva solicitud de contratación',
        'message': 'Tienes una nueva solicitud de contratación para el 15 de enero',
        'time': '2 horas atrás',
        'icon': Icons.work,
        'color': Colors.blue,
      },
      {
        'title': 'Mensaje nuevo',
        'message': 'María te envió un mensaje',
        'time': '4 horas atrás',
        'icon': Icons.message,
        'color': Colors.green,
      },
      {
        'title': 'Reserva confirmada',
        'message': 'Tu reserva para el 12 de enero ha sido confirmada',
        'time': 'Ayer',
        'icon': Icons.check_circle,
        'color': Colors.green,
      },
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text('Notificaciones'),
        actions: [
          TextButton(
            onPressed: () {
              // TODO: Marcar todas como leídas
            },
            child: Text('Marcar todas como leídas'),
          ),
        ],
      ),
      body: notifications.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.notifications_none,
                    size: 80,
                    color: Colors.grey,
                  ),
                  SizedBox(height: 16),
                  Text(
                    'No tienes notificaciones',
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                ],
              ),
            )
          : ListView.builder(
              itemCount: notifications.length,
              itemBuilder: (context, index) {
                final notification = notifications[index];
                return ListTile(
                  leading: CircleAvatar(
                    backgroundColor:
                        (notification['color'] as Color).withOpacity(0.1),
                    child: Icon(
                      notification['icon'] as IconData,
                      color: notification['color'] as Color,
                    ),
                  ),
                  title: Text(
                    notification['title'] as String,
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 4),
                      Text(notification['message'] as String),
                      SizedBox(height: 4),
                      Text(
                        notification['time'] as String,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                  isThreeLine: true,
                  onTap: () {
                    // TODO: Navegar a la pantalla correspondiente
                  },
                );
              },
            ),
    );
  }
}
