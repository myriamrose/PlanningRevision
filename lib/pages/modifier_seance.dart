import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../agenda_revision/theme.dart';
import '../models/Models.dart';
import '../agenda_revision/state.dart';

class ModifierSeanceScreen extends StatefulWidget {
  final Seance seance;
  const ModifierSeanceScreen({super.key, required this.seance});

  @override
  State<ModifierSeanceScreen> createState() => _ModifierSeanceScreenState();
}

class _ModifierSeanceScreenState extends State<ModifierSeanceScreen> {
  Matiere? _matiereSelectionnee;
  late DateTime _dateSelectionnee;
  late TimeOfDay _heureDebut;
  late TimeOfDay _heureFin;
  late TextEditingController _notesController;

  @override
  void initState() {
    super.initState();
    final s = widget.seance;
    _dateSelectionnee = DateTime(s.dateDebut.year, s.dateDebut.month, s.dateDebut.day);
    _heureDebut = TimeOfDay(hour: s.dateDebut.hour, minute: s.dateDebut.minute);
    _heureFin = TimeOfDay(hour: s.dateFin.hour, minute: s.dateFin.minute);
    _notesController = TextEditingController(text: s.notes ?? '');
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Résoudre la matière ici pour avoir accès au context/state
    if (_matiereSelectionnee == null) {
      final state = context.read<AppState>();
      _matiereSelectionnee = state.matiereById(widget.seance.matiereId);
    }
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F7),
      appBar: AppBar(
        title: const Text('Modifier la séance'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _Section(
            titre: 'Matière',
            child: state.matieres.isEmpty
                ? const Text('Aucune matière. Ajoutez-en dans les réglages.')
                : Wrap(
              spacing: 8,
              runSpacing: 8,
              children: state.matieres.map((m) {
                final sel = _matiereSelectionnee?.id == m.id;
                return GestureDetector(
                  onTap: () => setState(() => _matiereSelectionnee = m),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: sel ? m.couleur : m.couleur.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: sel ? Colors.white70 : m.couleur,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          m.nom,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: sel ? Colors.white : m.couleur,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 12),
          _Section(
            titre: 'Date',
            child: GestureDetector(
              onTap: () => _choisirDate(context),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                decoration: BoxDecoration(
                  color: const Color(0xFFF5F5F7),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.calendar_today_rounded, size: 18, color: Color(0xFF8E8E93)),
                    const SizedBox(width: 10),
                    Text(
                      DateFormat('EEEE d MMMM yyyy', 'fr_FR').format(_dateSelectionnee),
                      style: const TextStyle(fontSize: 14, color: Color(0xFF1C1C1E)),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          _Section(
            titre: 'Horaire',
            child: Row(
              children: [
                Expanded(
                  child: _PickerHeure(
                    label: 'Début',
                    heure: _heureDebut,
                    onChanged: (h) => setState(() => _heureDebut = h),
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 12),
                  child: Text('→', style: TextStyle(color: Color(0xFF8E8E93), fontSize: 18)),
                ),
                Expanded(
                  child: _PickerHeure(
                    label: 'Fin',
                    heure: _heureFin,
                    onChanged: (h) => setState(() => _heureFin = h),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          _Section(
            titre: 'Notes (optionnel)',
            child: TextField(
              controller: _notesController,
              maxLines: 3,
              decoration: const InputDecoration(
                hintText: 'Chapitre, exercices, objectifs...',
                hintStyle: TextStyle(fontSize: 13),
              ),
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: _matiereSelectionnee == null ? null : _valider,
            child: const Text('Enregistrer les modifications'),
          ),
        ],
      ),
    );
  }

  Future<void> _choisirDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _dateSelectionnee,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      locale: const Locale('fr'),
    );
    if (picked != null) setState(() => _dateSelectionnee = picked);
  }

  void _valider() {
    final debut = DateTime(
      _dateSelectionnee.year, _dateSelectionnee.month, _dateSelectionnee.day,
      _heureDebut.hour, _heureDebut.minute,
    );
    final fin = DateTime(
      _dateSelectionnee.year, _dateSelectionnee.month, _dateSelectionnee.day,
      _heureFin.hour, _heureFin.minute,
    );
    if (fin.isBefore(debut)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('L\'heure de fin doit être après l\'heure de début')),
      );
      return;
    }
    context.read<AppState>().modifierSeance(
      widget.seance.id,
      _matiereSelectionnee!.id,
      debut,
      fin,
      _notesController.text.isNotEmpty ? _notesController.text : null,
    );
    Navigator.pop(context);
  }
}

// ── Widgets locaux (identiques à AjouterSeanceScreen) ──────────────────────

class _Section extends StatelessWidget {
  final String titre;
  final Widget child;
  const _Section({required this.titre, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE5E5EA), width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(titre,
              style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF8E8E93),
                  letterSpacing: 0.5)),
          const SizedBox(height: 10),
          child,
        ],
      ),
    );
  }
}

class _PickerHeure extends StatelessWidget {
  final String label;
  final TimeOfDay heure;
  final ValueChanged<TimeOfDay> onChanged;

  const _PickerHeure(
      {required this.label, required this.heure, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        final picked = await showTimePicker(
          context: context,
          initialTime: heure,
          builder: (context, child) => Localizations.override(
            context: context,
            locale: const Locale('fr'),
            child: child,
          ),
        );
        if (picked != null) onChanged(picked);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: const Color(0xFFF5F5F7),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label,
                style:
                const TextStyle(fontSize: 10, color: Color(0xFF8E8E93))),
            const SizedBox(height: 2),
            Text(
              '${heure.hour.toString().padLeft(2, '0')}:${heure.minute.toString().padLeft(2, '0')}',
              style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1C1C1E)),
            ),
          ],
        ),
      ),
    );
  }
}