class Pointage {
  final String id;
  final String etudiantId;
  final String coursId;
  final DateTime heureArrivee;
  final DateTime? heureDepart;
  final double? latitude;
  final double? longitude;
  final String statut; // 'present', 'retard', 'absent'

  Pointage({
    required this.id,
    required this.etudiantId,
    required this.coursId,
    required this.heureArrivee,
    this.heureDepart,
    this.latitude,
    this.longitude,
    required this.statut,
  });

  factory Pointage.fromJson(Map<String, dynamic> json) {
    return Pointage(
      id: json['id'] ?? '',
      etudiantId: json['etudiantId'] ?? '',
      coursId: json['coursId'] ?? '',
      heureArrivee: DateTime.parse(json['heureArrivee']),
      heureDepart: json['heureDepart'] != null 
          ? DateTime.parse(json['heureDepart']) 
          : null,
      latitude: json['latitude']?.toDouble(),
      longitude: json['longitude']?.toDouble(),
      statut: json['statut'] ?? 'absent',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'etudiantId': etudiantId,
      'coursId': coursId,
      'heureArrivee': heureArrivee.toIso8601String(),
      'heureDepart': heureDepart?.toIso8601String(),
      'latitude': latitude,
      'longitude': longitude,
      'statut': statut,
    };
  }

  bool get estPresent => statut == 'present';
  bool get estEnRetard => statut == 'retard';
  bool get estAbsent => statut == 'absent';
}