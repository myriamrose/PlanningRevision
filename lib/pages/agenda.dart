import 'package:flutter/material.dart';

class AgendaPage extends StatefulWidget {
  const AgendaPage({super.key, required this.title});
  final String title;
  @override
  State<AgendaPage> createState() => _AgendaPageState();
}

class _AgendaPageState extends State<AgendaPage> {
  DateTime _jourSelectionne = DateTime.now();

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final seances = state.seancesDuJour(_jourSelectionne);

    return Scaffold(
      backgroundColor:const Color(0xFFF5F5F7),
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Mon agenda'),
            Text(
              DateFormat('EEEE d MMMM yyyy', 'fr_FR').format(_jourSelectionne),
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w400, color: Color(0xFF8E8E93)),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.today_rounded),
            onPressed: () => setState(() => _jourSelectionne = DateTime.now()),
          ),
        ],
      ),
      body: Column(
        children: [
          _BandeauJours(
            jourSelectionne: _jourSelectionne,
            onJourChanged: (j) => setState(() => _jourSelectionne = j),
          ),
          Expanded(
            child: seances.isEmpty
                ? _EmptyState(onAjouter: () => _ouvrirAjout(context))
                : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: seances.length,
              itemBuilder: (ctx, i) => _CarteSeance(
                seance: seances[i],
                matiere: state.matiereById(seances[i].matiereId),
                onToggle: () => state.toggleTerminee(seances[i].id),
                onDelete: () => state.supprimerSeance(seances[i].id),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _ouvrirAjout(context),
        backgroundColor: kPurple,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }


  void _ouvrirAjout(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AjouterSeanceScreen(jourInitial: _jourSelectionne),
      ),
    );
  }
}

class _BandeauJours extends StatelessWidget {
  final DateTime jourSelectionne;
  final ValueChanged<DateTime> onJourChanged;

  const _BandeauJours({required this.jourSelectionne, required this.onJourChanged});

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    // Afficher 7 jours centrés sur aujourd'hui
    final jours = List.generate(7, (i) {
      final debut = now.subtract(Duration(days: now.weekday - 1));
      return DateTime(debut.year, debut.month, debut.day + i);
    });
    const joursLabels = ['L', 'M', 'M', 'J', 'V', 'S', 'D'];

    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
      child: Row(
        children: List.generate(7, (i) {
          final jour = jours[i];
          final estSelectionne = jour.day == jourSelectionne.day &&
              jour.month == jourSelectionne.month &&
              jour.year == jourSelectionne.year;
          final estAujourdHui = jour.day == now.day &&
              jour.month == now.month &&
              jour.year == now.year;
          return Expanded(
            child: GestureDetector(
              onTap: () => onJourChanged(jour),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                margin: const EdgeInsets.symmetric(horizontal: 2),
                padding: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  color: estSelectionne ? kPurple : Colors.transparent,
                  borderRadius: BorderRadius.circular(10),
                  border: estAujourdHui && !estSelectionne
                      ? Border.all(color: kPurple, width: 1)
                      : null,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      joursLabels[i],
                      style: TextStyle(
                        fontSize: 10,
                        color: estSelectionne ? Colors.white70 : const Color(0xFF8E8E93),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${jour.day}',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: estSelectionne ? Colors.white : const Color(0xFF1C1C1E),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}

class _CarteSeance extends StatelessWidget {
  final Seance seance;
  final Matiere? matiere;
  final VoidCallback onToggle;
  final VoidCallback onDelete;

  const _CarteSeance({
    required this.seance,
    required this.matiere,
    required this.onToggle,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final couleur = matiere?.couleur ?? Colors.grey;
    final couleurLight = couleur.withOpacity(0.1);

    return Dismissible(
      key: Key(seance.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: Colors.red.shade50,
          borderRadius: BorderRadius.circular(14),
        ),
        child: const Icon(Icons.delete_outline, color: Colors.red),
      ),
      onDismissed: (_) => onDelete(),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              Container(
                width: 4,
                height: 52,
                decoration: BoxDecoration(
                  color: couleur,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            matiere?.nom ?? 'Matière inconnue',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFF1C1C1E),
                              decoration: seance.terminee ? TextDecoration.lineThrough : null,
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: couleurLight,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            formatDuree(seance.heures),
                            style: TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: couleur),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${formatHeure(seance.dateDebut)} – ${formatHeure(seance.dateFin)}',
                      style: const TextStyle(fontSize: 12, color: Color(0xFF8E8E93)),
                    ),
                    if (seance.notes != null && seance.notes!.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        seance.notes!,
                        style: const TextStyle(fontSize: 12, color: Color(0xFFAEAEB2)),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: onToggle,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: seance.terminee ? couleur : Colors.transparent,
                    border: Border.all(color: seance.terminee ? couleur : const Color(0xFFD1D1D6), width: 1.5),
                  ),
                  child: seance.terminee
                      ? const Icon(Icons.check, size: 14, color: Colors.white)
                      : null,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final VoidCallback onAjouter;
  const _EmptyState({required this.onAjouter});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(color: kPurpleLight, shape: BoxShape.circle),
            child: const Icon(Icons.menu_book_rounded, color: kPurple, size: 30),
          ),
          const SizedBox(height: 16),
          const Text('Aucune séance ce jour', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Color(0xFF1C1C1E))),
          const SizedBox(height: 6),
          const Text('Planifie une séance de révision', style: TextStyle(fontSize: 13, color: Color(0xFF8E8E93))),
          const SizedBox(height: 20),
          TextButton.icon(
            onPressed: onAjouter,
            icon: const Icon(Icons.add, color: kPurple),
            label: const Text('Ajouter une séance', style: TextStyle(color: kPurple)),
          ),
        ],
      ),
    );
  }
}

}

