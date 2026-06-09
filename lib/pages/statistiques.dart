import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../agenda_revision/theme.dart';
import '../agenda_revision/state.dart';

class StatsScreen extends StatelessWidget {
  const StatsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final total = state.totalHeuresHebdo();
    final objectif = state.objectifHeuresHebdo;
    final heuresMatieres = state.heuresParMatiereHebdo();
    final heuresJours = state.heuresParJourHebdo();
    final now = DateTime.now();
    final lundi = now.subtract(Duration(days: now.weekday - 1));
    final dimanche = lundi.add(const Duration(days: 6));

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F7),
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Cette semaine'),
            Text(
              '${DateFormat('d MMM', 'fr_FR').format(lundi)} – ${DateFormat('d MMM yyyy', 'fr_FR').format(dimanche)}',
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w400, color: Color(0xFF8E8E93)),
            ),
          ],
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Stats cards
          Row(
            children: [
              Expanded(child: _StatCard(label: 'Total révisé', value: formatDuree(total), sub: _progressionLabel(total))),
              const SizedBox(width: 12),
              Expanded(
                child: _StatCard(
                  label: 'Objectif',
                  value: '${(total / objectif * 100).clamp(0, 100).round()}%',
                  sub: 'Objectif : ${formatDuree(objectif)}',
                  valueColor: kPurple,
                  child: _MiniProgress(valeur: (total / objectif).clamp(0, 1)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Barre par matière
          _Carte(
            titre: 'Heures par matière',
            child: Column(
              children: state.matieres.map((m) {
                final h = heuresMatieres[m.id] ?? 0;
                final maxH = heuresMatieres.values.fold(0.0, (a, b) => b > a ? b : a);
                return _BarreMatiere(
                  nom: m.nom,
                  heures: h,
                  couleur: m.couleur,
                  ratio: maxH > 0 ? h / maxH : 0,
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 16),

          // Histogramme jours
          _Carte(
            titre: 'Activité par jour',
            child: _Histogramme(heuresJours: heuresJours),
          ),
          const SizedBox(height: 16),

          // Objectif slider
          _Carte(
            titre: 'Objectif hebdomadaire',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('${formatDuree(objectif)} / semaine', style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
                    Text('${objectif.round()}h', style: const TextStyle(fontSize: 13, color: kPurple, fontWeight: FontWeight.w500)),
                  ],
                ),
                const SizedBox(height: 8),
                SliderTheme(
                  data: SliderTheme.of(context).copyWith(
                    activeTrackColor: kPurple,
                    inactiveTrackColor: kPurpleLight,
                    thumbColor: kPurple,
                    overlayColor: kPurple.withOpacity(0.1),
                  ),
                  child: Slider(
                    value: objectif,
                    min: 1,
                    max: 40,
                    divisions: 39,
                    onChanged: (v) => state.setObjectif(v.roundToDouble()),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _progressionLabel(double total) {
    // Comparer à la semaine précédente — pour l'instant valeur fixe
    return total > 0 ? 'Cette semaine' : 'Aucune séance';
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final String sub;
  final Color? valueColor;
  final Widget? child;

  const _StatCard({required this.label, required this.value, required this.sub, this.valueColor, this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F5F7),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontSize: 11, color: Color(0xFF8E8E93))),
          const SizedBox(height: 6),
          Text(value, style: TextStyle(fontSize: 24, fontWeight: FontWeight.w600, color: valueColor ?? const Color(0xFF1C1C1E))),
          const SizedBox(height: 2),
          Text(sub, style: const TextStyle(fontSize: 11, color: Color(0xFFAEAEB2))),
          if (child != null) ...[const SizedBox(height: 8), child!],
        ],
      ),
    );
  }
}

class _MiniProgress extends StatelessWidget {
  final double valeur;
  const _MiniProgress({required this.valeur});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(4),
      child: LinearProgressIndicator(
        value: valeur,
        minHeight: 6,
        backgroundColor: kPurpleLight,
        valueColor: const AlwaysStoppedAnimation<Color>(kPurple),
      ),
    );
  }
}

class _Carte extends StatelessWidget {
  final String titre;
  final Widget child;
  const _Carte({required this.titre, required this.child});

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
          Text(
            titre.toUpperCase(),
            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFF8E8E93), letterSpacing: 0.5),
          ),
          const SizedBox(height: 14),
          child,
        ],
      ),
    );
  }
}

class _BarreMatiere extends StatelessWidget {
  final String nom;
  final double heures;
  final Color couleur;
  final double ratio;

  const _BarreMatiere({required this.nom, required this.heures, required this.couleur, required this.ratio});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(width: 8, height: 8, decoration: BoxDecoration(color: couleur, shape: BoxShape.circle)),
                  const SizedBox(width: 8),
                  Text(nom, style: const TextStyle(fontSize: 13, color: Color(0xFF3C3C43))),
                ],
              ),
              Text(formatDuree(heures), style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: couleur)),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: ratio,
              minHeight: 6,
              backgroundColor: couleur.withOpacity(0.1),
              valueColor: AlwaysStoppedAnimation<Color>(couleur),
            ),
          ),
        ],
      ),
    );
  }
}

class _Histogramme extends StatelessWidget {
  final List<double> heuresJours;
  const _Histogramme({required this.heuresJours});

  @override
  Widget build(BuildContext context) {
    final max = heuresJours.fold(0.0, (a, b) => b > a ? b : a);
    const labels = ['L', 'M', 'M', 'J', 'V', 'S', 'D'];
    final now = DateTime.now();
    final jourIndex = now.weekday - 1;

    return SizedBox(
      height: 100,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: List.generate(7, (i) {
          final h = heuresJours[i];
          final ratio = max > 0 ? h / max : 0.0;
          final estAujourdHui = i == jourIndex;
          return Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 3),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  if (h > 0)
                    Text(
                      formatDuree(h),
                      style: const TextStyle(fontSize: 9, color: Color(0xFF8E8E93)),
                    ),
                  const SizedBox(height: 2),
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 400),
                    height: ratio * 60 + (h > 0 ? 4 : 4),
                    decoration: BoxDecoration(
                      color: estAujourdHui ? kPurple : (h > 0 ? kPurpleLight : const Color(0xFFF5F5F7)),
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(
                        color: h == 0 ? const Color(0xFFE5E5EA) : Colors.transparent,
                        width: 0.5,
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    labels[i],
                    style: TextStyle(
                      fontSize: 11,
                      color: estAujourdHui ? kPurple : const Color(0xFF8E8E93),
                      fontWeight: estAujourdHui ? FontWeight.w600 : FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }
}
