import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:newbie_project_casio/model/group_model.dart';
import 'package:newbie_project_casio/model/user_model.dart';

class _ToDoModel {
  _ToDoModel({
    this.id,
    this.name,
    this.worker,
    this.state,
    this.group,
    this.manager,
    this.reference,
  });

  String? id;
  String? name;
  List<DocumentReference>? worker;
  DocumentReference? manager;
  DocumentReference? reference;
  DocumentReference? group;
  int? state;

  _ToDoModel.fromJson(dynamic json, this.reference) {
    name = json['name'];
    worker = List<DocumentReference>.from(json['worker']);
    manager = json['manager'];
    id = reference!.id;
    state = json['state'];
    group = json['group'];
  }

  dynamic toJson() {
    dynamic json = {};
    json['id'] = this.id;
    json['name'] = this.name;
    json['worker'] = this.worker;
    json['manager'] = this.manager;
    json['state'] = this.state;
    json['reference'] = this.reference;
    json['group'] = this.group;

    return json;
  }

  _ToDoModel.fromSnapShot(DocumentSnapshot<Map<String, dynamic>> snapshot)
      : this.fromJson(snapshot.data(), snapshot.reference);

  _ToDoModel.fromQuerySnapshot(
      QueryDocumentSnapshot<Map<String, dynamic>> snapshot)
      : this.fromJson(snapshot.data(), snapshot.reference);

  Future<List<_ToDoModel>> getData() async {
    List<_ToDoModel> datas = [];

    CollectionReference<Map<String, dynamic>> collectionReference =
        FirebaseFirestore.instance.collection("todo");

    QuerySnapshot<Map<String, dynamic>> querySnapshot =
        await collectionReference.get();

    for (var doc in querySnapshot.docs) {
      _ToDoModel toDoModel = _ToDoModel.fromQuerySnapshot(doc);
      datas.add(toDoModel);
    }

    return datas;
  }
}

class ToDoModel {
  ToDoModel({
    this.id,
    this.name,
    this.worker,
    this.state,
    this.group,
    this.manager,
    this.reference,
  });

  String? name;
  String? id;
  List<UserModel>? worker;
  GroupModel? group;
  UserModel? manager;
  DocumentReference? reference;
  int? state;

  fromSnapShot(DocumentSnapshot<Map<String, dynamic>> snapshot) async {
    _ToDoModel _toDoModel = _ToDoModel.fromSnapShot(snapshot);
    print('_todo model : ${_toDoModel.toJson()}');
    this.id = _toDoModel.id;
    this.name = _toDoModel.name;
    this.reference = _toDoModel.reference;
    this.state = _toDoModel.state;

    List<DocumentReference<Object?>>? _workerReference = _toDoModel.worker;
    DocumentReference<Object?>? _managerReference = _toDoModel.manager;
    List<UserModel> worker = [];

    try {
      for (var wref in _workerReference!) {
        DocumentSnapshot wsnapshot = await wref.get();
        UserModel _worker = UserModel.fromSnapShot(
            wsnapshot as DocumentSnapshot<Map<String, dynamic>>);
        worker.add(_worker);
      }

      this.worker = worker;
    } catch (error) {
      print('phase 1');
      print(error);
    }

    try {
      DocumentSnapshot msnapshot = await _managerReference!.get();
      UserModel _manager = UserModel.fromSnapShot(
          msnapshot as DocumentSnapshot<Map<String, dynamic>>);
      this.manager = _manager;
    } catch (error) {
      print(error);
      this.manager = null;
    }
    print('함수 실행 결과');
    print(this.toJson());
  }

  fromQuerySnapshot(
      QueryDocumentSnapshot<Map<String, dynamic>> queryDocumentSnapshot) async {
    _ToDoModel _toDoModel = _ToDoModel.fromQuerySnapshot(queryDocumentSnapshot);
    this.id = _toDoModel.id;
    this.name = _toDoModel.name;
    this.reference = _toDoModel.reference;
    this.state = _toDoModel.state;
    List<DocumentReference<Object?>>? _workerReference = _toDoModel.worker;
    DocumentReference<Object?>? _managerReference = _toDoModel.manager;
    List<UserModel> worker = [];

    try {
      for (var wref in _workerReference!) {
        DocumentSnapshot wsnapshot = await wref.get();
        UserModel _worker = UserModel.fromSnapShot(
            wsnapshot as DocumentSnapshot<Map<String, dynamic>>);
        worker.add(_worker);
      }
    } catch (error) {
      print(error);
    }

    try {
      DocumentSnapshot msnapshot = await _managerReference!.get();
      UserModel _manager = UserModel.fromSnapShot(
          msnapshot as DocumentSnapshot<Map<String, dynamic>>);
      this.manager = _manager;
    } catch (error) {
      print(error);
      this.manager = null;
    }
    print('here!');
    print(this.toJson());
  }

  dynamic toJson() {
    dynamic json = {};
    json['name'] = this.name;
    json['worker'] = this.worker;
    json['manager'] = this.manager;
    json['id'] = this.id;
    json['state'] = this.state;
    json['group'] = this.group;

    return json;
  }
}
