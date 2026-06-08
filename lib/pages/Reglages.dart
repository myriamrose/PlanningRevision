import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:agenda_revision/state.dart';
import 'package:agenda_revision/theme.dart';
import 'package:agenda_revision/models.dart';

class ReglagésScreen extends StatelessWidget {
const ReglagésScreen({super.key});

@override
Widget build(BuildContext context) {
  final state = context.watch<AppState>();

  return Scaffold(
    backgroundColor: const Color(0xFFF5F5F7),
    appBar: AppBar(title: const Text('Réglages')),
    body: ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _SectionTitre('Mes matières'),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0xFFE5E5EA), width: 0.5),
          ),
          child: Column(
            children: [
              ...state.matieres.asMap().entries.map((e) {
                final i = e.key;
                final m = e.value;
                final last = i == state.matieres.length - 1;
                return _LigneMatiere(
                  matiere: m,
                  derniere: last,
                  onDelete: () => _confirmerSuppression(context, state, m),
                );
              }),
              ListTile(
                leading: Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(color: kPurpleLight, borderRadius: BorderRadius.circular(8)),
                  child: const Icon(Icons.add, color: kPurple, size: 18),
                ),
                title: const Text('Ajouter une matière', style: TextStyle(fontSize: 15, color: kPurple)),
                onTap: () => _ajouterMatiere(context, state),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        _SectionTitre('À propos'),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0xFFE5E5EA), width: 0.5),
          ),
          child: Column(
            children: [
              _LigneInfo(label: 'Version', value: '1.0.0'),
              _LigneInfo(label: 'Développé avec', value: 'Flutter', derniere: true),
            ],
          ),
        ),
      ],
    ),
  );
}

void _confirmerSuppression(BuildContext context, AppState state, Matiere m) {
  showDialog(
    context: context,
    builder: (_) => AlertDialog(
      title: const Text('Supprimer la matière'),
      content: Text('Supprimer "${m.nom}" ? Toutes les séances associées seront aussi supprimées.'),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Annuler')),
        TextButton(
          onPressed: () {
            state.supprimerMatiere(m.id);
            Navigator.pop(context);
          },
          child: const Text('Supprimer', style: TextStyle(color: Colors.red)),
        ),
      ],
    ),
  );
}

void _ajouterMatiere(BuildContext context, AppState state) {
  final controller = TextEditingController();
  Color couleurChoisie = kCouleursMatiere[0];

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
    builder: (_) {
      return StatefulBuilder(
        builder: (ctx, setModalState) {
          return Padding(
            padding: EdgeInsets.only(
              left: 20, right: 20, top: 20,
              bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Nouvelle matière', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600)),
                const SizedBox(height: 16),
                TextField(
                  controller: controller,
                  autofocus: true,
                  decoration: const InputDecoration(hintText: 'Nom de la matière'),
                ),
                const SizedBox(height: 16),
                const Text('Couleur', style: TextStyle(fontSize: 13, color: Color(0xFF8E8E93))),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 10,
                  children: kCouleursMatiere.map((c) {
                    return GestureDetector(
                      onTap: () => setModalState(() => couleurChoisie = c),
                      child: Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: c,
                          shape: BoxShape.circle,
                          border: couleurChoisie == c
                              ? Border.all(color: const Color(0xFF1C1C1E), width: 2)
                              : null,
                        ),
                        child: couleurChoisie == c
                            ? const Icon(Icons.check, color: Colors.white, size: 16)
                            : null,
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      if (controller.text.trim().isNotEmpty) {
                        state.ajouterMatiere(controller.text.trim(), couleurChoisie);
                        Navigator.pop(ctx);
                      }
                    },
                    child: const Text('Ajouter'),
                  ),
                ),
              ],
            ),
          );
        },
      );
    },
  );
}
}

class _SectionTitre extends StatelessWidget {
  final String titre;
  const _SectionTitre(this.titre);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8, top: 4),
      child: Text(
        titre.toUpperCase(),
        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFF8E8E93), letterSpacing: 0.5),
      ),
    );
  }
}

class _LigneMatiere extends StatelessWidget {
  final Matiere matiere;
  final bool derniere;
  final VoidCallback onDelete;

  const _LigneMatiere({required this.matiere, required this.derniere, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: derniere ? null : const Border(bottom: BorderSide(color: Color(0xFFE5E5EA), width: 0.5)),
      ),
      child: ListTile(
        leading: Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(color: matiere.couleur, shape: BoxShape.circle),
        ),
        title: Text(matiere.nom, style: const TextStyle(fontSize: 15)),
        trailing: IconButton(
          icon: const Icon(Icons.delete_outline, color: Color(0xFFAEAEB2), size: 20),
          onPressed: onDelete,
        ),
      ),
    );
  }
}

class _LigneInfo extends StatelessWidget {
  final String label;
  final String value;
  final bool derniere;

  const _LigneInfo({required this.label, required this.value, this.derniere = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
      decoration: BoxDecoration(
        border: derniere ? null : const Border(bottom: BorderSide(color: Color(0xFFE5E5EA), width: 0.5)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 15, color: Color(0xFF1C1C1E))),
          Text(value, style: const TextStyle(fontSize: 15, color: Color(0xFF8E8E93))),
        ],
      ),
    );
  }
}