import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:newbie_project_casio/firebase_options.dart';
import 'package:newbie_project_casio/page/my_page.dart';
import 'package:newbie_project_casio/page/server_page.dart';
import 'package:newbie_project_casio/page/test_page.dart';

void main() async {
  runApp(const MainApp());

  // firebase 초기화
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: MainPage(),
    );
  }
}

class MainPage extends StatefulWidget {
  const MainPage({Key? key}) : super(key: key);

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  // 메인 위젯
  @override
  Widget build(BuildContext context) {
    return const DefaultTabController(
        length: 3,
        child: Scaffold(
          body: TabBarView(
            children: [
              TestPage(),
              ServerPage(),
              MyPage(),
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
