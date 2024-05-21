import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:newbie_project_casio/model/todo_model.dart';
import 'package:newbie_project_casio/model/user_model.dart';

class TaskPage extends StatefulWidget {
  final User user;

  const TaskPage({Key? key, required this.user}) : super(key: key);

  @override
  State<TaskPage> createState() => _TaskPageState();
}

class _TaskPageState extends State<TaskPage> {
  List<ToDoModel> manageToDo = [];

  late User user;

  @override
  void initState() {
    super.initState();
    user = widget.user;
  }

  @override
  Widget build(BuildContext context) {
    String id = user.uid;

    return SafeArea(
      child: FutureBuilder(
          future: FirebaseFirestore.instance.collection('user').doc(id).get(),
          builder:
              (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return CircularProgressIndicator(); // 데이터를 기다리는 동안 로딩 표시
            } else {
              Map<String, dynamic> data =
                  snapshot.data!.data() as Map<String, dynamic>;
              try {
                return Container(
                  height: MediaQuery.of(context).size.height,
                  child: ListView.builder(
                      itemCount: data['todo'].length,
                      itemBuilder: (ctx, index) {
                        return FutureBuilder(
                            future: getToDoModel(data['todo'][index]),
                            builder: (_context, _snapshot) {
                              if (_snapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return const CircularProgressIndicator(); // 데이터가 로드될 때까지 로딩 표시
                              } else {
                                ToDoModel? toDoModel = _snapshot.data;
                                if (toDoModel!.manager!.id == user.uid) {
                                  return Container(
                                    child: Text(
                                        'managing : ${toDoModel.worker?.map((worker) => worker.name).toList()}'),
                                  );
                                } else {
                                  return Text(
                                      '${toDoModel.worker?.map((worker) => worker.name).toList()}');
                                }
                              }
                            });
                      }),
                );
              } catch (error) {
                return Text('Nothing to do!');
              }
            }
          }),
    );
  }
}

Future<ToDoModel> getToDoModel(docRef) async {
  ToDoModel toDoModel = ToDoModel();
  DocumentSnapshot snapshot = await docRef.get();
  await toDoModel
      .fromSnapShot(snapshot as DocumentSnapshot<Map<String, dynamic>>);
  return toDoModel;
}
