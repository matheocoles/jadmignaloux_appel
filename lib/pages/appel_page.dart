import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../services/database_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AppelPage extends StatefulWidget {
  final int coursId;
  final String coursNom;

  const AppelPage({super.key, required this.coursId, required this.coursNom});

  @override
  State<AppelPage> createState() => _AppelPageState();
}

class _AppelPageState extends State<AppelPage> {
  final db = DatabaseService();
  final supabase = Supabase.instance.client;
  List<Map<String, dynamic>> eleves = [];
  Map<int, String> statutEleves = {}; // clé : eleve_cours_id
  bool loading = true;

  @override
  void initState() {
    super.initState();
    loadEleves();
  }

  Future<int> getHeuresManquees(int eleveId) async {
    final response = await supabase
        .from('presences')
        .select('statut')
        .eq('eleve_id', eleveId)
        .eq('statut', 'Absent');

    final absences = List<Map<String, dynamic>>.from(response);
    return absences.length;
  }

  Future<void> loadEleves() async {
    final data = await db.getElevesByCours(widget.coursId);

    final now = DateTime.now();
    final todayStart = DateTime(now.year, now.month, now.day, 0, 0, 0).toIso8601String();
    final todayEnd = DateTime(now.year, now.month, now.day, 23, 59, 59).toIso8601String();

    final presences = await supabase
        .from('presences')
        .select('eleve_cours_id, statut')
        .eq('cours_id', widget.coursId)
        .gte('date', todayStart)
        .lte('date', todayEnd);

    final Map<int, String> statutsDuJour = {
      for (var p in presences) p['eleve_cours_id']: p['statut']
    };

    setState(() {
      eleves = data;
      for (var e in eleves) {
        final id = e['eleve_cours_id'];
        statutEleves[id] = statutsDuJour[id] ?? "Présent";
      }
      loading = false;
    });
  }


  Map<String, int> compterStatuts() {
    int present = 0;
    int absent = 0;

    for (var statut in statutEleves.values) {
      if (statut == "Présent") present++;
      if (statut == "Absent") absent++;
    }

    return {
      'nombre_present': present,
      'nombre_absent': absent,
    };
  }

  void resetAppel() {
    setState(() {
      for (var id in statutEleves.keys) {
        statutEleves[id] = "Présent";
      }
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Tous les statuts ont été réinitialisés à 'Présent'")),
    );
  }


  Future<void> savePresence() async {
    final now = DateTime.now();
    final todayStart = DateTime(now.year, now.month, now.day, 0, 0, 0).toIso8601String();
    final todayEnd = DateTime(now.year, now.month, now.day, 23, 59, 59).toIso8601String();

    for (var e in eleves) {
      final statut = statutEleves[e['eleve_cours_id']]!;
      final eleveCoursId = e['eleve_cours_id'];

      // Vérifie s'il existe déjà une présence pour cet élève aujourd'hui
      final existing = await supabase
          .from('presences')
          .select('id')
          .eq('eleve_cours_id', eleveCoursId)
          .eq('cours_id', widget.coursId)
          .gte('date', todayStart)
          .lte('date', todayEnd)
          .maybeSingle();

      if (existing != null && existing['id'] != null) {
        // Mise à jour
        await supabase.from('presences').update({
          'statut': statut,
          'date': now.toIso8601String(),
        }).eq('id', existing['id']);
      } else {
        // Insertion
        await supabase.from('presences').insert({
          'eleve_cours_id': eleveCoursId,
          'eleve_id': e['id'],
          'statut': statut,
          'date': now.toIso8601String(),
          'cours_id': widget.coursId,
        });
      }
    }

    final stats = compterStatuts();

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("✅ Appel enregistré"),
        content: Text(
          "Présences sauvegardées :\n"
              "👥 Présents : ${stats['nombre_present']}\n"
              "🚫 Absents : ${stats['nombre_absent']}",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Fermer"),
          ),
        ],
      ),
    );

// Une fois la popup fermée, on quitte la page
    Navigator.pop(context, true);

  }


  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(title: Text("Appel : ${widget.coursNom}")),
      body: ListView.builder(
        itemCount: eleves.length,
        itemBuilder: (context, index) {
          final e = eleves[index];
          final eleveCoursId = e['eleve_cours_id'];
          return Card(
            child: ListTile(
              title: Text("${e['prenom']} ${e['nom']}"),
              trailing: DropdownButton<String>(
                value: statutEleves[eleveCoursId],
                items: const [
                  DropdownMenuItem(value: "Présent", child: Text("Présent")),
                  DropdownMenuItem(value: "Absent", child: Text("Absent")),
                  DropdownMenuItem(value: "Retard", child: Text("Retard")),
                ],
                onChanged: (value) {
                  setState(() {
                    statutEleves[eleveCoursId] = value!;
                  });
                },
              ),
              onTap: () async {
                final heuresManquees = await getHeuresManquees(e['id']);
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: Text("${e['prenom']} ${e['nom']}"),
                    content: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "📅 Date de naissance : ${e['date_naissance'] != null ? DateFormat('dd/MM/yyyy').format(DateTime.parse(e['date_naissance'])) : 'N/A'}",
                        ),
                        Text("👨‍👩‍👧 Parent : ${e['parent_prenom'] ?? ''} ${e['parent_nom'] ?? ''}"),
                        Text("📧 Email : ${e['parent_email'] ?? 'N/A'}"),
                        Text("📞 Téléphone : ${e['parent_telephone'] ?? 'N/A'}"),
                        Text("🗓️ Première année : ${e['premiere_annee'] ?? 'N/A'}"),
                        Text("✅ Adhésion valide : ${e['adhesion_valide'] == true ? 'Oui' : 'Non'}"),
                        const SizedBox(height: 8),
                        Text("⏱️ Heures manquées : $heuresManquees h"),
                      ],
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text("Fermer"),
                      ),
                    ],
                  ),
                );
              },
            ),
          );
        },
      ),
      floatingActionButton: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            heroTag: 'reset',
            onPressed: resetAppel,
            backgroundColor: Colors.orange,
            child: const Icon(Icons.refresh),
            tooltip: 'Réinitialiser',
          ),
          const SizedBox(width: 16),
          FloatingActionButton(
            heroTag: 'save',
            onPressed: savePresence,
            child: const Icon(Icons.save),
            tooltip: 'Sauvegarder',
          ),
        ],
      ),

    );
  }
}
