import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:newbie_project_casio/model/group_model.dart';
import 'package:newbie_project_casio/model/todo_model.dart';

class UserModel {
  UserModel({
    this.id,
    required this.name,
    required this.group,
    required this.todo,
    this.reference,
  });

  String? id;
  String? name;
  List<DocumentReference>? group;
  List<DocumentReference>? todo;
  DocumentReference? reference;

  UserModel.fromJson(dynamic json, this.reference) {
    name = json['name'];
    id = reference!.id;
    if (json['group'] != null) {
      group = List<DocumentReference>.from(json['group']);
    } else {
      group = null;
    }
    if (json['todo'] != null) {
      todo = List<DocumentReference>.from(json['todo']);
    } else {
      todo = null;
    }
  }

  dynamic toJson() {
    dynamic json = {};
    json['id'] = this.id;
    json['name'] = this.name;
    json['reference'] = this.reference;
    json['group'] = this.group;
    json['todo'] = this.todo;

    return json;
  }

  UserModel.fromSnapShot(DocumentSnapshot<Map<String, dynamic>> snapshot)
      : this.fromJson(snapshot.data(), snapshot.reference);

  UserModel.fromQuerySnapshot(
      QueryDocumentSnapshot<Map<String, dynamic>> snapshot)
      : this.fromJson(snapshot.data(), snapshot.reference);

  Future<List<ToDoModel>> getData() async {
    List<ToDoModel> datas = [];

    CollectionReference<Map<String, dynamic>> collectionReference =
        FirebaseFirestore.instance.collection("todo");

    QuerySnapshot<Map<String, dynamic>> querySnapshot =
        await collectionReference.get();

    for (var doc in querySnapshot.docs) {
      ToDoModel toDoModel = ToDoModel(state: 0);
      await toDoModel.fromQuerySnapshot(doc);
      datas.add(toDoModel);
    }

    return datas;
  }
}
