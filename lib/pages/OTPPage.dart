
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firestore_fusion/pages/LoginPage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:loading_btn/loading_btn.dart';
import 'package:pinput/pinput.dart';

import 'DashboardPage.dart';

class OTPPage extends StatefulWidget {
  const OTPPage({super.key});

  static String smsCode = "";

  @override
  State<OTPPage> createState() => _OTPPageState();
}

class _OTPPageState extends State<OTPPage> {

  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {

    final defaultPinTheme = PinTheme(
      width: 56,
      height: 56,
      textStyle: const TextStyle(fontSize: 20, color: Colors.black, fontWeight: FontWeight.bold),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey),
        borderRadius: BorderRadius.circular(20),
      ),
    );

    final focusedPinTheme = defaultPinTheme.copyDecorationWith(
      border: Border.all(color: const Color.fromRGBO(114, 178, 238, 1)),
      borderRadius: BorderRadius.circular(8),
    );

    final submittedPinTheme = defaultPinTheme.copyWith(
      decoration: defaultPinTheme.decoration?.copyWith(
        color: const Color.fromRGBO(234, 239, 243, 1),
      ),
    );

    return Scaffold(
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          centerTitle: true,
          title: const Text("Verify OTP", style: TextStyle( fontWeight: FontWeight.bold, letterSpacing: 5.0 ),),
          actions: const [
            Padding(
              padding: EdgeInsets.only(right: 10.0),
              child: Icon(Icons.verified, size: 30, color: Colors.green,),
            )
          ],
        ),
      body: SizedBox(
        width: MediaQuery.of(context).size.width,
        height: double.maxFinite,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset("assets/images/otp.png", width: 200, height: 200,),
            const Text("Enter OTP\n(One Time Password)\nsent to your phone number", textAlign: TextAlign.center, style: TextStyle( fontSize: 20, color: Colors.black, fontWeight: FontWeight.bold, letterSpacing: 3.0, ),),
            const Divider(thickness: 0.5, color: Colors.black,),
            Text("${LoginPage.ccode}-${LoginPage.phone}", textAlign: TextAlign.center, style: const TextStyle( fontSize: 20, color: Colors.black, fontWeight: FontWeight.bold, letterSpacing: 3.0 ),),
            const Divider(thickness: 0.5, color: Colors.black,),
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: Pinput(
                length: 6,
                defaultPinTheme: defaultPinTheme,
                focusedPinTheme: focusedPinTheme,
                submittedPinTheme: submittedPinTheme,
                onCompleted: (val) {
                  OTPPage.smsCode = val;
                  print(OTPPage.smsCode);
                },
              ),
            ),
            const SizedBox(height: 25,),
            LoadingBtn(
                width: 300,
                height: 50,
                borderRadius: 30,
                color: Colors.black,
                animate: true,
                roundLoadingShape: false,
                loader: const SpinKitThreeBounce(
                  color: Colors.white,
                  size: 15
                ),
                onTap: ((startLoading, stopLoading, btnState) async {
                    try {
                      if (btnState == ButtonState.idle) {
                        startLoading();
                        PhoneAuthCredential credential = PhoneAuthProvider.credential(verificationId: LoginPage.verifyId, smsCode: OTPPage.smsCode);
                        stopLoading();
                        // print("Verification Id: ${LoginPage.verifyId}, SMS Code:  ${OTPPage.smsCode}");
                        await _firebaseAuth.signInWithCredential(credential)
                            .then((value) => Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const DashboardPage())))
                            .onError((error, stackTrace) {
                              startLoading();
                              Fluttertoast.showToast(msg: "Wrong OTP");
                              Future.delayed(const Duration(seconds: 2));
                              print("bla bla blaa error: $error");
                              stopLoading();
                        });
                      }
                    } catch(e) {
                      startLoading();
                      Fluttertoast.showToast(msg: "Wrong OTP");
                      Future.delayed(const Duration(seconds: 2));
                      print("bla bla blaa error: $e");
                      stopLoading();
                    }
                }),
                child: const Text("Verify OTP", style: TextStyle( fontSize: 18, color: Colors.white ),)
            ),
            const SizedBox(height: 20,),
          ],
        ),
      ),
    );
  }
}