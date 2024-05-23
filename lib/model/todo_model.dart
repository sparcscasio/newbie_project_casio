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
    this.duedate,
    this.memo,
  });

  String? id;
  String? name;
  List<DocumentReference>? worker;
  DocumentReference? manager;
  DocumentReference? reference;
  DocumentReference? group;
  int? state;
  Timestamp? duedate;
  String? memo;

  _ToDoModel.fromJson(dynamic json, this.reference) {
    name = json['name'];
    worker = List<DocumentReference>.from(json['worker']);
    manager = json['manager'];
    id = reference!.id;
    state = json['state'];
    group = json['group'];
    duedate = json['duedate'];
    memo = json['memo'];
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
    json['duedate'] = this.duedate;
    json['memo'] = this.memo;

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
    this.duedate,
    this.memo,
  });

  String? name;
  String? id;
  List<UserModel>? worker;
  GroupModel? group;
  UserModel? manager;
  DocumentReference? reference;
  int? state;
  Timestamp? duedate;
  String? memo;

  fromSnapShot(DocumentSnapshot<Map<String, dynamic>> snapshot) async {
    _ToDoModel _toDoModel = _ToDoModel.fromSnapShot(snapshot);
    this.id = _toDoModel.id;
    this.name = _toDoModel.name;
    this.reference = _toDoModel.reference;
    this.state = _toDoModel.state;
    this.duedate = _toDoModel.duedate;
    this.memo = _toDoModel.memo;

    List<DocumentReference<Object?>>? _workerReference = _toDoModel.worker;
    DocumentReference<Object?>? _managerReference = _toDoModel.manager;
    
    List<UserModel> worker = [];

    if (_workerReference != null) {
      for (var wref in _workerReference) {
        DocumentSnapshot wsnapshot = await wref.get();
        UserModel _worker = UserModel.fromSnapShot(
            wsnapshot as DocumentSnapshot<Map<String, dynamic>>);
        worker.add(_worker);
      }
      this.worker = worker;
    } else {
      this.worker = null;
    }

    if (_managerReference != null) {
      DocumentSnapshot msnapshot = await _managerReference!.get();
      UserModel _manager = UserModel.fromSnapShot(
          msnapshot as DocumentSnapshot<Map<String, dynamic>>);
      this.manager = _manager;
    } else {
      this.manager = null;
    }
  }

  fromQuerySnapshot(
      QueryDocumentSnapshot<Map<String, dynamic>> queryDocumentSnapshot) async {
    _ToDoModel _toDoModel = _ToDoModel.fromQuerySnapshot(queryDocumentSnapshot);
    this.id = _toDoModel.id;
    this.name = _toDoModel.name;
    this.reference = _toDoModel.reference;
    this.state = _toDoModel.state;
    this.duedate = _toDoModel.duedate;
    this.memo = _toDoModel.memo;
    List<DocumentReference<Object?>>? _workerReference = _toDoModel.worker;
    DocumentReference<Object?>? _managerReference = _toDoModel.manager;
    List<UserModel> worker = [];

    if (_workerReference != null) {
      for (var wref in _workerReference) {
        DocumentSnapshot wsnapshot = await wref.get();
        UserModel _worker = UserModel.fromSnapShot(
            wsnapshot as DocumentSnapshot<Map<String, dynamic>>);
        worker.add(_worker);
      }
      this.worker = worker;
    } else {
      this.worker = null;
    }

    if (_managerReference != null) {
      DocumentSnapshot msnapshot = await _managerReference!.get();
      UserModel _manager = UserModel.fromSnapShot(
          msnapshot as DocumentSnapshot<Map<String, dynamic>>);
      this.manager = _manager;
    } else {
      this.manager = null;
    }
  }

  dynamic toJson() {
    dynamic json = {};
    json['name'] = this.name;
    json['worker'] = this.worker;
    json['manager'] = this.manager;
    json['id'] = this.id;
    json['state'] = this.state;
    json['group'] = this.group;
    json['duedate'] = this.duedate;
    json['memo'] = this.memo;

    return json;
  }
}
