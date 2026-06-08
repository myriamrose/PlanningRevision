import 'dart:ui';

class Matiere {
  final String id;
  final String nom;
  final Color couleur;
  bool notificationActive;
  int rappelMinutes; // minutes avant le cours

  Matiere({
    required this.id,
    required this.nom,
    required this.couleur,
    this.notificationActive = true,
    this.rappelMinutes = 30,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'nom': nom,
    'couleur': couleur.value,
    'notificationActive': notificationActive,
    'rappelMinutes': rappelMinutes,
  };

  factory Matiere.fromJson(Map<String, dynamic> json) => Matiere(
    id: json['id'],
    nom: json['nom'],
    couleur: Color(json['couleur']),
    notificationActive: json['notificationActive'] ?? true,
    rappelMinutes: json['rappelMinutes'] ?? 30,
  );
}

class Seance {
  final String id;
  final String matiereId;
  final DateTime dateDebut;
  final DateTime dateFin;
  final String? notes;
  bool terminee;

  Seance({
    required this.id,
    required this.matiereId,
    required this.dateDebut,
    required this.dateFin,
    this.notes,
    this.terminee = false,
  });

  Duration get duree => dateFin.difference(dateDebut);

  double get heures => duree.inMinutes / 60.0;

  Map<String, dynamic> toJson() => {
    'id': id,
    'matiereId': matiereId,
    'dateDebut': dateDebut.toIso8601String(),
    'dateFin': dateFin.toIso8601String(),
    'notes': notes,
    'terminee': terminee,
  };

  factory Seance.fromJson(Map<String, dynamic> json) => Seance(
    id: json['id'],
    matiereId: json['matiereId'],
    dateDebut: DateTime.parse(json['dateDebut']),
    dateFin: DateTime.parse(json['dateFin']),
    notes: json['notes'],
    terminee: json['terminee'] ?? false,
  );
}
