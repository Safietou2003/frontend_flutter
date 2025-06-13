class Etudiant {
  final String id;
  final String nom;
  final String prenom;
  final String email;
  final String numeroEtudiant;
  final String classe;
  final String? photoUrl;

  Etudiant({
    required this.id,
    required this.nom,
    required this.prenom,
    required this.email,
    required this.numeroEtudiant,
    required this.classe,
    this.photoUrl,
  });

  factory Etudiant.fromJson(Map<String, dynamic> json) {
    return Etudiant(
      id: json['id'] ?? '',
      nom: json['nom'] ?? '',
      prenom: json['prenom'] ?? '',
      email: json['email'] ?? '',
      numeroEtudiant: json['numeroEtudiant'] ?? '',
      classe: json['classe'] ?? '',
      photoUrl: json['photoUrl'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nom': nom,
      'prenom': prenom,
      'email': email,
      'numeroEtudiant': numeroEtudiant,
      'classe': classe,
      'photoUrl': photoUrl,
    };
  }

  String get nomComplet => '$prenom $nom';
}