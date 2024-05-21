import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:newbie_project_casio/page/my_page.dart';
import 'package:newbie_project_casio/page/server_page.dart';
import 'package:newbie_project_casio/page/task_page.dart';

class MainPage extends StatefulWidget {
  final User user;

  MainPage({Key? key, required this.user}) : super(key: key);
  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  late User user;

  @override
  void initState() {
    super.initState();
    user = widget.user;
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
        length: 3,
        child: Scaffold(
          body: TabBarView(
            children: [
              TaskPage(user: user,),
              ServerPage(user: user,),
              MyPage(user: user),
            ],
          ),
          bottomNavigationBar: TabBar(
              labelColor: Colors.lightGreen,
              unselectedLabelColor: Colors.black38,
              indicatorColor: Colors.lightGreen,
              tabs: [
                Tab(
                  icon: Icon(Icons.home),
                  text: 'home',
                ),
                Tab(
                  icon: Icon(Icons.chat),
                  text: 'chat',
                ),
                Tab(
                  icon: Icon(Icons.people),
                  text: 'my',
                )
              ]),
        ));
  }
}
