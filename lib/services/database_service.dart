import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/eleve.dart';

class DatabaseService {
  final supabase = Supabase.instance.client;

  // ------------------- ÉLÈVES -------------------

  Future<List<Map<String, dynamic>>> getAllEleves() async {
    final data = await supabase.from('eleves').select();
    return List<Map<String, dynamic>>.from(data);
  }

  Future<List<Map<String, dynamic>>> getElevesByCours(int coursId) async {
    final data = await supabase.from('eleves').select().eq('cours_id', coursId);
    return List<Map<String, dynamic>>.from(data);
  }

  Future<void> addEleve(Eleve eleve) async {
    final res = await supabase.from("eleves").insert({
      "nom": eleve.nom,
      "prenom": eleve.prenom,
      "date_naissance": eleve.dateNaissance?.toIso8601String(), // Conversion ici
      "parent_nom": eleve.nomParent,
      "parent_prenom": eleve.prenomParent,
      "parent_email": eleve.emailParent,
      "parent_telephone": eleve.telParent,
      "premiere_annee": eleve.anneePremiereDanse,
      "adhesion_valide": eleve.adhesionAJour,
    }).select();

    final int eleveId = res[0]['id'];

    for (var coursId in eleve.coursIds) {
      await supabase.from('eleves_cours').insert({
        'eleve_id': eleveId,
        'cours_id': coursId,
      });
    }
  }

  Future<void> updateEleve(Eleve eleve) async {
    await supabase.from("eleves").update({
      "nom": eleve.nom,
      "prenom": eleve.prenom,
      "date_naissance": eleve.dateNaissance?.toIso8601String(), // Conversion ici aussi
      "parent_nom": eleve.nomParent,
      "parent_prenom": eleve.prenomParent,
      "parent_email": eleve.emailParent,
      "parent_telephone": eleve.telParent,
      "premiere_annee": eleve.anneePremiereDanse,
      "adhesion_valide": eleve.adhesionAJour,
    }).eq("id", eleve.id);
  }


  Future<List<Map<String, dynamic>>> getCoursByEleve(int eleveId) async {
    final data = await supabase
        .from('eleves_cours')
        .select('cours(*)')
        .eq('eleve_id', eleveId);
    return List<Map<String, dynamic>>.from(data);
  }

  Future<List<Map<String, dynamic>>> getEleveCours() async {
    final data = await supabase.from('eleves_cours').select();
    return List<Map<String, dynamic>>.from(data);
  }

  // ------------------- PRÉSENCES -------------------

  Future<void> savePresence(int eleveId, String statut, DateTime date) async {
    await supabase.from('presences').insert({
      'eleve_id': eleveId,
      'statut': statut,
      'date': date.toIso8601String(),
    });
  }

  Future<List<Map<String, dynamic>>> getPresences(int coursId) async {
    final response = await supabase
        .from("presences")
        .select("*, eleves(nom, prenom)")
        .eq("eleves.cours_id", coursId);
    return List<Map<String, dynamic>>.from(response);
  }

  // ------------------- COURS -------------------

  Future<List<Map<String, dynamic>>> getCours() async {
    final response = await supabase.from("cours").select();
    return List<Map<String, dynamic>>.from(response);
  }

  Future<List<Map<String, dynamic>>> getCoursById(int coursId) async {
    final res = await supabase.from('cours').select().eq('id', coursId);
    return List<Map<String, dynamic>>.from(res);
  }

  Future<List<Map<String, dynamic>>> getCoursByProfesseurAndJour(
      String prenom, String jour) async {
    final data = await supabase
        .from('cours')
        .select()
        .ilike('professeur', prenom)
        .eq('jour', jour);
    return List<Map<String, dynamic>>.from(data);
  }
}
