import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:agenda_revision/state.dart';
import 'package:agenda_revision/theme.dart';

class RappelsScreen extends StatelessWidget {
  const RappelsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F7),
      appBar: AppBar(title: const Text('Rappels')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _GroupeSection(
            titre: 'Rappels par matière',
            children: state.matieres.map((m) {
              return _LigneNotif(
                couleur: m.couleur,
                label: m.nom,
                sousTitre: 'Rappel ${m.rappelMinutes} min avant',
                actif: m.notificationActive,
                onToggle: () => state.toggleNotification(m.id),
                onTapDelay: () => _choisirDelai(context, state, m.id, m.rappelMinutes),
              );
            }).toList(),
          ),
          const SizedBox(height: 16),
          _GroupeSection(
            titre: 'Récapitulatif hebdomadaire',
            children: [
              _LigneSimple(
                icone: Icons.calendar_month_rounded,
                iconeCouleur: kPurple,
                label: 'Résumé de semaine',
                sousTitre: 'Chaque dimanche à 19h00',
                actif: state.rappelHebdoActif,
                onToggle: () {
                  state.rappelHebdoActif = !state.rappelHebdoActif;
                  // ignore: invalid_use_of_protected_member
                  state.notifyListeners();
                },
              ),
              _LigneSimple(
                icone: Icons.emoji_events_rounded,
                iconeCouleur: const Color(0xFFEF9F27),
                label: 'Objectif atteint',
                sousTitre: 'Félicitation si objectif dépassé',
                actif: state.rappelObjectifActif,
                onToggle: () {
                  state.rappelObjectifActif = !state.rappelObjectifActif;
                  // ignore: invalid_use_of_protected_member
                  state.notifyListeners();
                },
                dernierElement: true,
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: kPurpleLight,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                const Icon(Icons.info_outline_rounded, color: kPurple, size: 18),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Les notifications doivent être activées dans les réglages de ton téléphone.',
                    style: const TextStyle(fontSize: 12, color: kPurple),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _choisirDelai(BuildContext context, AppState state, String matiereId, int actuel) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) {
        const options = [5, 10, 15, 30, 60, 120];
        return Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Rappel avant le cours', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600)),
              const SizedBox(height: 16),
              ...options.map((min) {
                final label = min < 60 ? '$min minutes' : '${min ~/ 60} heure${min >= 120 ? 's' : ''}';
                return ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(label),
                  trailing: actuel == min ? const Icon(Icons.check, color: kPurple) : null,
                  onTap: () {
                    state.setRappelMinutes(matiereId, min);
                    Navigator.pop(context);
                  },
                );
              }),
            ],
          ),
        );
      },
    );
  }
}

class _GroupeSection extends StatelessWidget {
  final String titre;
  final List<Widget> children;
  const _GroupeSection({required this.titre, required this.children});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text(
            titre.toUpperCase(),
            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFF8E8E93), letterSpacing: 0.5),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0xFFE5E5EA), width: 0.5),
          ),
          child: Column(children: children),
        ),
      ],
    );
  }
}

class _LigneNotif extends StatelessWidget {
  final Color couleur;
  final String label;
  final String sousTitre;
  final bool actif;
  final VoidCallback onToggle;
  final VoidCallback onTapDelay;

  const _LigneNotif({
    required this.couleur,
    required this.label,
    required this.sousTitre,
    required this.actif,
    required this.onToggle,
    required this.onTapDelay,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Color(0xFFE5E5EA), width: 0.5)),
      ),
      child: Row(
        children: [
          Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(color: couleur, shape: BoxShape.circle),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: GestureDetector(
              onTap: actif ? onTapDelay : null,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label, style: const TextStyle(fontSize: 15, color: Color(0xFF1C1C1E))),
                  const SizedBox(height: 2),
                  Text(
                    sousTitre,
                    style: TextStyle(
                      fontSize: 12,
                      color: actif ? const Color(0xFF8E8E93) : const Color(0xFFAEAEB2),
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (actif)
            GestureDetector(
              onTap: onTapDelay,
              child: const Icon(Icons.chevron_right, size: 16, color: Color(0xFFAEAEB2)),
            ),
          const SizedBox(width: 8),
          Switch.adaptive(
            value: actif,
            activeColor: kPurple,
            onChanged: (_) => onToggle(),
          ),
        ],
      ),
    );
  }
}

class _LigneSimple extends StatelessWidget {
  final IconData icone;
  final Color iconeCouleur;
  final String label;
  final String sousTitre;
  final bool actif;
  final VoidCallback onToggle;
  final bool dernierElement;

  const _LigneSimple({
    required this.icone,
    required this.iconeCouleur,
    required this.label,
    required this.sousTitre,
    required this.actif,
    required this.onToggle,
    this.dernierElement = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        border: dernierElement ? null : const Border(bottom: BorderSide(color: Color(0xFFE5E5EA), width: 0.5)),
      ),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: iconeCouleur.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icone, color: iconeCouleur, size: 16),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: const TextStyle(fontSize: 15, color: Color(0xFF1C1C1E))),
                Text(sousTitre, style: const TextStyle(fontSize: 12, color: Color(0xFF8E8E93))),
              ],
            ),
          ),
          Switch.adaptive(
            value: actif,
            activeColor: kPurple,
            onChanged: (_) => onToggle(),
          ),
        ],
      ),
    );
  }
}
