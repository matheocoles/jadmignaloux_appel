import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class BlocNotePage extends StatefulWidget {
  final int coursId;
  final String coursNom;

  const BlocNotePage({super.key, required this.coursId, required this.coursNom});

  @override
  State<BlocNotePage> createState() => _BlocNotePageState();
}

class _BlocNotePageState extends State<BlocNotePage> {
  final supabase = Supabase.instance.client;
  final controller = TextEditingController();
  bool loading = true;

  @override
  void initState() {
    super.initState();
    loadNote();
  }

  Future<void> loadNote() async {
    final response = await supabase
        .from('bloc_notes')
        .select('contenu')
        .eq('cours_id', widget.coursId)
        .order('date', ascending: false)
        .limit(1)
        .maybeSingle();

    if (response != null && response['contenu'] != null) {
      controller.text = response['contenu'];
    }

    setState(() {
      loading = false;
    });
  }

  Future<void> saveNote() async {
    final existing = await supabase
        .from('bloc_notes')
        .select('id')
        .eq('cours_id', widget.coursId)
        .order('date', ascending: false)
        .limit(1)
        .maybeSingle();

    if (existing != null && existing['id'] != null) {
      // Mise à jour
      await supabase.from('bloc_notes').update({
        'contenu': controller.text,
        'date': DateTime.now().toIso8601String(),
      }).eq('id', existing['id']);
    } else {
      // Insertion
      await supabase.from('bloc_notes').insert({
        'cours_id': widget.coursId,
        'contenu': controller.text,
      });
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("📝 Bloc-note mis à jour")),
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Bloc-note : ${widget.coursNom}")),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const Text("🗒️ Écris tes remarques pour ce cours :"),
            const SizedBox(height: 12),
            Expanded(
              child: TextField(
                controller: controller,
                maxLines: null,
                expands: true,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: "Tape ici...",
                ),
              ),
            ),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              icon: const Icon(Icons.save),
              label: const Text("Sauvegarder"),
              onPressed: saveNote,
            ),
          ],
        ),
      ),
    );
  }
}
