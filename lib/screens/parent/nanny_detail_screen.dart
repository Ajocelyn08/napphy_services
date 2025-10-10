import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:napphy_services/services/auth_service.dart';
import 'package:napphy_services/services/firestore_service.dart';
import 'package:napphy_services/services/chat_service.dart';
import 'package:napphy_services/models/nanny_model.dart';
import 'package:napphy_services/models/user_model.dart';
import 'package:napphy_services/models/booking_model.dart';
import 'package:napphy_services/models/review_model.dart';
import 'package:napphy_services/config/routes.dart';

class NannyDetailScreen extends StatefulWidget {
  final String nannyId;

  const NannyDetailScreen({super.key, required this.nannyId});

  @override
  State<NannyDetailScreen> createState() => _NannyDetailScreenState();
}

class _NannyDetailScreenState extends State<NannyDetailScreen> {
  NannyModel? _nanny;
  UserModel? _nannyUser;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadNannyData();
  }

  Future<void> _loadNannyData() async {
    final firestoreService = Provider.of<FirestoreService>(context, listen: false);

    try {
      final nanny = await firestoreService.getNannyProfile(widget.nannyId);
      // Cargar tambiÃ©n datos del usuario
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.nannyId)
          .get();

      setState(() {
        _nanny = nanny;
        _nannyUser = UserModel.fromFirestore(userDoc);
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al cargar datos: $e')),
      );
    }
  }

  Future<void> _sendMessage() async {
    final authService = Provider.of<AuthService>(context, listen: false);
    final chatService = ChatService();

    try {
      final chatId = await chatService.getOrCreateChat(
        authService.currentUser!.uid,
        widget.nannyId,
        authService.currentUserModel!.fullName,
        _nannyUser!.fullName,
        authService.currentUserModel!.photoUrl,
        _nannyUser!.photoUrl,
      );

      Navigator.pushNamed(
        context,
        Routes.chat,
        arguments: {
          'receiverId': widget.nannyId,
          'receiverName': _nannyUser!.fullName,
        },
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al abrir chat: $e')),
      );
    }
  }

  void _showBookingDialog() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => _BookingForm(
        nanny: _nanny!,
        nannyUser: _nannyUser!,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: Text('Perfil')),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_nanny == null || _nannyUser == null) {
      return Scaffold(
        appBar: AppBar(title: Text('Perfil')),
        body: Center(child: Text('No se pudo cargar el perfil')),
      );
    }

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 200,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(_nannyUser!.fullName),
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Theme.of(context).colorScheme.primary,
                      Theme.of(context).colorScheme.secondary,
                    ],
                  ),
                ),
                child: Center(
                  child: CircleAvatar(
                    radius: 50,
                    backgroundColor: Colors.white,
                    child: _nanny!.photoUrl != null
                        ? ClipOval(
                            child: Image.network(
                              _nanny!.photoUrl!,
                              width: 100,
                              height: 100,
                              fit: BoxFit.cover,
                            ),
                          )
                        : Icon(Icons.person, size: 50),
                  ),
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Card(
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              _StatItem(
                                icon: Icons.star,
                                value: _nanny!.rating.toStringAsFixed(1),
                                label: 'Rating',
                                color: Colors.amber,
                              ),
                              _StatItem(
                                icon: Icons.work,
                                value: '${_nanny!.yearsOfExperience}',
                                label: 'AÃ±os exp.',
                                color: Colors.blue,
                              ),
                              _StatItem(
                                icon: Icons.rate_review,
                                value: '${_nanny!.totalReviews}',
                                label: 'ReseÃ±as',
                                color: Colors.green,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 16),
                  Card(
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Tarifa',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            '\$${_nanny!.hourlyRate.toStringAsFixed(2)} por hora',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 16),
                  Card(
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Sobre mÃ­',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(_nanny!.bio.isNotEmpty
                              ? _nanny!.bio
                              : 'Sin descripciÃ³n'),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 16),
                  if (_nanny!.certifications.isNotEmpty)
                    Card(
                      child: Padding(
                        padding: EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Certificaciones',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 8),
                            ..._nanny!.certifications.map((cert) => Padding(
                                  padding: EdgeInsets.symmetric(vertical: 4),
                                  child: Row(
                                    children: [
                                      Icon(Icons.check_circle,
                                          color: Colors.green, size: 20),
                                      SizedBox(width: 8),
                                      Text(cert),
                                    ],
                                  ),
                                )),
                          ],
                        ),
                      ),
                    ),
                  SizedBox(height: 16),
                  Card(
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Idiomas',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 8),
                          Wrap(
                            spacing: 8,
                            children: _nanny!.languages
                                .map((lang) => Chip(label: Text(lang)))
                                .toList(),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 16),
                  Text(
                    'ReseÃ±as',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8),
                  _ReviewsList(nannyId: widget.nannyId),
                  SizedBox(height: 80),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomSheet: Container(
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 4,
              offset: Offset(0, -2),
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: _sendMessage,
                icon: Icon(Icons.chat),
                label: Text('Mensaje'),
              ),
            ),
            SizedBox(width: 8),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: _showBookingDialog,
                icon: Icon(Icons.calendar_today),
                label: Text('Contratar'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final Color color;

  const _StatItem({
    required this.icon,
    required this.value,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: color, size: 32),
        SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: TextStyle(color: Colors.grey),
        ),
      ],
    );
  }
}

