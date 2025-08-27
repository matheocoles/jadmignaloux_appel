class Eleve {
  final int id;
  final String nom;
  final String prenom;
  final String dateNaissance;
  final String nomParent;
  final String prenomParent;
  final String emailParent;
  final String telParent;
  final String anneePremiereDanse;
  final bool adhesionAJour;
  final int? coursId; // <- nouveau champ optionnel

  Eleve({
    required this.id,
    required this.nom,
    required this.prenom,
    required this.dateNaissance,
    required this.nomParent,
    required this.prenomParent,
    required this.emailParent,
    required this.telParent,
    required this.anneePremiereDanse,
    required this.adhesionAJour,
    this.coursId, // <- initialisation
  });

  factory Eleve.fromJson(Map<String, dynamic> json) {
    return Eleve(
      id: json['id'],
      nom: json['nom'],
      prenom: json['prenom'],
      dateNaissance: json['date_naissance'],
      nomParent: json['parent_nom'],
      prenomParent: json['parent_prenom'],
      emailParent: json['parent_email'],
      telParent: json['parent_telephone'],
      anneePremiereDanse: json['premiere_annee'],
      adhesionAJour: json['adhesion_valide'] ?? true,
      coursId: json['cours_id'], // <- récupération depuis Supabase
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "nom": nom,
      "prenom": prenom,
      "date_naissance": dateNaissance,
      "parent_nom": nomParent,
      "parent_prenom": prenomParent,
      "parent_email": emailParent,
      "parent_telephone": telParent,
      "premiere_annee": anneePremiereDanse,
      "adhesion_valide": adhesionAJour,
      "cours_id": coursId,
    };
  }
}
