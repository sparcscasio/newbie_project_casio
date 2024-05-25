import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:newbie_project_casio/model/group_model.dart';
import 'package:newbie_project_casio/model/todo_model.dart';
import 'package:newbie_project_casio/model/user_model.dart';
import 'package:newbie_project_casio/page/add_group.dart';
import 'package:newbie_project_casio/page/add_todo.dart';
import 'package:newbie_project_casio/page/group_info.dart';
import 'package:newbie_project_casio/page/update_todo.dart';
import 'package:newbie_project_casio/provider/group_provider.dart';
import 'package:provider/provider.dart';

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
    // FirebaseFirestore.instance
    //     .collection('user')
    //     .snapshots()
    //     .listen((snapshot) {
    //   setState(() {}); // 전체 뷰 리셋
    // });
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
        actions: [
          IconButton(
              onPressed: () {
                showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return Dialog(
                        child: AddGroupPage(user: user),
                      );
                    });
              },
              icon: const Icon(Icons.add))
        ],
      ),
      body: SafeArea(
          child: StreamBuilder<DocumentSnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('user')
                  .doc(user.uid)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const CircularProgressIndicator();
                } else {
                  try {
                    List<DocumentReference> groupDocList =
                        List<DocumentReference>.from(snapshot.data!['group']);
                    return SizedBox(
                        child: ListView.builder(
                            shrinkWrap: true,
                            scrollDirection: Axis.vertical,
                            itemCount: groupDocList.length,
                            itemBuilder: (ctx, index) {
                              return FutureBuilder(
                                  future:
                                      getGroupModel(index, groupDocList[index]),
                                  builder: (_context, _snapshot) {
                                    if (_snapshot.connectionState ==
                                        ConnectionState.waiting) {
                                      return const CircularProgressIndicator(); // 데이터가 로드될 때까지 로딩 표시
                                    } else {
                                      GroupModel? groupModel = _snapshot.data;
                                      List<ToDoModel>? todo = groupModel!.todo;
                                      return Column(children: [
                                        groupName(groupModel, context, user),
                                        SingleChildScrollView(
                                          child: Container(
                                            height: 300,
                                            child:
                                                getToDoView(todo, groupModel),
                                          ),
                                        ),
                                      ]); //
                                    }
                                  });
                            }));
                  } catch (error) {
                    return Center(
                      child: Text('no group!'),
                    );
                  }
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

Future<GroupModel> getGroupModel(index, groupRef) async {
  GroupModel groupModel = GroupModel();
  DocumentSnapshot snapshot = await groupRef.get();
  await groupModel
      .fromSnapShot(snapshot as DocumentSnapshot<Map<String, dynamic>>);
  return groupModel;
}

Future<String?> getNameFromDocument(DocumentReference documentReference) async {
  DocumentSnapshot snapshot = await documentReference.get();
  return snapshot.toString();
}

Widget getToDoView(List<ToDoModel>? toDoList, GroupModel groupModel) {
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
                IconButton(
                    onPressed: () {
                      deleteToDo(todo, groupModel);
                    },
                    icon: Icon(Icons.delete))
              ],
            ),
            height: 50,
          ),
          onTap: () {
            ShowToDoDialog(context, todo, groupModel);
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

Widget groupName(GroupModel groupModel, BuildContext context, User user) {
  String name = groupModel.name!;
  return InkWell(
    onTap: () {
      showDialog(
          context: context,
          builder: (BuildContext context) {
            return Dialog(
              child: GroupInfoPage(
                groupModel: groupModel,
                user: user,
              ),
            );
          });
    },
    child: Container(
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
      if (state == 2) {
        return IconButton(
          icon: Icon(Icons.favorite),
          onPressed: () {},
          color: Colors.green,
        );
      } else {
        return IconButton(
          icon: Icon(Icons.favorite),
          onPressed: () {},
          color: Colors.red,
        );
      }
    }
  }
}

void ShowToDoDialog(BuildContext context, ToDoModel todo, GroupModel group) {
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
              ElevatedButton(
                  onPressed: () {
                    ShowUpdateDialog(context, todo, group);
                  },
                  child: Text('update')),
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

void ShowUpdateDialog(BuildContext context, ToDoModel todo, GroupModel group) {
  showDialog(
      context: context,
      builder: (BuildContext context) {
        return UpdateToDoPage(
          toDoModel: todo,
          groupModel: group,
        );
      });
}

deleteToDo(ToDoModel todo, GroupModel group) async {
  DocumentReference groupRef = group.reference!;
  DocumentReference todoRef = todo.reference!;
  List<DocumentReference> user =
      todo.worker!.map((item) => item.reference!).toList();

  for (var userRef in user) {
    DocumentSnapshot documentSnapshot = await userRef.get();
    Map<String, dynamic>? data =
        documentSnapshot.data() as Map<String, dynamic>?;
    try {
      data!['todo'].remove(todoRef);
    } catch (error) {
      print(error);
    }
    userRef.set(data);
  }

  DocumentSnapshot groupSnapshot = await groupRef.get();
  Map<String, dynamic>? data = groupSnapshot.data() as Map<String, dynamic>?;
  try {
    data!['todo'].remove(todoRef);
  } catch (error) {
    print(error);
  }
  groupRef.set(data);

  await todoRef.delete();
}
