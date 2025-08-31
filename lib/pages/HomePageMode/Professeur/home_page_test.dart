import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../services/database_service.dart';
import '../../appel_page.dart';
import 'bloc_note_page.dart';

class HomePageProfTest extends StatefulWidget {
  final String prenom;

  const HomePageProfTest({
    super.key,
    required this.prenom,
  });

  @override
  State<HomePageProfTest> createState() => _HomePageProfTestState();
}

class _HomePageProfTestState extends State<HomePageProfTest> {
  final db = DatabaseService();
  bool loading = true;
  List<Map<String, dynamic>> cours = [];

  @override
  void initState() {
    super.initState();
    loadCours();
  }

  /// Charger uniquement les cours du prof connecté
  Future<void> loadCours() async {
    // ⚡ Simulation d'un jour (vendredi 29 août 2025)
    final fakeDate = DateTime(2025, 8, 28);
    final currentDay =
    DateFormat('EEEE', 'fr_FR').format(fakeDate).toLowerCase();

    print("👉 Jour simulé : $currentDay, Prof : ${widget.prenom}");

    final data =
    await db.getCoursByProfesseurAndJour(widget.prenom, currentDay);
    print("👉 Cours trouvés : $data");

    // Reformater les horaires pour enlever les secondes
    final formatInput = DateFormat("HH:mm:ss");
    final formatOutput = DateFormat("HH:mm");

    for (var c in data) {
      try {
        c['horaire_debut'] =
            formatOutput.format(formatInput.parse(c['horaire_debut']));
        c['horaire_fin'] =
            formatOutput.format(formatInput.parse(c['horaire_fin']));
      } catch (e) {
        print("⚠️ Erreur de format d'horaire : $e");
      }
    }

    // Tri par horaire de début
    data.sort((a, b) {
      final format = DateFormat("HH:mm");
      try {
        final startA = format.parse(a['horaire_debut']);
        final startB = format.parse(b['horaire_debut']);
        return startA.compareTo(startB);
      } catch (e) {
        print("⚠️ Erreur parsing horaire : $e");
        return 0;
      }
    });

    for (var c in data) {
      final stats = await db.getStatsForCours(c['id']);
      c['nombre_present'] = stats['nombre_present'];
      c['nombre_absent'] = stats['nombre_absent'];
    }


    setState(() {
      cours = data;
      loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final today =
    DateFormat('EEEE d MMMM yyyy', 'fr_FR').format(DateTime.now());

    return Scaffold(
      appBar: AppBar(title: const Text("Mes cours")),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            Text(
              "👋 Bonjour ${widget.prenom},",
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: Color(0xFFECC440),
              ),
            ),
            const SizedBox(height: 4),
            Text("Nous sommes le $today",
                style: Theme.of(context).textTheme.bodyMedium),
            const SizedBox(height: 24),

            /// --- Liste des cours du prof connecté ---
            Text("📘 Vos cours aujourd'hui",
                style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),

            if (cours.isEmpty)
              const Text("Aucun cours prévu pour vous aujourd'hui."),
            ...cours.map((c) {
              return Card(
                elevation: 5,
                margin: const EdgeInsets.symmetric(vertical: 8),
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(c['nom'] ?? 'Cours',
                          style: Theme.of(context).textTheme.titleMedium),
                      const SizedBox(height: 4),
                      Text("Horaire : ${c['horaire_debut']} - ${c['horaire_fin']}"),
                      Text("Présents : ${c['nombre_present'] ?? 0}"),
                      Text("Absents : ${c['nombre_absent'] ?? 0}"),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          ElevatedButton.icon(
                            icon: const Icon(Icons.check_circle_outline),
                            label: const Text("Faire l'appel"),
                            onPressed: () async {
                              final result = await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => AppelPage(
                                    coursId: c['id'],
                                    coursNom: c['nom'] ?? "Cours",
                                  ),
                                ),
                              );

                              if (result == true) {
                                setState(() {
                                  loading = true;
                                });
                                await loadCours(); // 🔄 recharge les stats après appel
                              }
                            },
                          ),
                          ElevatedButton.icon(
                            icon: const Icon(Icons.note),
                            label: const Text("Bloc-notes"),
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => BlocNotePage(
                                    coursId: c['id'],
                                    coursNom: c['nom'] ?? "Cours",
                                  ),
                                ),
                              );
                            },
                          ),

                        ],
                      ),
                    ],
                  ),
                ),
              );

            }),

          ],
        ),
      ),
    );
  }
}
