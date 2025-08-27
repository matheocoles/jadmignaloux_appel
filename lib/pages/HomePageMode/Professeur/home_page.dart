import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../services/database_service.dart';
import '../../appel_page.dart';

class HomePageProf extends StatefulWidget {
  final String prenom; // récupéré au login

  const HomePageProf({super.key, required this.prenom});

  @override
  State<HomePageProf> createState() => _HomePageProfState();
}

class _HomePageProfState extends State<HomePageProf> {
  final db = DatabaseService();
  Map<String, dynamic>? coursActuel;
  Map<String, dynamic>? prochainCours;
  bool loading = true;

  // Dates de reprise des cours
  final List<String> joursReprise = [
    '2025-09-08',
    '2025-09-11',
    '2025-09-12',
  ];

  @override
  void initState() {
    super.initState();
    loadCours();
  }

  Future<void> loadCours() async {
    final today = DateTime.now();
    final todayStr = DateFormat('yyyy-MM-dd').format(today);

    // Vérifie si aujourd'hui est un jour de reprise
    if (!joursReprise.contains(todayStr)) {
      setState(() {
        loading = false;
        coursActuel = null;
        prochainCours = null;
      });
      return;
    }

    final currentDay = DateFormat('EEEE', 'fr_FR').format(today); // Lundi, Mardi...
    final currentTime = TimeOfDay.fromDateTime(today);

    // Récupère tous les cours du professeur pour le jour actuel
    final data = await db.getCoursByProfesseurAndJour(widget.prenom, currentDay);

    Map<String, dynamic>? actuel;
    Map<String, dynamic>? prochain;

    // Trier les cours par horaire_debut
    data.sort((a, b) => a['horaire_debut'].compareTo(b['horaire_debut']));

    for (var c in data) {
      final debut = TimeOfDay(
          hour: int.parse(c['horaire_debut'].split(':')[0]),
          minute: int.parse(c['horaire_debut'].split(':')[1]));
      final fin = TimeOfDay(
          hour: int.parse(c['horaire_fin'].split(':')[0]),
          minute: int.parse(c['horaire_fin'].split(':')[1]));

      // Cours en cours
      if ((currentTime.hour > debut.hour ||
          (currentTime.hour == debut.hour && currentTime.minute >= debut.minute)) &&
          (currentTime.hour < fin.hour ||
              (currentTime.hour == fin.hour && currentTime.minute <= fin.minute))) {
        actuel = c;
      }
      // Prochain cours
      else if (currentTime.hour < debut.hour ||
          (currentTime.hour == debut.hour && currentTime.minute < debut.minute)) {
        if (prochain == null) {
          prochain = c;
        }
      }
    }

    setState(() {
      coursActuel = actuel;
      prochainCours = prochain;
      loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text("Mes cours")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            if (coursActuel != null)
              Card(
                color: Colors.green[100],
                child: ListTile(
                  title: Text("Cours actuel : ${coursActuel!['nom']}"),
                  subtitle: Text(
                      "Horaire : ${coursActuel!['horaire_debut']} - ${coursActuel!['horaire_fin']}"),
                  trailing: ElevatedButton(
                    child: const Text("Faire l'appel"),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => AppelPage(
                            coursId: coursActuel!['id'],
                            coursNom: coursActuel!['nom'],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              )
            else
              const Text(
                "Aucun cours en cours (cours non encore repris ou terminé)",
                style: TextStyle(fontSize: 16),
              ),

            const SizedBox(height: 20),

            if (prochainCours != null)
              Card(
                color: Colors.blue[100],
                child: ListTile(
                  title: Text("Prochain cours : ${prochainCours!['nom']}"),
                  subtitle: Text(
                      "Horaire : ${prochainCours!['horaire_debut']} - ${prochainCours!['horaire_fin']}"),
                ),
              )
            else
              const Text(
                "Aucun prochain cours aujourd'hui",
                style: TextStyle(fontSize: 16),
              ),
          ],
        ),
      ),
    );
  }
}
