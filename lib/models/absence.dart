class Absence {
  final String id;
  final String etudiantId;
  final String coursId;
  final DateTime date;
  final String type; // 'absence', 'retard'
  final String? motif;
  final bool justifiee;
  final String? pieceJustificative;
  final DateTime? dateCreation;

  Absence({
    required this.id,
    required this.etudiantId,
    required this.coursId,
    required this.date,
    required this.type,
    this.motif,
    required this.justifiee,
    this.pieceJustificative,
    this.dateCreation,
  });

  factory Absence.fromJson(Map<String, dynamic> json) {
    return Absence(
      id: json['id'] ?? '',
      etudiantId: json['etudiantId'] ?? '',
      coursId: json['coursId'] ?? '',
      date: DateTime.parse(json['date']),
      type: json['type'] ?? 'absence',
      motif: json['motif'],
      justifiee: json['justifiee'] ?? false,
      pieceJustificative: json['pieceJustificative'],
      dateCreation: json['dateCreation'] != null 
          ? DateTime.parse(json['dateCreation']) 
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'etudiantId': etudiantId,
      'coursId': coursId,
      'date': date.toIso8601String(),
      'type': type,
      'motif': motif,
      'justifiee': justifiee,
      'pieceJustificative': pieceJustificative,
      'dateCreation': dateCreation?.toIso8601String(),
    };
  }

  bool get estRetard => type == 'retard';
  bool get estAbsence => type == 'absence';
}