import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:newbie_project_casio/model/group_model.dart';
import 'package:newbie_project_casio/model/user_model.dart';

String _name = '';

class AddGroupPage extends StatefulWidget {
  final User user;
  const AddGroupPage({Key? key, required this.user}) : super(key: key);

  @override
  State<AddGroupPage> createState() => _AddGroupState();
}

class _AddGroupState extends State<AddGroupPage> {
  late User user;
  late DocumentReference userRef;

  @override
  void initState() {
    super.initState();
    user = widget.user;
    userRef = FirebaseFirestore.instance.collection('user').doc(user.uid);
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 250,
      child: Column(children: [
        NameGetter(),
        ElevatedButton(
          onPressed: () {
            UpdateDatabase(userRef);
            Navigator.pop(context);
          },
          child: Text(
            '그룹 추가하기',
            style: TextStyle(color: Colors.white),
          ),
          style: ButtonStyle(
              backgroundColor: MaterialStatePropertyAll(Colors.lightGreen)),
        ),
      ]),
    );
  }
}

class NameGetter extends StatefulWidget {
  @override
  _NameGetterState createState() => _NameGetterState();
}

class _NameGetterState extends State<NameGetter> {
  final TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          // TextField에 컨트롤러 연결
          Text(
            '이름 : ${_name}',
            style: TextStyle(color: Colors.green),
          ),
          TextField(
            controller: _controller,
            decoration: InputDecoration(
              labelText: 'Enter name',
              labelStyle: TextStyle(color: Colors.grey),
              enabledBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: Colors.green),
              ),
              focusedBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: Colors.green),
              ),
            ),
            cursorColor: Colors.green,
          ),
          SizedBox(height: 20),
          TextButton(
              onPressed: () {
                setState(() {
                  _name = _controller.text;
                });
              },
              child: Text(
                'Enter',
                style: TextStyle(color: Colors.lightGreen),
              )),
        ],
      ),
    );
  }
}

UpdateDatabase(DocumentReference userRef) async {
  CollectionReference collectionRef =
      FirebaseFirestore.instance.collection('group');
  Map<String, dynamic> data = {
    'name': _name,
    'user': [userRef],
    'todo': [],
  };
  DocumentReference docRef = await collectionRef.add(data);

  UpdateUser(docRef, userRef);
}

UpdateUser(DocumentReference groupRef, DocumentReference userRef) async {
  DocumentSnapshot documentSnapshot = await userRef.get();
  Map<String, dynamic>? data = documentSnapshot.data() as Map<String, dynamic>?;
  try {
    data!['group'].add(groupRef);
  } catch (error) {
    data!['group'] = [groupRef];
  }
  userRef.set(data);
}
