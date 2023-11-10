import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:firestore_fusion/pages/CategoryPage.dart';
import 'package:firestore_fusion/pages/HomePage.dart';
import 'package:flutter/material.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {

  int index = 0;

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      appBar: AppBar(
        title: const Text("HAIR SALON", style: TextStyle( letterSpacing: 5.0, fontWeight: FontWeight.bold ),),
        centerTitle: true,
        elevation: 10.0,
        actions: [ Padding(
          padding: const EdgeInsets.only(right: 20.0),
          child: Image.asset("assets/images/icon.png", width: 40, height: 40,),
        ), ]
      ),
      body: Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        color: Colors.grey.shade200,
        child: getSelectedWidget(index: index),
      ),
      bottomNavigationBar: CurvedNavigationBar(
          height: 60,
          index: index,
          color: Colors.black54,
          backgroundColor: Colors.black54,
          buttonBackgroundColor: Colors.red,
          items: const [
            Icon(Icons.home, size: 50, color: Colors.white,),
            Icon(Icons.category, size: 50, color: Colors.white,)
          ],
        onTap: (selectedIndex) {
            setState(() {
              index = selectedIndex;
            });
        },
      ),
    );
  }

  Widget getSelectedWidget({required int index}) {
    Widget widget;
    switch(index) {
      case 0:
        widget = const HomePage();
        break;
      case 1:
        widget = const CategoryPage();
        break;
      default:
        widget = const HomePage();
        break;
    }
    return widget;
  }
}