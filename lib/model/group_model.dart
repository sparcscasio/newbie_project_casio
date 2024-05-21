import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:newbie_project_casio/model/todo_model.dart';
import 'package:newbie_project_casio/model/user_model.dart';

class _GroupModel {
  _GroupModel({
    this.id,
    this.name,
    this.reference,
    this.todo,
    this.user,
  });

  String? name;
  String? id;
  DocumentReference? reference;
  List<DocumentReference>? todo;
  List<DocumentReference>? user;

  _GroupModel.fromJson(dynamic json, this.reference) {
    name = json['name'];
    id = reference!.id;
    if (json['todo'] != null) {
      todo = List<DocumentReference>.from(json['todo']);
    } else {
      todo = null;
    }
    user = List<DocumentReference>.from(json['user']);
  }

  dynamic toJson() {
    dynamic json = {};
    json['id'] = this.id;
    json['name'] = this.name;
    json['reference'] = this.reference;
    json['todo'] = this.todo;
    json['user'] = this.user;

    return json;
  }

  _GroupModel.fromSnapShot(DocumentSnapshot<Map<String, dynamic>> snapshot)
      : this.fromJson(snapshot.data(), snapshot.reference);

  _GroupModel.fromQuerySnapshot(
      QueryDocumentSnapshot<Map<String, dynamic>> snapshot)
      : this.fromJson(snapshot.data(), snapshot.reference);

  Future<List<_GroupModel>> getData() async {
    List<_GroupModel> datas = [];

    CollectionReference<Map<String, dynamic>> collectionReference =
        FirebaseFirestore.instance.collection("group");

    QuerySnapshot<Map<String, dynamic>> querySnapshot =
        await collectionReference.get();

    for (var doc in querySnapshot.docs) {
      _GroupModel groupModel = _GroupModel.fromQuerySnapshot(doc);
      datas.add(groupModel);
    }

    return datas;
  }
}

class GroupModel {
  GroupModel({
    this.id,
    this.name,
    this.reference,
    this.todo,
    this.user,
  });

  String? name;
  String? id;
  DocumentReference? reference;
  List<ToDoModel>? todo;
  List<UserModel>? user;

  fromSnapShot(DocumentSnapshot<Map<String, dynamic>> snapshot) async {
    _GroupModel _groupModel = _GroupModel.fromSnapShot(snapshot);
    this.id = _groupModel.id;
    this.name = _groupModel.name;
    this.reference = _groupModel.reference;
    List<DocumentReference<Object?>>? _toDoReference = _groupModel.todo;
    List<DocumentReference<Object?>>? _userReference = _groupModel.user;
    List<ToDoModel> todo = [];
    List<UserModel> user = [];
    if (_toDoReference != null) {
      for (var tref in _toDoReference) {
        DocumentSnapshot tsnapshot = await tref.get();
        ToDoModel _todo = ToDoModel();
        await _todo
            .fromSnapShot(tsnapshot as DocumentSnapshot<Map<String, dynamic>>);
        todo.add(_todo);
      }
      this.todo = todo;
    } else {
      this.todo = null;
    }
    if (_userReference != null) {
      for (var uref in _userReference) {
        DocumentSnapshot usnapshot = await uref.get();
        UserModel _user = UserModel.fromSnapShot(
            usnapshot as DocumentSnapshot<Map<String, dynamic>>);
        user.add(_user);
      }
      this.user = user;
    } else {
      this.user = null;
    }
  }

  fromQuerySnapshot(
      QueryDocumentSnapshot<Map<String, dynamic>> queryDocumentSnapshot) async {
    _GroupModel _groupModel =
        _GroupModel.fromQuerySnapshot(queryDocumentSnapshot);
    this.id = _groupModel.id;
    this.name = _groupModel.name;
    this.reference = _groupModel.reference;
    List<DocumentReference<Object?>>? _toDoReference = _groupModel.todo;
    List<DocumentReference<Object?>>? _userReference = _groupModel.user;
    List<ToDoModel> todo = [];
    List<UserModel> user = [];
    if (_toDoReference != null) {
      for (var tref in _toDoReference) {
        DocumentSnapshot tsnapshot = await tref.get();
        ToDoModel _todo = ToDoModel();
        await _todo
            .fromSnapShot(tsnapshot as DocumentSnapshot<Map<String, dynamic>>);
        todo.add(_todo);
      }
      this.todo = todo;
    } else {
      this.todo = null;
    }

    if (_userReference != null) {
      for (var uref in _userReference) {
        DocumentSnapshot usnapshot = await uref.get();
        UserModel _user = UserModel.fromSnapShot(
            usnapshot as DocumentSnapshot<Map<String, dynamic>>);
        user.add(_user);
      }
      this.user = user;
    } else {
      user = [];
      this.user = null;
    }
  }

  dynamic toJson() {
    dynamic json = {};
    json['id'] = this.id;
    json['name'] = this.name;
    json['reference'] = this.reference;
    json['todo'] = this.todo;
    json['user'] = this.user;

    return json;
  }
}
