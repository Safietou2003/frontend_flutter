import 'package:flutter/material.dart';
import '../../models/absence.dart';
import '../../models/cours.dart';
import 'detail_absence.dart';

class ListeAbsenceScreen extends StatefulWidget {
  const ListeAbsenceScreen({super.key});

  @override
  State<ListeAbsenceScreen> createState() => _ListeAbsenceScreenState();
}

class _ListeAbsenceScreenState extends State<ListeAbsenceScreen> {
  List<Absence> _absences = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadAbsences();
  }

  void _loadAbsences() {
    // Simulation de chargement des absences
    Future.delayed(const Duration(seconds: 1), () {
      setState(() {
        _absences = [
          Absence(
            id: '1',
            etudiantId: '1',
            coursId: '1',
            date: DateTime.now().subtract(const Duration(days: 2)),
            type: 'absence',
            motif: null,
            justifiee: false,
          ),
          Absence(
            id: '2',
            etudiantId: '1',
            coursId: '2',
            date: DateTime.now().subtract(const Duration(days: 5)),
            type: 'retard',
            motif: 'Transport en retard',
            justifiee: true,
          ),
          Absence(
            id: '3',
            etudiantId: '1',
            coursId: '3',
            date: DateTime.now().subtract(const Duration(days: 7)),
            type: 'absence',
            motif: 'Maladie',
            justifiee: true,
          ),
        ];
        _isLoading = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mes absences'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _absences.isEmpty
              ? const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.event_available,
                        size: 64,
                        color: Colors.grey,
                      ),
                      SizedBox(height: 16),
                      Text(
                        'Aucune absence enregistrée',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _absences.length,
                  itemBuilder: (context, index) {
                    final absence = _absences[index];
                    return _buildAbsenceCard(absence);
                  },
                ),
    );
  }

  Widget _buildAbsenceCard(Absence absence) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => DetailAbsenceScreen(absence: absence),
              ),
            );
          },
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: _getStatusColor(absence).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    _getStatusIcon(absence),
                    color: _getStatusColor(absence),
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _getCoursName(absence.coursId),
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _formatDate(absence.date),
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: absence.estRetard ? Colors.orange : Colors.red,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              absence.estRetard ? 'Retard' : 'Absence',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          if (absence.justifiee)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.green,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: const Text(
                                'Justifiée',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
                const Icon(
                  Icons.chevron_right,
                  color: Colors.grey,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Color _getStatusColor(Absence absence) {
    if (absence.justifiee) {
      return Colors.green;
    } else if (absence.estRetard) {
      return Colors.orange;
    } else {
      return Colors.red;
    }
  }

  IconData _getStatusIcon(Absence absence) {
    if (absence.justifiee) {
      return Icons.check_circle;
    } else if (absence.estRetard) {
      return Icons.access_time;
    } else {
      return Icons.cancel;
    }
  }

  String _getCoursName(String coursId) {
    // Simulation de récupération du nom du cours
    switch (coursId) {
      case '1':
        return 'Mathématiques';
      case '2':
        return 'Informatique';
      case '3':
        return 'Physique';
      default:
        return 'Cours inconnu';
    }
  }

  String _formatDate(DateTime date) {
    final months = [
      'janvier', 'février', 'mars', 'avril', 'mai', 'juin',
      'juillet', 'août', 'septembre', 'octobre', 'novembre', 'décembre'
    ];
    
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }
}