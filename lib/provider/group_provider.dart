import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:newbie_project_casio/model/group_model.dart';
import 'package:newbie_project_casio/model/user_model.dart';

class GroupListProvider with ChangeNotifier {
  final List<GroupModel> groupList = List.empty(growable: true);
  User? user;
  GroupListProvider({this.user});

  List<GroupModel> fetchGroupList() {
    _fetchGroupList();
    return groupList;
  }

  List<GroupModel> getGroupList() {
    return groupList;
  }

  void _fetchGroupList() async {
    groupList.clear();
    print('_fetchGroup called');
    print('${user?.email}');
    print(groupList);
    try {
      DocumentSnapshot<Map<String, dynamic>> snapshot = await FirebaseFirestore
          .instance
          .collection('user')
          .doc(user!.uid)
          .get();
      Map<String, dynamic> _userData = snapshot.data() as Map<String, dynamic>;
      List<DocumentReference>? _groupRef =
          List<DocumentReference>.from(_userData['group']) ?? [];
      if (_groupRef != null) {
        for (var i = 0; i < _groupRef.length; i++) {
          GroupModel _group = GroupModel();
          DocumentSnapshot<Map<String, dynamic>> _snapshot = await _groupRef[i]
              .get() as DocumentSnapshot<Map<String, dynamic>>;
          await _group.fromSnapShot(_snapshot);
          print('_group : ${_group.name} for ${i}');
          groupList.add(_group);
        }
      }
    } catch (error) {
      print('error in group provider');
      print(error);
    }
    for (var group in groupList) {
      print(group.name);
    }
    print(groupList);
    print('group list fetch end');
    notifyListeners();
  }

  void updateCurrentUser() {
    user = FirebaseAuth.instance.currentUser;
    notifyListeners();
  }
}
