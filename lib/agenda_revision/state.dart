import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import '../models/Models.dart';
import '../services/notificationService.dart';

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
    notifyListeners();
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
    if (!m.notificationActive) {
      for (final s in seances.where((s) => s.matiereId == matiereId)) {
        NotificationService.cancel(s.id.hashCode);
      }
    }
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
    final id = _uuid.v4();
    final seance = Seance(id: id, matiereId: matiereId, dateDebut: debut, dateFin: fin, notes: notes);
    seances.add(seance);
    _planifierNotification(id, matiereId, debut, notes);
    _sauvegarder();
    notifyListeners();
  }

  void modifierSeance(String id, String matiereId, DateTime debut, DateTime fin, String? notes) {
    final index = seances.indexWhere((s) => s.id == id);
    if (index == -1) return;

    // Annuler l'ancienne notification
    NotificationService.cancel(id.hashCode);

    // Mettre à jour la séance
    seances[index] = Seance(
      id: id,
      matiereId: matiereId,
      dateDebut: debut,
      dateFin: fin,
      notes: notes,
      terminee: seances[index].terminee,
    );

    // Replanifier la notification avec les nouvelles infos
    _planifierNotification(id, matiereId, debut, notes);

    _sauvegarder();
    notifyListeners();
  }

  void _planifierNotification(String seanceId, String matiereId, DateTime debut, String? notes) {
    final matiere = matiereById(matiereId);
    if (matiere != null && matiere.notificationActive) {
      final rappel = debut.subtract(Duration(minutes: matiere.rappelMinutes));
      if (rappel.isAfter(DateTime.now())) {
        NotificationService.scheduleNotification(
          id: seanceId.hashCode,
          title: "Cours : ${matiere.nom}",
          body: notes ?? "Ta séance commence bientôt",
          dateTime: rappel,
        );
      }
    }
  }

  void supprimerSeance(String id) {
    NotificationService.cancel(id.hashCode);
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