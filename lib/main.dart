import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:newbie_project_casio/firebase_options.dart';
import 'package:newbie_project_casio/page/auth_gate.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // firebase 초기화
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: AuthGate(),
    );
  }
}
