import 'package:flutter/material.dart';

class AgendaPage extends StatefulWidget {
  const AgendaPage({super.key, required this.title});
  final String title;
  @override
  State<AgendaPage> createState() => _AgendaPageState();
}

class _AgendaPageState extends State<AgendaPage> {
  DateTime _jourselectionner = DateTime.now();

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final seances = state.seancesDujour( _jourselectionner);
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F7),
      appBar: AppBar(
        title: Column(crossAxisAlignment: CrossAxisAlignment.start,
            children: [
            const Text('Mon agenda'),
          Text(
            DateFormat('EEEE d MMMM yyyy', 'fr_FR').format( _jourselectionner),
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w400, color: Color(0xFF8E8E93)),
      ),
      ],
    ),
        actions: [
          IconButton(
            icon: const Icon(Icons.today_rounded),
            onPressed: () => setState(() => _jourselectionner = DateTime.now()),
          ),
        ],
      ),
        body: Column(
          children: [
          _BandeauJours(
          jourSelectionne: _jourselectionner,
          onJourChanged: (j) => setState(() => _jourselectionner = j),
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

  }

