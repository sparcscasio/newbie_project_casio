import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_ui_auth/firebase_ui_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:newbie_project_casio/model/group_model.dart';

int state = 0;
String groupName = '';

class MyPage extends StatefulWidget {
  final User user;
  MyPage({Key? key, required this.user}) : super(key: key);

  @override
  State<MyPage> createState() => _MyPageState();
}

class _MyPageState extends State<MyPage> {
  late User user;

  @override
  void initState() {
    super.initState();
    user = widget.user;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        height: MediaQuery.of(context).size.height,
        child: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          physics: AlwaysScrollableScrollPhysics(),
          child: Column(
            children: [
              SizedBox(
                height: 20,
              ),
              Text('email : ${user.email}'),
              SizedBox(
                height: 20,
              ),
              Container(
                width: 100,
                height: 30,
                child: Center(
                    child: Text(
                  '소속 그룹',
                  style: TextStyle(color: Colors.white, fontSize: 15),
                )),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  color: Colors.green,
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(10.0),
                child: FutureBuilder(
                    future: FirebaseFirestore.instance
                        .collection('user')
                        .doc(user.uid)
                        .get(),
                    builder: (BuildContext context,
                        AsyncSnapshot<DocumentSnapshot> snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return CircularProgressIndicator(); // 데이터를 기다리는 동안 로딩 표시
                      } else {
                        Map<String, dynamic> data =
                            snapshot.data!.data() as Map<String, dynamic>;
                        return Container(
                          height: 100,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: Colors.lightGreen),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(20.0),
                            child: SingleChildScrollView(
                              physics: AlwaysScrollableScrollPhysics(),
                              scrollDirection: Axis.vertical,
                              child: Container(
                                constraints: BoxConstraints(
                                  maxHeight: MediaQuery.of(context).size.height,
                                ),
                                child: ListView.builder(
                                    itemCount: data['group'].length,
                                    itemBuilder: (ctx, index) {
                                      return FutureBuilder(
                                          future: getGroupModel(
                                              data['group'][index]),
                                          builder: (_context, _snapshot) {
                                            GroupModel? groupModel =
                                                _snapshot.data;
                                            if (_snapshot.connectionState ==
                                                ConnectionState.waiting) {
                                              return const CircularProgressIndicator(); // 데이터가 로드될 때까지 로딩 표시
                                            } else {
                                              return Container(
                                                child: Text(groupModel!.name!),
                                              );
                                            }
                                          });
                                    }),
                              ),
                            ),
                          ),
                        );
                      }
                    }),
              ),
              TextButton(
                  onPressed: () {
                    state = 0;
                    showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            contentPadding: EdgeInsets.all(8.0),
                            title: Text('Add group'),
                            content: Container(
                                height: 200, child: AddGroup(user, context)),
                          );
                        });
                  },
                  child: Text(
                    'add new group',
                    style: TextStyle(color: Colors.lightGreen),
                  )),
              SignOutButton(
                variant: ButtonVariant.filled,
              ),
            ],
          ),
        ),
      ),
      appBar: AppBar(
        backgroundColor: Colors.lightGreen,
        title: Text(
          'Group Task Manager',
          style: TextStyle(color: Colors.white),
        ),
      ),
    );
  }
}

Widget AddGroup(User user, BuildContext context) {
  final TextEditingController _controller = TextEditingController();

  return SingleChildScrollView(
    scrollDirection: Axis.vertical,
    physics: AlwaysScrollableScrollPhysics(),
    child: Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height, // 최대 높이 설정
      ),
      child: Column(
        children: [
          TextField(
            controller: _controller,
            decoration: InputDecoration(
              labelText: 'Enter name',
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
          SizedBox(
            height: 20,
          ),
          ElevatedButton(
            onPressed: () async {
              // 컨트롤러를 통해 입력된 텍스트 가져오기
              final code = _controller.text;
              int _state = await UpdateUserInfo(code, user);
              if (_state == 1) {
                showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return Dialog(
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text('${groupName}에 추가되었습니다.'),
                        ),
                      );
                    });
                Future.delayed(Duration(seconds: 2), () {
                  Navigator.pop(context);
                  Navigator.of(context, rootNavigator: true).pop();
                });
              } else {
                if (_state == -1) {
                  showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return Dialog(
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text('잘못된 그룹 코드입니다\n코드를 다시 확인해주세요.'),
                          ),
                        );
                      });
                  Future.delayed(Duration(seconds: 2), () {
                    Navigator.pop(context);
                    Navigator.of(context, rootNavigator: true).pop();
                  });
                } else {
                  if (_state == 2) {
                    showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return Dialog(
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text('이미 ${groupName}에 속해 있습니다.'),
                            ),
                          );
                        });
                    Future.delayed(Duration(seconds: 2), () {
                      Navigator.pop(context);
                      Navigator.of(context, rootNavigator: true).pop();
                    });
                  }
                }
              }
            },
            child: Text(
              'Enter',
              style: TextStyle(color: Colors.white),
            ),
            style: ButtonStyle(
                backgroundColor: MaterialStatePropertyAll(Colors.lightGreen)),
          ),
        ],
      ),
    ),
  );
}

Future<int> UpdateUserInfo(String code, User user) async {
  DocumentReference docRef =
      FirebaseFirestore.instance.collection('group').doc(code);
  DocumentSnapshot doc = await docRef.get();

  DocumentReference userRef =
      FirebaseFirestore.instance.collection('user').doc(user.uid);

  if (doc.exists) {
    DocumentSnapshot userSnapshot = await userRef.get();
    Map<String, dynamic>? data = userSnapshot.data() as Map<String, dynamic>?;
    if (data != null) {
      try {
        if (!data['group'].contains(docRef)) {
          data['group'].add(docRef);
        }
      } catch (error) {
        data['group'] = [docRef];
      }
      await userRef.set(data);
    }
    Map<String, dynamic>? groupData = doc.data() as Map<String, dynamic>?;
    if (groupData != null) {
      groupName = groupData['name'];
      try {
        if (!groupData['user'].contains(userRef)) {
          state = 1;
          groupData['user'].add(userRef);
        } else {
          state = 2;
        }
      } catch (error) {
        groupData['user'] = [userRef];
      }
      await userRef.set(data);
      await docRef.set(groupData);
    }
  } else {
    state = -1;
  }

  return state;
}

Future<GroupModel> getGroupModel(DocumentReference docRef) async {
  GroupModel groupModel = GroupModel();
  DocumentSnapshot snapshot = await docRef.get();
  await groupModel
      .fromSnapShot(snapshot as DocumentSnapshot<Map<String, dynamic>>);
  return groupModel;
}

Widget backup(User user, BuildContext context) {
  return Column(
    children: [
      SignOutButton(),
      Text('email : ${user.email}'),
      TextButton(
          onPressed: () {
            state = 0;
            showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: Text('Add group'),
                    content: AddGroup(user, context),
                  );
                });
          },
          child: Text('add new group')),
    ],
  );
}
