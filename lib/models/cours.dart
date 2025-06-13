class Cours {
  final String id;
  final String nom;
  final String code;
  final String professeur;
  final String salle;
  final DateTime heureDebut;
  final DateTime heureFin;
  final String jour;
  final String? description;

  Cours({
    required this.id,
    required this.nom,
    required this.code,
    required this.professeur,
    required this.salle,
    required this.heureDebut,
    required this.heureFin,
    required this.jour,
    this.description,
  });

  factory Cours.fromJson(Map<String, dynamic> json) {
    return Cours(
      id: json['id'] ?? '',
      nom: json['nom'] ?? '',
      code: json['code'] ?? '',
      professeur: json['professeur'] ?? '',
      salle: json['salle'] ?? '',
      heureDebut: DateTime.parse(json['heureDebut']),
      heureFin: DateTime.parse(json['heureFin']),
      jour: json['jour'] ?? '',
      description: json['description'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nom': nom,
      'code': code,
      'professeur': professeur,
      'salle': salle,
      'heureDebut': heureDebut.toIso8601String(),
      'heureFin': heureFin.toIso8601String(),
      'jour': jour,
      'description': description,
    };
  }

  String get duree {
    final difference = heureFin.difference(heureDebut);
    final hours = difference.inHours;
    final minutes = difference.inMinutes % 60;
    return '${hours}h${minutes > 0 ? '${minutes}min' : ''}';
  }
}