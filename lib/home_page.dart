import 'package:flutter/material.dart';
import 'package:mess_mate/global_complaints.dart';
import 'package:mess_mate/my_complaints.dart';
import 'package:mess_mate/raise_complaints.dart';
import 'package:mess_mate/status_page.dart';
import 'package:stylish_bottom_bar/stylish_bottom_bar.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  List<Widget> pages = [GlobalComplaints(), StatusPage(), MyComplaints()];
  int selected = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: pages[selected],

      floatingActionButton: FloatingActionButton(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)),
        onPressed: (){
          Navigator.of(context).push(MaterialPageRoute(builder: (context) => const RaiseComplaints()));
        },
        child: Icon(Icons.add),
      ),

      floatingActionButtonLocation: FloatingActionButtonLocation.endDocked,

      bottomNavigationBar: StylishBottomBar(
        option: AnimatedBarOptions(
          iconStyle: IconStyle.simple
        ),
        items: [
          BottomBarItem(
            icon: Icon(Icons.home),
            title: Text('Home')
          ),
          BottomBarItem(
            icon: Icon(Icons.pie_chart),
            title: Text('Status')
          ),
          BottomBarItem(
            icon: Icon(Icons.person),
            title: Text('My Complaints')
          ),
        ],
        currentIndex: selected,
        onTap: (value) {
          setState(() {
            selected = value;
          });
        },
        fabLocation: StylishBarFabLocation.end,
        hasNotch: true,
        notchStyle: NotchStyle.circle,
      ),
    );
  }
}