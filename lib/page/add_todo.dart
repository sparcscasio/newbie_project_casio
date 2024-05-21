import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:newbie_project_casio/model/group_model.dart';
import 'package:newbie_project_casio/model/user_model.dart';

List<bool>? _indexList;
int _index = 0;
String _name = '';
String? _memo;
DateTime? _selectedDate = null;

class AddToDoPage extends StatefulWidget {
  final GroupModel groupModel;
  const AddToDoPage({Key? key, required this.groupModel}) : super(key: key);

  @override
  State<AddToDoPage> createState() => _AddToDoPage();
}

class _AddToDoPage extends State<AddToDoPage> {
  @override
  Widget build(BuildContext context) {
    GroupModel groupModel = widget.groupModel;
    List<UserModel>? _users = groupModel.user;
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
      ),
      clipBehavior: Clip.antiAlias,
      child: Scaffold(
        body: SingleChildScrollView(
          child: SafeArea(
            child: Column(
              children: [
                Text(groupModel.name!),
                Text('select workers'),
                Center(
                  child: Container(
                    clipBehavior: Clip.antiAlias,
                    child: UserNameStack(
                      users: _users,
                    ),
                    height: 100,
                    width: 250,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.lightGreen),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    //color: Colors.black,
                  ),
                ),
                Text('select manager'),
                Center(
                  child: Container(
                    clipBehavior: Clip.antiAlias,
                    child: ManagerStack(
                      users: _users,
                    ),
                    height: 100,
                    width: 250,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.lightGreen),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    //color: Colors.black,
                  ),
                ),
                NameGetter(),
                MemoGetter(),
                DateGetter(),
              ],
            ),
          ),
        ),
        appBar: AppBar(
          backgroundColor: Colors.lightGreen,
          title: Text('hello'),
          actions: [
            IconButton(
              icon: Icon(Icons.add),
              onPressed: () {
                List<DocumentReference> worker = [];
                if (_indexList != null) {
                  for (var i = 0; i < _indexList!.length; i++) {
                    if (_indexList![i] == true) {
                      worker.add(_users![i].reference!);
                    }
                  }
                  if (worker.length != 0) {
                    if (_name == '') {
                    } else {
                      DocumentReference manager = _users![_index].reference!;
                      DocumentReference groupref = groupModel.reference!;
                      DocumentReference _todo =
                          UpdateToDo(groupref, worker, manager, _name, _memo);
                      UpdateGroup(_todo, groupref);
                      UpdateUser(_todo, worker);
                    }
                  } else {}
                } else {}
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }
}

class UserNameStack extends StatefulWidget {
  final List<UserModel>? users;

  UserNameStack({super.key, required this.users});

  @override
  _UserNameStackState createState() => _UserNameStackState();
}

class _UserNameStackState extends State<UserNameStack> {
  @override
  void initState() {
    super.initState();
    if (widget.users != null) {
      _indexList = List<bool>.filled(widget.users!.length, false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.users != null) {
      return ListView.separated(
        itemCount: widget.users!.length,
        itemBuilder: (context, index) {
          return ListTile(
            tileColor: Colors.transparent,
            selectedTileColor: Colors.lightGreen,
            title: Text(
              widget.users![index].name!,
              style: const TextStyle(
                color: Colors.black,
                fontSize: 15,
              ),
            ),
            selected: _indexList![index],
            onTap: () {
              setState(() {
                _indexList![index] = !_indexList![index];
              });
            },
          );
        },
        separatorBuilder: (context, index) {
          return Divider(
            color: Colors.grey,
            thickness: 1,
          );
        },
      );
    } else {
      return ListTile(
        title: Text('No users!'),
      );
    }
  }
}

class ManagerStack extends StatefulWidget {
  final List<UserModel>? users;

  ManagerStack({super.key, required this.users});

  @override
  _ManagerStackState createState() => _ManagerStackState();
}

class _ManagerStackState extends State<ManagerStack> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.users != null) {
      return ListView.separated(
        itemCount: widget.users!.length,
        itemBuilder: (context, index) {
          return ListTile(
            tileColor: Colors.transparent,
            selectedTileColor: Colors.lightGreen,
            title: Text(
              widget.users![index].name!,
              style: const TextStyle(
                color: Colors.black,
                fontSize: 15,
              ),
            ),
            selected: index == _index,
            onTap: () {
              setState(() {
                _index = index;
                print(_index);
              });
            },
          );
        },
        separatorBuilder: (context, index) {
          return Divider(
            color: Colors.grey,
            thickness: 1,
          );
        },
      );
    } else {
      return ListTile(
        title: Text('No users!'),
      );
    }
  }
}

