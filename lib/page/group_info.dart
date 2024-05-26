import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:newbie_project_casio/model/group_model.dart';
import 'package:newbie_project_casio/model/todo_model.dart';
import 'package:newbie_project_casio/model/user_model.dart';
import 'package:newbie_project_casio/page/server_page.dart';

String _name = '';

class GroupInfoPage extends StatefulWidget {
  final GroupModel groupModel;
  final User user;
  const GroupInfoPage({Key? key, required this.groupModel, required this.user})
      : super(key: key);

  @override
  State<GroupInfoPage> createState() => _GroupInfoState();
}

class _GroupInfoState extends State<GroupInfoPage> {
  late GroupModel groupModel;
  late User user;
  late DocumentReference userRef;

  @override
  void initState() {
    super.initState();
    groupModel = widget.groupModel;
    user = widget.user;
    userRef = FirebaseFirestore.instance.collection('user').doc(user.uid);
    _name = groupModel.name!;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Column(
        children: [
          NameGetter(
            groupReference: groupModel.reference!,
          ),
          Center(
            child: Text(
              '<그룹 구성원>',
              style: TextStyle(color: Colors.green),
            ),
          ),
          Text('${groupModel.user!.map((item) => item.name)}'),
          SizedBox(height: 20,),
          Text('group code : ${groupModel.id}'),
          TextButton(
              onPressed: () {
                DeleteGroup(groupModel);
              },
              child: Text(
                'delete this group',
                style: TextStyle(color: Colors.lightGreen),
              )),
          ElevatedButton(
            onPressed: () {
              LeaveGroup(groupModel, userRef);
            },
            child: Text(
              'leave this group',
              style: TextStyle(color: Colors.white),
            ),
            style: ButtonStyle(
                backgroundColor: MaterialStatePropertyAll(Colors.lightGreen)),
          )
        ],
      ),
    );
  }
}

class NameGetter extends StatefulWidget {
  final DocumentReference groupReference;
  NameGetter({Key? key, required this.groupReference}) : super(key: key);

  @override
  _NameGetterState createState() => _NameGetterState();
}

class _NameGetterState extends State<NameGetter> {
  final TextEditingController _controller = TextEditingController(text: _name);
  late DocumentReference groupReference;

  @override
  void initState() {
    super.initState();
    groupReference = widget.groupReference;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          // TextField에 컨트롤러 연결
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                'name :',
                style: TextStyle(color: Colors.green, fontSize: 20),
              ),
              SizedBox(
                width: 10,
              ),
              SizedBox(
                width: 150,
                height: 20,
                child: TextField(
                  controller: _controller,
                  decoration: InputDecoration(
                    labelStyle: TextStyle(color: Colors.grey),
                    enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.green),
                    ),
                    focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.green),
                    ),
                  ),
                  cursorColor: Colors.green,
                ),
              ),
            ],
          ),
          TextButton(
              onPressed: () async {
                setState(() {
                  _name = _controller.text;
                });
                DocumentSnapshot snapshot = await groupReference.get();
                Map<String, dynamic> data =
                    snapshot.data() as Map<String, dynamic>;
                data['name'] = _name;
                groupReference.set(data);
                Navigator.pop(context);
              },
              child: Text(
                'change name',
                style: TextStyle(color: Colors.lightGreen),
              )),
        ],
      ),
    );
  }
}

DeleteGroup(GroupModel groupModel) async {
  DocumentReference groupRef = groupModel.reference!;
  DocumentSnapshot snapshot = await groupRef.get();
  Map<String, dynamic> data = snapshot.data() as Map<String, dynamic>;
  List<DocumentReference> user = List<DocumentReference>.from(data['user']);
  // group에 속한 todo 지우기
  try {
    List<DocumentReference> todo = List<DocumentReference>.from(data['todo']);
    DeleteTodo(todo);
  } catch (error) {
    print(error);
  }
  // user에서 group 지우기
  for (var userRef in user) {
    DocumentSnapshot documentSnapshot = await userRef.get();
    Map<String, dynamic>? data =
        documentSnapshot.data() as Map<String, dynamic>?;
    try {
      data!['group'].remove(groupRef);
    } catch (error) {
      print(error);
    }
    userRef.set(data);
  }

  groupRef.delete();
}

LeaveGroup(GroupModel groupModel, DocumentReference userRef) async {
  DocumentReference groupRef = groupModel.reference!;
  DocumentSnapshot snapshot = await groupRef.get();
  Map<String, dynamic> data = snapshot.data() as Map<String, dynamic>;
  List<DocumentReference> user = List<DocumentReference>.from(data['user']);

  DocumentSnapshot userSnapshot = await userRef.get();
  Map<String, dynamic> userData = userSnapshot.data() as Map<String, dynamic>;

  List<DocumentReference> userTodo = [];
  List<DocumentReference> groupTodo = [];
  List<DocumentReference> target = [];

  try {
    userTodo = List<DocumentReference>.from(userData['todo']);
  } catch (error) {
    print(error);
  }
  try {
    groupTodo = List<DocumentReference>.from(data['todo']);
  } catch (error) {
    print(error);
  }

  try {
    print(userTodo);
    print(groupTodo);
    target = intersection(userTodo, groupTodo);
    print('target : ${target}');
  } catch (error) {
    print(error);
  }

  if (target != null) {
    for (var todoRef in target) {
      print('todo ref : ${todoRef}');
      userData['todo'].remove(todoRef);
      DocumentSnapshot targetSnapshot = await todoRef.get();
      Map<String, dynamic> targetData =
          targetSnapshot.data() as Map<String, dynamic>;
      print('target data : ${targetData}');
      if (targetData['worker'].length == 1) {
        data['todo'].remove(todoRef);
        todoRef.delete();
      } else {
        targetData['worker'].remove(userRef);
        todoRef.set(targetData);
      }
    }
  }
  // group에서 지우기
  if (user.length == 1) {
    print('this');
    DeleteGroup(groupModel);
  } else {
    try {
      data!['user'].remove(userRef);
    } catch (error) {
      print(error);
    }
  }
  userData['group'].remove(groupRef);
  userRef.set(userData);
  groupRef.set(data);
}

DeleteTodo(List<DocumentReference> todo) async {
  for (var todoRef in todo) {
    DocumentSnapshot tsnapshot = await todoRef.get();
    Map<String, dynamic> todoData = tsnapshot.data() as Map<String, dynamic>;
    List<DocumentReference> user = todoData['worker'];

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
    todoRef.delete();
  }
}

List<DocumentReference> intersection<DocumentReference>(
    List<DocumentReference> list1, List<DocumentReference> list2) {
  // list1을 set으로 변환
  Set<DocumentReference> set1 = Set.from(list1);
  // list2를 set으로 변환
  Set<DocumentReference> set2 = Set.from(list2);

  // list1과 list2에 공통으로 있는 요소들을 구함
  Set<DocumentReference> intersectionSet = set1.intersection(set2);

  // 결과를 리스트로 변환하여 반환
  return intersectionSet.toList();
}
