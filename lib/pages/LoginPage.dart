import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firestore_fusion/pages/StartPage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:loading_btn/loading_btn.dart';
import 'package:platform_device_id_v3/platform_device_id.dart';

import 'OTPPage.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  static var name = "", ccode = "", phone = "", verifyId = "", contact = "";

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {

  final TextEditingController countryCodeController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController nameController = TextEditingController();

  late DatabaseReference _databaseReference;
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _databaseReference = FirebaseDatabase.instance.ref().child("Data");
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      extendBodyBehindAppBar: false,
      appBar: AppBar(
        centerTitle: true,
        title: const Text("Login", style: TextStyle( fontWeight: FontWeight.bold, letterSpacing: 5.0 ),),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 10.0),
            child: Icon(Icons.login, size: 30,),
          )
        ],
      ),
      body: SizedBox(
        width: MediaQuery.of(context).size.width,
        height: double.maxFinite,
        child: Stack(
          alignment: Alignment.topCenter,
          children: [
            Image.asset("assets/images/bg.png", fit: BoxFit.cover,),
            Container(
              color: Colors.white.withOpacity(0.8),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 50,),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: TextFormField(
                      controller: nameController,
                      keyboardType: TextInputType.text,
                      decoration: InputDecoration(
                          labelText: "Enter name",
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(30.0),
                          ),
                          filled: true,
                          fillColor: Colors.white
                      ),
                      onChanged: (val) {
                        LoginPage.name = val;
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(right: 8.0, left: 8.0),
                    child: Row(
                      children: [
                        Expanded(
                          flex: 2,
                          child: TextFormField(
                            maxLength: 3,
                            controller: countryCodeController,
                            keyboardType: TextInputType.phone,
                            decoration: InputDecoration(
                              labelText: "C-Code",
                              prefixIcon: const Icon(Icons.call, color: Colors.black,),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(30.0),
                              ),
                              filled: true,
                              fillColor: Colors.white,
                            ),
                            onChanged: (val) {
                              LoginPage.ccode = val;
                            },
                          ),
                        ),
                        const SizedBox(width: 8.0,),
                        Expanded(
                          flex: 3,
                          child: TextFormField(
                            maxLength: 10,
                            controller: phoneController,
                            keyboardType: TextInputType.phone,
                            decoration: InputDecoration(
                                labelText: "Phone Number",
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(30.0),
                                ),
                                filled: true,
                                fillColor: Colors.white
                            ),
                            onChanged: (val) {
                              LoginPage.phone = val;
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 80,),
                  LoadingBtn(
                      width: 300,
                      height: 50,
                      animate: true,
                      borderRadius: 30,
                      color: Colors.black,
                      roundLoadingShape: false,
                      loader: const SpinKitThreeBounce(
                        color: Colors.white,
                        size: 15,
                      ),
                      onTap: ((startLoading, stopLoading, btnState) async {
                        var name = nameController.text.toString();
                        var ccode = countryCodeController.text.toString();
                        var num = phoneController.text.toString();
                        LoginPage.contact = ccode+num;
                        Map<String, String> data = {
                          'Name': name.toString(),
                          'Contact': LoginPage.contact.toString()
                        };
                        if (btnState == ButtonState.idle && countryCodeController.text.isNotEmpty && phoneController.text.isNotEmpty && phoneController.text.length == 10) {
                          startLoading();
                          print("Validate");
                          // Navigator.push(context, MaterialPageRoute(builder: (context) => const OTPPage()));
                          try {
                            await _databaseReference.child(StartPage.deviceId).child(LoginPage.contact).set(data).
                            then((value) async {
                              await FirebaseAuth.instance.verifyPhoneNumber(
                                  phoneNumber: LoginPage.contact,
                                  verificationFailed: (FirebaseAuthException e) {},
                                  verificationCompleted: (PhoneAuthCredential credential) async {
                                    // await _firebaseAuth.signInWithCredential(credential);
                                  },
                                  codeSent: (String verificationId, int? resendToken) {
                                    stopLoading();
                                    print(LoginPage.ccode+LoginPage.phone);
                                    LoginPage.verifyId = verificationId;
                                    Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const OTPPage()));
                                  },
                                  codeAutoRetrievalTimeout: (String verificationId) {}
                              ).onError((error, stackTrace) {
                                Fluttertoast.showToast(msg: "Can't sent OTP\n$error");
                              });
                            }).onError((error, stackTrace) {
                              Fluttertoast.showToast(msg: "Can't register\n$error");
                            });
                          } catch(e) {
                            print("EEErrorr $e");
                          }
                        } else {
                          stopLoading();
                          Fluttertoast.showToast(msg: "Fields can't be empty");
                          print("Not Validate");
                        }
                      }),
                      child: const Text("Verify Number", style: TextStyle( fontSize: 18, color: Colors.white ),)
                  ),
                  const SizedBox(height: 20,),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}