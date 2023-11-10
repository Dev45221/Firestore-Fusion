import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_database/ui/firebase_list.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:loading_btn/loading_btn.dart';
import 'package:platform_device_id_v3/platform_device_id.dart';

import 'DashboardPage.dart';
import 'LoginPage.dart';

class StartPage extends StatefulWidget {
  const StartPage({super.key});

  static String deviceId = "";
  static Query fetchQuery = FirebaseDatabase.instance.ref().child("Data");

  @override
  State<StartPage> createState() => _StartPageState();
}

class _StartPageState extends State<StartPage> {

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getDeviceId();
  }

  getDeviceId() async {
    StartPage.deviceId = await PlatformDeviceId.getDeviceId as String;
    print("Device Id: ${StartPage.deviceId}");
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0.0,
        actions: [
          TextButton(
              onPressed: () {
                Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const DashboardPage()));
              },
              child: const Text("SKIP", style: TextStyle( fontSize: 20, color: Colors.black54, decoration: TextDecoration.underline, ),)
          )
        ],
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset('assets/images/bg.png', fit: BoxFit.cover,),
          const SizedBox(height: 20,),
          LoadingBtn(
              width: 300,
              height: 50,
              borderRadius: 30.0,
              color: Colors.black,
              loader: const SpinKitThreeBounce(
                color: Colors.white,
                size: 15,
              ),
              onTap:  ((startLoading, stopLoading, btnState) async {
                if (btnState == ButtonState.idle) {
                  startLoading();
                  await Future.delayed(const Duration(seconds: 3));
                  FirebaseList(
                    query: StartPage.fetchQuery,
                    onValue: (snapshot) {
                      if (snapshot.exists && snapshot.hasChild(StartPage.deviceId)) {
                        stopLoading();
                        Navigator.push(context, MaterialPageRoute(builder: (context) => const DashboardPage()));
                      } else {
                        stopLoading();
                        Navigator.push(context, MaterialPageRoute(builder: (context) => const LoginPage()));
                      }
                    },
                  );
                }
              }),
              child: const Text("Get Started", style: TextStyle( fontSize: 20, color: Colors.white, fontWeight: FontWeight.bold, letterSpacing: 2.0 ),)
          )
        ],
      ),
    );
  }
}