class _ReviewsList extends StatelessWidget {
  final String nannyId;

  const _ReviewsList({required this.nannyId});

  @override
  Widget build(BuildContext context) {
    final firestoreService = Provider.of<FirestoreService>(context);

    return StreamBuilder<List<ReviewModel>>(
      stream: firestoreService.getReviewsForNanny(nannyId),
      builder: (context, snapshot) {
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Card(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Text('No hay reseÃ±as aÃºn'),
            ),
          );
        }

        return Column(
          children: snapshot.data!.take(3).map((review) {
            return Card(
              margin: EdgeInsets.only(bottom: 8),
              child: Padding(
                padding: EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        ...List.generate(
                          5,
                          (index) => Icon(
                            index < review.rating
                                ? Icons.star
                                : Icons.star_border,
                            color: Colors.amber,
                            size: 18,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 8),
                    Text(review.comment),
                  ],
                ),
              ),
            );
          }).toList(),
        );
      },
    );
  }
}

class _BookingForm extends StatefulWidget {
  final NannyModel nanny;
  final UserModel nannyUser;

  const _BookingForm({required this.nanny, required this.nannyUser});

  @override
  State<_BookingForm> createState() => _BookingFormState();
}

class _BookingFormState extends State<_BookingForm> {
  final _formKey = GlobalKey<FormState>();
  DateTime _selectedDate = DateTime.now();
  TimeOfDay _startTime = TimeOfDay.now();
  TimeOfDay _endTime = TimeOfDay(hour: TimeOfDay.now().hour + 2, minute: 0);
  final _addressController = TextEditingController();
  final _instructionsController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);
    final firestoreService = Provider.of<FirestoreService>(context, listen: false);

    int hours = _endTime.hour - _startTime.hour;
    double total = hours * widget.nanny.hourlyRate;

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 16,
        right: 16,
        top: 16,
      ),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Solicitar servicio',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 16),
              ListTile(
                title: Text('Fecha'),
                subtitle: Text('${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}'),
                trailing: Icon(Icons.calendar_today),
                onTap: () async {
                  final date = await showDatePicker(
                    context: context,
                    initialDate: _selectedDate,
                    firstDate: DateTime.now(),
                    lastDate: DateTime.now().add(Duration(days: 365)),
                  );
                  if (date != null) {
                    setState(() {
                      _selectedDate = date;
                    });
                  }
                },
              ),
              ListTile(
                title: Text('Hora de inicio'),
                subtitle: Text(_startTime.format(context)),
                trailing: Icon(Icons.access_time),
                onTap: () async {
                  final time = await showTimePicker(
                    context: context,
                    initialTime: _startTime,
                  );
                  if (time != null) {
                    setState(() {
                      _startTime = time;
                    });
                  }
                },
              ),
              ListTile(
                title: Text('Hora de fin'),
                subtitle: Text(_endTime.format(context)),
                trailing: Icon(Icons.access_time),
                onTap: () async {
                  final time = await showTimePicker(
                    context: context,
                    initialTime: _endTime,
                  );
                  if (time != null) {
                    setState(() {
                      _endTime = time;
                    });
                  }
                },
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: _addressController,
                decoration: InputDecoration(
                  labelText: 'DirecciÃ³n',
                  prefixIcon: Icon(Icons.location_on),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor ingresa la direcciÃ³n';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: _instructionsController,
                maxLines: 3,
                decoration: InputDecoration(
                  labelText: 'Instrucciones especiales (opcional)',
                  hintText: 'Alergias, rutinas, etc.',
                ),
              ),
              SizedBox(height: 16),
              Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Resumen'),
                    SizedBox(height: 8),
                    Text('Horas: $hours'),
                    Text('Tarifa: \$${widget.nanny.hourlyRate}/hora'),
                    Divider(),
                    Text(
                      'Total: \$${total.toStringAsFixed(2)}',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () async {
                    if (!_formKey.currentState!.validate()) return;

                    try {
                      BookingModel booking = BookingModel(
                        id: '',
                        parentId: authService.currentUser!.uid,
                        nannyId: widget.nanny.userId,
                        startDate: _selectedDate,
                        endDate: _selectedDate,
                        startTime: _startTime.format(context),
                        endTime: _endTime.format(context),
                        numberOfHours: hours,
                        hourlyRate: widget.nanny.hourlyRate,
                        totalAmount: total,
                        address: _addressController.text,
                        specialInstructions: _instructionsController.text,
                        createdAt: DateTime.now(),
                      );

                      await firestoreService.createBooking(booking);

                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Solicitud enviada exitosamente'),
                          backgroundColor: Colors.green,
                        ),
                      );
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Error: $e')),
                      );
                    }
                  },
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 12),
                    child: Text('Enviar solicitud', style: TextStyle(fontSize: 16)),
                  ),
                ),
              ),
              SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}

