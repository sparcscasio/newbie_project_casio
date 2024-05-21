import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' hide EmailAuthProvider;
import 'package:firebase_ui_auth/firebase_ui_auth.dart';
import 'package:flutter/material.dart';
import 'package:newbie_project_casio/page/main_page.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return SignInScreen(
            providers: [
              EmailAuthProvider(),
            ],
          );
        }
        User user = snapshot.data!;
        UpdateDataBase(user);
        return MainPage(user: user);
      },
    );
  }
}

void UpdateDataBase(User user) async {
  DocumentReference docRef =
      FirebaseFirestore.instance.collection('user').doc(user.uid);
  DocumentSnapshot doc = await docRef.get();

  if (!doc.exists) {
    List<String> splited = user.email!.split('@');
    await docRef.set({
      'name': splited[0],
      'group': [],
      'todo': [],
    });
  }
}
