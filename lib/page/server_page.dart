import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:newbie_project_casio/model/group_model.dart';
import 'package:newbie_project_casio/model/todo_model.dart';

class ServerPage extends StatefulWidget {
  const ServerPage({Key? key}) : super(key: key);

  @override
  State<ServerPage> createState() => _ServerPageState();
}

class _ServerPageState extends State<ServerPage> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance.collection('group').snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const CircularProgressIndicator();
              } else {
                QuerySnapshot querySnapshot = snapshot.data!;
                return SizedBox(
                    child: ListView.builder(
                        shrinkWrap: true,
                        scrollDirection: Axis.vertical,
                        itemCount: snapshot.data?.docs.length,
                        itemBuilder: (ctx, index) {
                          return FutureBuilder(
                              future: getGroupModel(index, querySnapshot),
                              builder: (_context, _snapshot) {
                                if (_snapshot.connectionState ==
                                    ConnectionState.waiting) {
                                  return const CircularProgressIndicator(); // 데이터가 로드될 때까지 로딩 표시
                                } else {
                                  GroupModel? groupModel = _snapshot.data;
                                  List<ToDoModel>? todo = groupModel!.todo;
                                  List<String> username = [];
                                  try {
                                    for (var i in groupModel.user!) {
                                      username.add(i.name);
                                    }
                                  } catch (error) {
                                    print(error);
                                  }
                                  return Column(children: [
                                    Text(groupModel.name!),
                                    Text(username.toString()),
                                    SingleChildScrollView(
                                      child: Container(
                                        height: 100,
                                        child: getToDoView(todo!),
                                      ),
                                    ),
                                  ]);
                                }
                              });
                        }));
              }
            })
        //TextButton(
        //onPressed: () => getdata(),
        //child: Text('server page'),
        //),
        );
  }
}

Future<GroupModel> getGroupModel(index, querySnapshot) async {
  GroupModel groupModel = GroupModel();
  await groupModel.fromQuerySnapshot(
      querySnapshot.docs[index] as QueryDocumentSnapshot<Map<String, dynamic>>);
  return groupModel;
}

Future<String?> getNameFromDocument(DocumentReference documentReference) async {
  DocumentSnapshot snapshot = await documentReference.get();
  return snapshot.toString();
}

Widget getToDoView(List<ToDoModel> toDoList) {
  return ListView.separated(
    itemCount: toDoList.length,
    itemBuilder: (BuildContext ctx, int idx) {
      ToDoModel todo = toDoList[idx];
      return Container(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Manager : ${todo.manager.toString()}'),
            Text(' '),
            Text('state : ${todo.state}'),
            Text(' '),
            Text('worker : ${todo.worker![0].name}'),
            Text(' '),
            Text('Name : ${todo.name}'),
            Text(' '),
          ],
        ),
        height: 50,
      );
    },
    separatorBuilder: (BuildContext ctx, int idx) {
      return Divider();
    },
  );
}