class NameGetter extends StatefulWidget {
  @override
  _NameGetterState createState() => _NameGetterState();
}

class _NameGetterState extends State<NameGetter> {
  final TextEditingController _controller = TextEditingController();

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
          Text('name : ${_name}'),
          TextField(
            controller: _controller,
            decoration: InputDecoration(labelText: 'Enter name'),
          ),
          SizedBox(height: 20),
          ElevatedButton(
              onPressed: () {
                setState(() {
                  _name = _controller.text;
                });
              },
              child: Text('Enter')),
        ],
      ),
    );
  }
}

class MemoGetter extends StatefulWidget {
  @override
  _MemoGetterState createState() => _MemoGetterState();
}

class _MemoGetterState extends State<MemoGetter> {
  final TextEditingController _controller2 = TextEditingController();

  @override
  void dispose() {
    _controller2.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          // TextField에 컨트롤러 연결
          Text('memo : ${_memo}'),
          TextField(
            controller: _controller2,
            decoration: InputDecoration(labelText: 'Enter memo'),
          ),
          SizedBox(height: 20),
          ElevatedButton(
              onPressed: () {
                setState(() {
                  _memo = _controller2.text;
                });
              },
              child: Text('Enter')),
        ],
      ),
    );
  }
}

class DateGetter extends StatefulWidget {
  @override
  _DateGetterState createState() => _DateGetterState();
}

class _DateGetterState extends State<DateGetter> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(_selectedDate.toString()),
        ElevatedButton(
            onPressed: () {
              showDatePicker(
                      context: context,
                      firstDate: DateTime.now(),
                      lastDate: DateTime(2050))
                  .then((selectedDate) {
                setState(() {
                  _selectedDate = selectedDate;
                });
              });
            },
            child: Text('pick duedate')),
      ],
    );
  }
}

UpdateToDo(DocumentReference group, List<DocumentReference> worker,
    DocumentReference manager, String name, String? memo) {
  FirebaseFirestore _firestore = FirebaseFirestore.instance;
  DocumentReference docRef = _firestore.collection("todo").doc();
  docRef.set({
    'name': name,
    'group': group,
    'worker': worker,
    'manager': manager,
    'state': 0,
    'duedate': _selectedDate,
    'memo': memo,
  });
  return docRef;
}

UpdateGroup(DocumentReference todo, DocumentReference group) async {
  DocumentSnapshot documentSnapshot = await group.get();
  Map<String, dynamic>? data = documentSnapshot.data() as Map<String, dynamic>?;
  try {
    data!['todo'].add(todo);
  } catch (error) {
    data!['todo'] = [todo];
  }
  group.set(data);
}

UpdateUser(DocumentReference todo, List<DocumentReference> worker) async {
  for (var docref in worker) {
    DocumentSnapshot documentSnapshot = await docref.get();
    Map<String, dynamic>? data =
        documentSnapshot.data() as Map<String, dynamic>?;
    try {
      data!['todo'].add(todo);
    } catch (error) {
      data!['todo'] = [todo];
    }
    docref.set(data);
  }
}

Timegetter(BuildContext context) {
  return ElevatedButton(
      onPressed: () {
        showDatePicker(
                context: context,
                firstDate: DateTime.now(),
                lastDate: DateTime(2050))
            .then((selectedDate) {
          return selectedDate;
        });
      },
      child: Text('pick duedate'));
}
