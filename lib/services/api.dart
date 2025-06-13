import 'dart:convert';
import 'package:http/http.dart' as http;
import '../utils/const.dart';
import '../models/etudiant.dart';
import '../models/cours.dart';
import '../models/absence.dart';
import '../models/pointage.dart';

class ApiService {
  static const String baseUrl = Const.baseUrl;

  // Headers par défaut
  static Map<String, String> get _headers => {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };

  // Authentification
  static Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/login'),
        headers: _headers,
        body: jsonEncode({
          'email': email,
          'password': password,
        }),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Erreur de connexion: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Erreur réseau: $e');
    }
  }

  // Récupérer les informations de l'étudiant
  static Future<Etudiant> getEtudiant(String id) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/etudiants/$id'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return Etudiant.fromJson(data);
      } else {
        throw Exception('Erreur lors de la récupération de l\'étudiant');
      }
    } catch (e) {
      throw Exception('Erreur réseau: $e');
    }
  }

  // Récupérer les cours d'un étudiant
  static Future<List<Cours>> getCours(String etudiantId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/etudiants/$etudiantId/cours'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => Cours.fromJson(json)).toList();
      } else {
        throw Exception('Erreur lors de la récupération des cours');
      }
    } catch (e) {
      throw Exception('Erreur réseau: $e');
    }
  }

  // Récupérer les absences d'un étudiant
  static Future<List<Absence>> getAbsences(String etudiantId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/etudiants/$etudiantId/absences'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => Absence.fromJson(json)).toList();
      } else {
        throw Exception('Erreur lors de la récupération des absences');
      }
    } catch (e) {
      throw Exception('Erreur réseau: $e');
    }
  }

  // Enregistrer un pointage
  static Future<Pointage> enregistrerPointage({
    required String etudiantId,
    required String coursId,
    required double latitude,
    required double longitude,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/pointages'),
        headers: _headers,
        body: jsonEncode({
          'etudiantId': etudiantId,
          'coursId': coursId,
          'latitude': latitude,
          'longitude': longitude,
          'heureArrivee': DateTime.now().toIso8601String(),
        }),
      );

      if (response.statusCode == 201) {
        final data = jsonDecode(response.body);
        return Pointage.fromJson(data);
      } else {
        throw Exception('Erreur lors de l\'enregistrement du pointage');
      }
    } catch (e) {
      throw Exception('Erreur réseau: $e');
    }
  }

  // Justifier une absence
  static Future<bool> justifierAbsence(String absenceId, String motif) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/absences/$absenceId/justifier'),
        headers: _headers,
        body: jsonEncode({
          'motif': motif,
          'justifiee': true,
        }),
      );

      return response.statusCode == 200;
    } catch (e) {
      throw Exception('Erreur réseau: $e');
    }
  }
}