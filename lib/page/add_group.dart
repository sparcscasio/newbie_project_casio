import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:newbie_project_casio/model/group_model.dart';
import 'package:newbie_project_casio/model/user_model.dart';

class AddGroupPage extends StatefulWidget {
  final User user;
  const AddGroupPage({Key? key, required this.user}) : super(key: key);

  @override
  State<AddGroupPage> createState() => _AddGroupState();
}

class _AddGroupState extends State<AddGroupPage> {
  @override
  Widget build(BuildContext context) {
    return Container(
    );
  }
}