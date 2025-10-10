import 'package:flutter/material.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _notificationsEnabled = true;
  bool _emailNotifications = true;
  bool _pushNotifications = true;
  bool _darkMode = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Configuración'),
      ),
      body: ListView(
        children: [
          _buildSection(
            title: 'Notificaciones',
            children: [
              SwitchListTile(
                title: Text('Habilitar notificaciones'),
                subtitle: Text('Recibir todas las notificaciones'),
                value: _notificationsEnabled,
                onChanged: (value) {
                  setState(() {
                    _notificationsEnabled = value;
                  });
                },
              ),
              SwitchListTile(
                title: Text('Notificaciones por email'),
                subtitle: Text('Recibir notificaciones por correo'),
                value: _emailNotifications,
                onChanged: _notificationsEnabled
                    ? (value) {
                        setState(() {
                          _emailNotifications = value;
                        });
                      }
                    : null,
              ),
              SwitchListTile(
                title: Text('Notificaciones push'),
                subtitle: Text('Recibir notificaciones en el dispositivo'),
                value: _pushNotifications,
                onChanged: _notificationsEnabled
                    ? (value) {
                        setState(() {
                          _pushNotifications = value;
                        });
                      }
                    : null,
              ),
            ],
          ),
          Divider(height: 1),
          _buildSection(
            title: 'Apariencia',
            children: [
              SwitchListTile(
                title: Text('Modo oscuro'),
                subtitle: Text('Usar tema oscuro en la aplicación'),
                value: _darkMode,
                onChanged: (value) {
                  setState(() {
                    _darkMode = value;
                  });
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Funcionalidad próximamente disponible'),
                    ),
                  );
                },
              ),
            ],
          ),
          Divider(height: 1),
          _buildSection(
            title: 'Cuenta',
            children: [
              ListTile(
                leading: Icon(Icons.person),
                title: Text('Editar perfil'),
                trailing: Icon(Icons.chevron_right),
                onTap: () {
                  // Ya está implementado en las pantallas de cada rol
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: Icon(Icons.lock),
                title: Text('Cambiar contraseña'),
                trailing: Icon(Icons.chevron_right),
                onTap: () {
                  _showChangePasswordDialog();
                },
              ),
              ListTile(
                leading: Icon(Icons.privacy_tip),
                title: Text('Privacidad'),
                trailing: Icon(Icons.chevron_right),
                onTap: () {
                  _showPrivacyDialog();
                },
              ),
            ],
          ),
          Divider(height: 1),
          _buildSection(
            title: 'Soporte',
            children: [
              ListTile(
                leading: Icon(Icons.help),
                title: Text('Ayuda'),
                trailing: Icon(Icons.chevron_right),
                onTap: () {
                  _showHelpDialog();
                },
              ),
              ListTile(
                leading: Icon(Icons.info),
                title: Text('Acerca de'),
                trailing: Icon(Icons.chevron_right),
                onTap: () {
                  _showAboutDialog();
                },
              ),
              ListTile(
                leading: Icon(Icons.feedback),
                title: Text('Enviar comentarios'),
                trailing: Icon(Icons.chevron_right),
                onTap: () {
                  _showFeedbackDialog();
                },
              ),
            ],
          ),
          Divider(height: 1),
          Padding(
            padding: EdgeInsets.all(16),
            child: Text(
              'Versión 1.0.0',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required List<Widget> children,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Text(
            title,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
        ),
        ...children,
      ],
    );
  }

  void _showChangePasswordDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Cambiar contraseña'),
        content: Text('Esta funcionalidad estará disponible próximamente.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showPrivacyDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Privacidad'),
        content: SingleChildScrollView(
          child: Text(
            'En Napphy Services valoramos tu privacidad. '
            'Todos tus datos personales están protegidos y cifrados. '
            'No compartimos tu información con terceros sin tu consentimiento.',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showHelpDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Ayuda'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('¿Necesitas ayuda?'),
            SizedBox(height: 16),
            Text('Email: soporte@napphy.com'),
            Text('Teléfono: +1 234 567 890'),
            SizedBox(height: 16),
            Text('Horario de atención:'),
            Text('Lun - Vie: 9:00 AM - 6:00 PM'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showAboutDialog() {
    showAboutDialog(
      context: context,
      applicationName: 'Napphy Services',
      applicationVersion: '1.0.0',
      applicationIcon: Icon(Icons.child_care, size: 48),
      children: [
        SizedBox(height: 16),
        Text(
          'Napphy Services es una plataforma que conecta a padres '
          'con niñeras y cuidadores confiables.',
        ),
      ],
    );
  }

  void _showFeedbackDialog() {
    final feedbackController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Enviar comentarios'),
        content: TextField(
          controller: feedbackController,
          maxLines: 4,
          decoration: InputDecoration(
            hintText: 'Cuéntanos tu experiencia...',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('¡Gracias por tus comentarios!')),
              );
            },
            child: Text('Enviar'),
          ),
        ],
      ),
    );
  }
}
