import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import 'package:agenda_revision/models.dart';

const _uuid = Uuid();

class AppState extends ChangeNotifier {
  List<Matiere> matieres = [];
  List<Seance> seances = [];
  double objectifHeuresHebdo = 15.0;
  bool rappelHebdoActif = true;
  bool rappelObjectifActif = true;

  AppState() {
    _init();
  }

  Future<void> _init() async {
    await _charger();
    if (matieres.isEmpty) _ajouterDemoData();
    notifyListeners();
  }

  void _ajouterDemoData() {
    matieres = [
      Matiere(id: _uuid.v4(), nom: 'Mathématiques', couleur: const Color(0xFF534AB7), rappelMinutes: 30),
      Matiere(id: _uuid.v4(), nom: 'Physique', couleur: const Color(0xFF1D9E75), rappelMinutes: 60),
      Matiere(id: _uuid.v4(), nom: 'Anglais', couleur: const Color(0xFFEF9F27), rappelMinutes: 15),
      Matiere(id: _uuid.v4(), nom: 'Histoire', couleur: const Color(0xFFD4537E), notificationActive: false, rappelMinutes: 30),
    ];
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    seances = [
      Seance(id: _uuid.v4(), matiereId: matieres[0].id, dateDebut: today.add(const Duration(hours: 14)), dateFin: today.add(const Duration(hours: 16)), notes: 'Chapitre 4 – Matrices'),
      Seance(id: _uuid.v4(), matiereId: matieres[1].id, dateDebut: today.add(const Duration(hours: 17)), dateFin: today.add(const Duration(hours: 18, minutes: 30)), notes: 'TD – Cinétique'),
      Seance(id: _uuid.v4(), matiereId: matieres[2].id, dateDebut: today.add(const Duration(hours: 20)), dateFin: today.add(const Duration(hours: 21)), notes: 'Expression écrite'),
      Seance(id: _uuid.v4(), matiereId: matieres[0].id, dateDebut: today.subtract(const Duration(days: 2, hours: -9)), dateFin: today.subtract(const Duration(days: 2, hours: -11)), notes: 'Révision chapitre 3', terminee: true),
      Seance(id: _uuid.v4(), matiereId: matieres[1].id, dateDebut: today.subtract(const Duration(days: 1, hours: -10)), dateFin: today.subtract(const Duration(days: 1, hours: -11, minutes: -30)), terminee: true),
      Seance(id: _uuid.v4(), matiereId: matieres[3].id, dateDebut: today.subtract(const Duration(days: 3, hours: -14)), dateFin: today.subtract(const Duration(days: 3, hours: -16)), terminee: true),
    ];
    _sauvegarder();
  }

  // --- Matieres ---
  void ajouterMatiere(String nom, Color couleur) {
    matieres.add(Matiere(id: _uuid.v4(), nom: nom, couleur: couleur));
    _sauvegarder();
    notifyListeners();
  }

  void supprimerMatiere(String id) {
    matieres.removeWhere((m) => m.id == id);
    seances.removeWhere((s) => s.matiereId == id);
    _sauvegarder();
    notifyListeners();
  }

  void toggleNotification(String matiereId) {
    final m = matieres.firstWhere((m) => m.id == matiereId);
    m.notificationActive = !m.notificationActive;
    _sauvegarder();
    notifyListeners();
  }

  void setRappelMinutes(String matiereId, int minutes) {
    final m = matieres.firstWhere((m) => m.id == matiereId);
    m.rappelMinutes = minutes;
    _sauvegarder();
    notifyListeners();
  }

  // --- Seances ---
  void ajouterSeance(String matiereId, DateTime debut, DateTime fin, String? notes) {
    seances.add(Seance(id: _uuid.v4(), matiereId: matiereId, dateDebut: debut, dateFin: fin, notes: notes));
    _sauvegarder();
    notifyListeners();
  }

  void supprimerSeance(String id) {
    seances.removeWhere((s) => s.id == id);
    _sauvegarder();
    notifyListeners();
  }

  void toggleTerminee(String id) {
    final s = seances.firstWhere((s) => s.id == id);
    s.terminee = !s.terminee;
    _sauvegarder();
    notifyListeners();
  }

  // --- Queries ---
  List<Seance> seancesDuJour(DateTime jour) {
    final d = DateTime(jour.year, jour.month, jour.day);
    return seances
        .where((s) {
      final sd = DateTime(s.dateDebut.year, s.dateDebut.month, s.dateDebut.day);
      return sd == d;
    })
        .toList()
      ..sort((a, b) => a.dateDebut.compareTo(b.dateDebut));
  }

  Matiere? matiereById(String id) {
    try {
      return matieres.firstWhere((m) => m.id == id);
    } catch (_) {
      return null;
    }
  }

  /// Heures totales cette semaine par matiere
  Map<String, double> heuresParMatiereHebdo() {
    final now = DateTime.now();
    final debutSemaine = now.subtract(Duration(days: now.weekday - 1));
    final debut = DateTime(debutSemaine.year, debutSemaine.month, debutSemaine.day);
    final fin = debut.add(const Duration(days: 7));
    final result = <String, double>{};
    for (final s in seances) {
      if (s.dateDebut.isAfter(debut) && s.dateDebut.isBefore(fin)) {
        result[s.matiereId] = (result[s.matiereId] ?? 0) + s.heures;
      }
    }
    return result;
  }

  double totalHeuresHebdo() {
    return heuresParMatiereHebdo().values.fold(0, (a, b) => a + b);
  }

  /// Heures par jour cette semaine (index 0=lundi)
  List<double> heuresParJourHebdo() {
    final now = DateTime.now();
    final debutSemaine = now.subtract(Duration(days: now.weekday - 1));
    final debut = DateTime(debutSemaine.year, debutSemaine.month, debutSemaine.day);
    final result = List<double>.filled(7, 0);
    for (final s in seances) {
      final sd = DateTime(s.dateDebut.year, s.dateDebut.month, s.dateDebut.day);
      final diff = sd.difference(debut).inDays;
      if (diff >= 0 && diff < 7) {
        result[diff] += s.heures;
      }
    }
    return result;
  }

  void setObjectif(double h) {
    objectifHeuresHebdo = h;
    _sauvegarder();
    notifyListeners();
  }

  // --- Persistence ---
  Future<void> _sauvegarder() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString('matieres', jsonEncode(matieres.map((m) => m.toJson()).toList()));
    prefs.setString('seances', jsonEncode(seances.map((s) => s.toJson()).toList()));
    prefs.setDouble('objectif', objectifHeuresHebdo);
    prefs.setBool('rappelHebdo', rappelHebdoActif);
    prefs.setBool('rappelObjectif', rappelObjectifActif);
  }

  Future<void> _charger() async {
    final prefs = await SharedPreferences.getInstance();
    final mJson = prefs.getString('matieres');
    final sJson = prefs.getString('seances');
    if (mJson != null) {
      matieres = (jsonDecode(mJson) as List).map((e) => Matiere.fromJson(e)).toList();
    }
    if (sJson != null) {
      seances = (jsonDecode(sJson) as List).map((e) => Seance.fromJson(e)).toList();
    }
    objectifHeuresHebdo = prefs.getDouble('objectif') ?? 15.0;
    rappelHebdoActif = prefs.getBool('rappelHebdo') ?? true;
    rappelObjectifActif = prefs.getBool('rappelObjectif') ?? true;
  }
}