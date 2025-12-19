import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:napphy_services/config/routes.dart';
import 'package:napphy_services/services/firestore_service.dart';
import 'package:napphy_services/models/nanny_model.dart';

class SearchNanniesScreen extends StatefulWidget {
  const SearchNanniesScreen({super.key});

  @override
  State<SearchNanniesScreen> createState() => _SearchNanniesScreenState();
}

class _SearchNanniesScreenState extends State<SearchNanniesScreen> {
  double _maxHourlyRate = 100.0;
  double _minRating = 0.0;
  bool _showFilters = false;
  String? selectedService;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;

    selectedService = args?['service'];
  }

  @override
  Widget build(BuildContext context) {
    final firestoreService = Provider.of<FirestoreService>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Buscar Niñeras'),
        actions: [
          IconButton(
            icon:
                Icon(_showFilters ? Icons.filter_list_off : Icons.filter_list),
            onPressed: () {
              setState(() {
                _showFilters = !_showFilters;
              });
            },
          ),
        ],
      ),
      body: Column(
        children: [
          if (_showFilters)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                border: Border(
                  bottom: BorderSide(color: Colors.grey[300]!),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Filtros',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text('Tarifa máxima por hora: \$${_maxHourlyRate.toInt()}'),
                  Slider(
                    value: _maxHourlyRate,
                    min: 0,
                    max: 200,
                    divisions: 20,
                    label: '\$${_maxHourlyRate.toInt()}',
                    onChanged: (value) {
                      setState(() {
                        _maxHourlyRate = value;
                      });
                    },
                  ),
                  const SizedBox(height: 8),
                  Text('Calificación mínima: ${_minRating.toStringAsFixed(1)}'),
                  Slider(
                    value: _minRating,
                    min: 0,
                    max: 5,
                    divisions: 10,
                    label: _minRating.toStringAsFixed(1),
                    onChanged: (value) {
                      setState(() {
                        _minRating = value;
                      });
                    },
                  ),
                ],
              ),
            ),
          Expanded(
            child: StreamBuilder<List<NannyModel>>(
              stream: selectedService == null
                  ? firestoreService.getNanniesStream(
                      isApproved: true,
                      isAvailable: true,
                    )
                  : firestoreService.getNanniesByService(
                      service: selectedService!,
                      isApproved: true,
                      isAvailable: true,
                    ),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }

                List<NannyModel> nannies = snapshot.data ?? [];

                // filtros locales
                nannies = nannies.where((nanny) {
                  return nanny.hourlyRate <= _maxHourlyRate &&
                      nanny.rating >= _minRating;
                }).toList();

                if (nannies.isEmpty) {
                  return const Center(
                    child: Text('No se encontraron niñeras'),
                  );
                }

                return ListView.builder(
                  itemCount: nannies.length,
                  itemBuilder: (context, index) {
                    return _NannyCard(nanny: nannies[index]);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _NannyCard extends StatelessWidget {
  final NannyModel nanny;

  const _NannyCard({required this.nanny});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        onTap: () {
          Navigator.pushNamed(
            context,
            Routes.nannyDetail,
            arguments: {'nannyId': nanny.id},
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              CircleAvatar(
                radius: 35,
                backgroundColor: Theme.of(context).colorScheme.primary,
                child: nanny.photoUrl != null
                    ? ClipOval(
                        child: Image.network(
                          nanny.photoUrl!,
                          width: 70,
                          height: 70,
                          fit: BoxFit.cover,
                        ),
                      )
                    : const Icon(Icons.person, size: 35, color: Colors.white),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            nanny.name,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        if (nanny.isAvailable)
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.green.shade50,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Text(
                              'Disponible',
                              style: TextStyle(
                                color: Colors.green,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.star, color: Colors.amber, size: 18),
                        const SizedBox(width: 4),
                        Text(
                          '${nanny.rating.toStringAsFixed(1)} (${nanny.totalReviews})',
                          style: const TextStyle(fontWeight: FontWeight.w500),
                        ),
                        const SizedBox(width: 16),
                        const Icon(Icons.work, size: 18, color: Colors.grey),
                        const SizedBox(width: 4),
                        Text('${nanny.yearsOfExperience} años'),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.location_on,
                            size: 18, color: Colors.grey),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            nanny.address,
                            style: TextStyle(color: Colors.grey[600]),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '\$${nanny.hourlyRate.toStringAsFixed(2)}/hora',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.pushNamed(
                              context,
                              Routes.nannyDetail,
                              arguments: {'nannyId': nanny.id},
                            );
                          },
                          child: const Text('Ver perfil'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
