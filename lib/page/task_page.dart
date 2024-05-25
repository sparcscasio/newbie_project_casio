import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
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
      child: SingleChildScrollView(
        child: FutureBuilder(
            future: FirebaseFirestore.instance.collection('user').doc(id).get(),
            builder: (BuildContext context,
                AsyncSnapshot<DocumentSnapshot> snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return CircularProgressIndicator(); // 데이터를 기다리는 동안 로딩 표시
              } else {
                Map<String, dynamic> data =
                    snapshot.data!.data() as Map<String, dynamic>;
                try {
                  return Column(
                    children: [
                      Container(
                        child: FutureBuilder(
                            future: getMap(data['todo']),
                            builder: (_context, _snapshot) {
                              if (_snapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return const CircularProgressIndicator(); // 데이터가 로드될 때까지 로딩 표시
                              } else {
                                return groupMapView(_snapshot.data
                                    as Map<DocumentReference, List<ToDoModel>>);
                              }
                            }),
                      ),
                      Container(
                        height: 50,
                        color: Colors.green,
                        alignment: Alignment.center,
                        child: Text(
                          '승인 목록',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                      Container(
                          child: FutureBuilder(
                              future: getManaging(data['todo'], user),
                              builder: (context, snapshot) {
                                if (snapshot.connectionState ==
                                    ConnectionState.waiting) {
                                  return const CircularProgressIndicator(); // 데이터가 로드될 때까지 로딩 표시
                                } else {
                                  return managingMapView(snapshot.data!);
                                }
                              })),
                    ],
                  );
                } catch (error) {
                  return Text('Nothing to do!');
                }
              }
            }),
      ),
    );
  }

  Future<ToDoModel> getToDoModel(docRef) async {
    ToDoModel toDoModel = ToDoModel();
    DocumentSnapshot snapshot = await docRef.get();
    await toDoModel
        .fromSnapShot(snapshot as DocumentSnapshot<Map<String, dynamic>>);
    return toDoModel;
  }

  Future<Map<DocumentReference, List<ToDoModel>>> getMap(docList) async {
    Map<DocumentReference, List<ToDoModel>> res = {};
    for (var ref in docList) {
      ToDoModel _todo = await getToDoModel(ref);
      DocumentSnapshot documentSnapshot = await ref.get();
      Map<String, dynamic>? data =
          documentSnapshot.data() as Map<String, dynamic>?;
      DocumentReference groupref = data!['group'];
      try {
        res[groupref]!.add(_todo);
      } catch (error) {
        res[groupref] = [_todo];
      }
    }
    print(res);
    return res;
  }

  Future<Map<DocumentReference, List<ToDoModel>>> getManaging(
      docList, User user) async {
    Map<DocumentReference, List<ToDoModel>> res = {};
    docList = List<DocumentReference>.from(docList);

    for (var ref in docList) {
      ToDoModel todo = await getToDoModel(ref);
      DocumentSnapshot documentSnapshot = await ref.get();
      Map<String, dynamic>? data =
          documentSnapshot.data() as Map<String, dynamic>?;
      DocumentReference groupref = data!['group'];
      if (todo!.manager!.id == user.uid) {
        try {
          res[groupref]!.add(todo);
        } catch (error) {
          res[groupref] = [todo];
        }
      }
    }
    return res;
  }

  Widget manageView(ToDoModel todo) {
    return Container(
      height: 50,
      child: Row(
        children: [
          getRemainingDate(todo.duedate, todo.state!),
          SizedBox(
            width: 10,
          ),
          Text(todo.name!),
          SizedBox(
            width: 10,
          ),
          StateViewManager(todo),
        ],
      ),
    );
  }

  Widget todoView(ToDoModel todo) {
    return Container(
      height: 50,
      child: Row(
        children: [
          getRemainingDate(todo.duedate, todo.state!),
          SizedBox(
            width: 10,
          ),
          Text(todo.name!),
          SizedBox(
            width: 10,
          ),
          StateViewToDo(todo),
        ],
      ),
    );
  }

  Widget StateViewManager(ToDoModel todo) {
    int state = todo.state!;

    if (state == 0 || state == -1) {
      return Text(
        '진행 중',
        style: TextStyle(color: Colors.grey),
      );
    } else {
      if (state == 1) {
        return Row(
          children: [
            Text(
              '승인 대기',
              style: TextStyle(color: Colors.red),
            ),
            SizedBox(
              width: 20,
            ),
            ElevatedButton(
                onPressed: () {
                  SetState(-1, todo);
                  setState(() {});
                },
                child: Text('반려')),
            SizedBox(
              width: 10,
            ),
            ElevatedButton(
                onPressed: () {
                  SetState(2, todo);
                  setState(() {});
                },
                child: Text('승인')),
          ],
        );
      } else {
        return Row(
          children: [
            Text(
              '승인 완료',
              style: TextStyle(color: Colors.green),
            ),
            SizedBox(
              width: 20,
            ),
            ElevatedButton(
                onPressed: () {
                  SetState(1, todo);
                  setState(() {});
                },
                child: Text('승인 취소')),
          ],
        );
      }
    }
  }

  Widget StateViewToDo(ToDoModel todo) {
    int state = todo.state!;

    if (state == 0) {
      return Row(
        children: [
          Text(
            '진행 중',
            style: TextStyle(color: Colors.grey),
          ),
          SizedBox(
            width: 20,
          ),
          ElevatedButton(
              onPressed: () {
                SetState(1, todo);
                setState(() {});
              },
              child: Text('승인 요청하기')),
        ],
      );
    } else {
      if (state == 1) {
        return Text(
          '승인 대기 중',
          style: TextStyle(color: Colors.yellow),
        );
      } else {
        if (state == -1) {
          return Row(
            children: [
              Text(
                '반려됨',
                style: TextStyle(color: Colors.red),
              ),
              SizedBox(
                width: 20,
              ),
              ElevatedButton(
                  onPressed: () {
                    SetState(1, todo);
                    setState(() {});
                  },
                  child: Text('승인 요청하기')),
            ],
          );
        } else {
          return Text(
            '승인 완료',
            style: TextStyle(color: Colors.green),
          );
        }
      }
    }
  }

  getRemainingDate(Timestamp? date, int state) {
    DateTime currentDate = DateTime.now();
    if (state == 2) {
      return Icon(
        Icons.check,
        color: Colors.green,
      );
    }
    if (date == null) {
      return Text(
        'no due',
        style: TextStyle(color: Colors.black12),
      );
    }
    DateTime duedate = date.toDate();
    Duration difference = currentDate.difference(duedate);
    if (difference.inDays >= -2) {
      return Text(
        'D ${difference.inDays - 1}',
        style: TextStyle(color: Colors.red, fontWeight: FontWeight.w500),
      );
    } else {
      return Text('D ${difference.inDays - 1}');
    }
  }

  SetState(int state, ToDoModel todo) async {
    DocumentReference ref = todo.reference!;
    DocumentSnapshot snapshot = await ref.get();
    Map<String, dynamic>? data = snapshot.data() as Map<String, dynamic>?;
    try {
      data!['state'] = state;
    } catch (error) {
      print(error);
    }
    ref.set(data);
  }

  groupMapView(Map<DocumentReference, List<ToDoModel>> groupMap) {
    List<DocumentReference> groupRef = groupMap.keys.toList();
    print(groupRef);
    return ListView.builder(
        shrinkWrap: true,
        itemCount: groupRef.length,
        itemBuilder: ((context, index) {
          DocumentReference ref = groupRef[index];
          List<ToDoModel> todo = groupMap[ref]!;
          return Column(
            children: [
              FutureBuilder(
                  future: getGroupName(ref),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return CircularProgressIndicator(); // 데이터를 기다리는 동안 로딩 표시
                    } else {
                      String name = snapshot.data!;
                      return Container(
                        height: 50,
                        color: Colors.lightGreen,
                        alignment: Alignment.center,
                        child: Text(
                          name,
                          style: TextStyle(color: Colors.white),
                        ),
                      );
                    }
                  }),
              ListView.builder(
                  shrinkWrap: true,
                  itemCount: todo.length,
                  itemBuilder: (ctx, idx) {
                    return todoView(todo[idx]);
                  }),
            ],
          );
        }));
  }

  managingMapView(Map<DocumentReference, List<ToDoModel>> manageMap) {
    List<DocumentReference> groupRef = manageMap.keys.toList();
    print(groupRef);
    return ListView.builder(
        shrinkWrap: true,
        itemCount: groupRef.length,
        itemBuilder: ((context, index) {
          DocumentReference ref = groupRef[index];
          List<ToDoModel> todo = manageMap[ref]!;
          return Column(
            children: [
              FutureBuilder(
                  future: getGroupName(ref),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return CircularProgressIndicator(); // 데이터를 기다리는 동안 로딩 표시
                    } else {
                      String name = snapshot.data!;
                      return Container(
                        height: 50,
                        color: Colors.lightGreen,
                        alignment: Alignment.center,
                        child: Text(
                          name,
                          style: TextStyle(color: Colors.white),
                        ),
                      );
                    }
                  }),
              ListView.builder(
                  shrinkWrap: true,
                  itemCount: todo.length,
                  itemBuilder: (ctx, idx) {
                    return manageView(todo[idx]);
                  }),
            ],
          );
        }));
  }

  Future<String> getGroupName(DocumentReference ref) async {
    DocumentSnapshot snapshot = await ref.get();
    Map<String, dynamic>? data = snapshot.data() as Map<String, dynamic>?;
    print(data!['name']);
    return data!['name'];
  }
}
