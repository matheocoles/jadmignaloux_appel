import 'package:flutter/material.dart';
import 'package:jadmignaloux_appel/pages/HomePageMode/Professeur/home_page_test.dart';
import 'home_page.dart';

class WelcomeProfPage extends StatefulWidget {
  final String prenom;

  const WelcomeProfPage({super.key, required this.prenom});

  @override
  State<WelcomeProfPage> createState() => _WelcomeProfPageState();
}

class _WelcomeProfPageState extends State<WelcomeProfPage> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 5), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => HomePageProfTest(prenom: widget.prenom),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue[50],
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.school,
              size: 80,
              color: Color(0xFFECC440),
            ),
            const SizedBox(height: 20),
            Text(
              "Bonjour ${widget.prenom} 👋",
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: Color(0xFFECC440),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            const Text(
              "Chargement de vos cours...",
              style: TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}
