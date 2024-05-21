import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:newbie_project_casio/model/group_model.dart';
import 'package:newbie_project_casio/model/todo_model.dart';
import 'package:newbie_project_casio/page/add_todo.dart';

class ServerPage extends StatefulWidget {
  final User user;

  ServerPage({Key? key, required this.user}) : super(key: key);

  @override
  State<ServerPage> createState() => _ServerPageState();
}

class _ServerPageState extends State<ServerPage> {
  late User user;
  @override
  void initState() {
    super.initState();
    // Firestore 컬렉션 변경 사항을 감지하여 전체 뷰 리셋
    FirebaseFirestore.instance
        .collection('todo')
        .snapshots()
        .listen((snapshot) {
      setState(() {});
    });
    FirebaseFirestore.instance
        .collection('user')
        .snapshots()
        .listen((snapshot) {
      setState(() {}); // 전체 뷰 리셋
    });
    user = widget.user;
  }

  @override
  Widget build(BuildContext context) {
    // 수정해야될지도!
    List<String> splited = user.email!.split('@');
    String name = splited[0];

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.lightGreen,
      ),
      body: SafeArea(
          child: StreamBuilder<QuerySnapshot>(
              stream:
                  FirebaseFirestore.instance.collection('group').snapshots(),
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
                                        username.add(i.name!);
                                      }
                                    } catch (error) {}
                                    if (username.contains(name)) {
                                      return Column(children: [
                                        groupName(groupModel, context),
                                        SingleChildScrollView(
                                          child: Container(
                                            height: 300,
                                            child: getToDoView(todo),
                                          ),
                                        ),
                                      ]);
                                    } else {
                                      return SizedBox(
                                        height: 1,
                                      );
                                    }
                                  }
                                });
                          }));
                }
              })
          //TextButton(
          //onPressed: () => getdata(),
          //child: Text('server page'),
          //),
          ),
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

Widget getToDoView(List<ToDoModel>? toDoList) {
  if (toDoList != null) {
    return ListView.separated(
      itemCount: toDoList.length,
      itemBuilder: (BuildContext context, int idx) {
        ToDoModel todo = toDoList[idx];
        return InkWell(
          child: Container(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                StateView(todo.state!),
                Text('${todo.name}'),
                Text('manager : ${todo.manager!.name}'),
              ],
            ),
            height: 50,
          ),
          onTap: () {
            ShowToDoDialog(context, todo);
          },
        );
      },
      separatorBuilder: (BuildContext ctx, int idx) {
        return Divider();
      },
    );
  } else {
    return Text('nothing to do');
  }
}

Widget groupName(GroupModel groupModel, BuildContext context) {
  String name = groupModel.name!;
  return Container(
    height: 50,
    width: double.infinity,
    color: Colors.green,
    child: Padding(
      padding: const EdgeInsets.fromLTRB(5, 0, 5, 0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            name,
            style: const TextStyle(color: Colors.white),
          ),
          IconButton(
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) {
                  return Dialog(
                      child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: AddToDoPage(
                      groupModel: groupModel,
                    ),
                    width: 100,
                  ));
                },
                barrierColor: Colors.white70,
              );
            },
            icon: const Icon(Icons.add),
            style: const ButtonStyle(
              iconSize: MaterialStatePropertyAll(15),
              iconColor: MaterialStatePropertyAll(Colors.white),
            ),
          ),
        ],
      ),
    ),
  );
}

Widget StateView(int state) {
  if (state == 0) {
    return IconButton(
      icon: Icon(Icons.favorite),
      onPressed: () {},
      color: Colors.grey,
    );
  } else {
    if (state == 1) {
      return IconButton(
        icon: Icon(Icons.favorite),
        onPressed: () {},
        color: Colors.yellow,
      );
    } else {
      return IconButton(
        icon: Icon(Icons.favorite),
        onPressed: () {},
        color: Colors.green,
      );
    }
  }
}

void ShowToDoDialog(BuildContext context, ToDoModel todo) {
  showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          child: Column(
            children: [
              Text('name : ${todo.name}'),
              Text(
                  'due date : ${todo.duedate?.toDate().toString().split(' ')[0] ?? 'no due date'}'),
              getRemainingDate(todo.duedate),
              Text('manager : ${todo.manager!.name}'),
              Text(
                  'workers : ${todo.worker!.map((worker) => worker.name).join(', ')}'),
              getMemo(todo.memo),
            ],
          ),
        );
      });
}

Text getRemainingDate(Timestamp? date) {
  DateTime currentDate = DateTime.now();
  if (date == null) {
    return Text('no due date!');
  }
  DateTime duedate = date.toDate();
  Duration difference = currentDate.difference(duedate);
  return Text('D ${difference.inDays - 1}');
}

Widget getMemo(String? memo) {
  if (memo != null) {
    return Column(
      children: [
        Text('memo :'),
        Container(
          width: 100,
          color: Colors.black12,
          child: Text(memo),
        )
      ],
    );
  } else {
    return Container();
  }
}
