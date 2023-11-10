import 'package:carousel_slider/carousel_slider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_database/firebase_database.dart' as realtime;
import 'package:firebase_database/ui/firebase_list.dart';
import 'package:firestore_fusion/pages/CategoryPage.dart';
import 'package:firestore_fusion/pages/StartPage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';


class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  var dateTime = DateTime.now();
  String greet = "Good Morning", nameData = "Dear", contactData = "";

  late Stream<QuerySnapshot> discountStream, catStream;
  int currentSliderIndex = 0;
  final CarouselController _carouselController = CarouselController();
  final realtime.Query _query = realtime.FirebaseDatabase.instance.ref().child("Data");

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    var firebase = FirebaseFirestore.instance;
    discountStream = firebase.collection("discount_slider").snapshots();
    catStream = firebase.collection("image_slider").snapshots();

    FirebaseList(
      query: _query,
      onValue: (snapshot) {
        if (snapshot.exists && snapshot.hasChild(StartPage.deviceId)) {
          contactData = snapshot.child(StartPage.deviceId).value.toString();
          nameData = snapshot.child(StartPage.deviceId).child(contactData.substring(1, 14)).child("Name").value.toString();
          print(contactData);
          print(nameData);
        }
      },
    );
    setState(() {
      if (dateTime.hour >= 12 && dateTime.hour <= 15) {
        greet = "Good Afternoon";
      } else if (dateTime.hour >= 16 && dateTime.hour <= 20) {
        greet = "Good Evening";
      } else if (dateTime.hour >= 21 && dateTime.hour < 24) {
        greet = "Good Night";
      }
    });
  }

  int indicatorCount = 1;

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Padding(
      padding: const EdgeInsets.all(5.0),
      child: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 15.0, top: 10.0),
              child: Text(greet, textAlign: TextAlign.left, style: const TextStyle( fontSize: 18, letterSpacing: 2.0, ),),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 15.0),
              child: Text(nameData, textAlign: TextAlign.left, style: const TextStyle( fontSize: 20, letterSpacing: 2.0, fontWeight: FontWeight.bold, color: Colors.deepPurple ),),
            ),
            const Divider(thickness: 0.5, color: Colors.grey,),
            const SizedBox(height: 10,),
            Container(
              width: MediaQuery.of(context).size.width,
              height: 250,
              color: Colors.transparent,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  StreamBuilder<QuerySnapshot>(
                    stream: discountStream,
                    builder: (context, snapshot) {
                      if (snapshot.hasData && snapshot.data!.docs.length > 1) {
                        indicatorCount = snapshot.data!.docs.length;
                        return CarouselSlider.builder(
                          carouselController: _carouselController,
                          itemCount: snapshot.data!.docs.length,
                          itemBuilder: (context, index, realIndex) {
                            DocumentSnapshot sliderImage = snapshot.data!.docs[index];
                            return ClipRRect(
                              borderRadius: BorderRadius.circular(20.0),
                              child: Image.network(sliderImage['image'], fit: BoxFit.cover,)
                            );
                          },
                          options: CarouselOptions(
                            autoPlay: true,
                            enableInfiniteScroll: false,
                            enlargeCenterPage: true,
                            onPageChanged: (index, reason) {
                              setState(() {
                                currentSliderIndex = index;
                              });
                            },
                          ),
                        );
                      } else {
                        return const Center(child: SpinKitPianoWave(color: Colors.deepPurple, size: 40,));
                      }
                    },
                  ),
                  AnimatedSmoothIndicator(
                      activeIndex: currentSliderIndex,
                      count: indicatorCount,
                      effect: ExpandingDotsEffect(
                        expansionFactor: 2.0,
                        dotColor: Colors.grey,
                        activeDotColor: Colors.red.shade300
                      ),
                  )
                ],
              ),
            ),
            const Divider(thickness: 0.5, color: Colors.grey,),
            const SizedBox(height: 10,),
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("Category", style: TextStyle( fontSize: 20, color: Colors.deepPurple.shade300, letterSpacing: 3.0 ),),
                  TextButton(
                      onPressed: () {
                        Navigator.push(context, MaterialPageRoute(builder: (context) => const CategoryPage()));
                      },
                      child: Text("View All", style: TextStyle( fontSize: 18, color: Colors.deepPurple.shade300, letterSpacing: 2.0 ),),
                  ),
                ],
              ),
            ),
            StreamBuilder<QuerySnapshot>(
              stream: catStream,
              builder: (context, snapshot) {
                if (snapshot.hasData && snapshot.data!.docs.length > 1) {
                  return SizedBox(
                    width: MediaQuery.of(context).size.width,
                    height: 200,
                    child: ListView.builder(
                        itemCount: 3,
                        itemExtent: 140,
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.all(10.0),
                        shrinkWrap: true,
                        itemBuilder: (context, index) {
                          DocumentSnapshot catImage = snapshot.data!.docs[index];
                          return Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.deepPurple.shade100,
                                borderRadius: BorderRadius.circular(20.0),
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  CircleAvatar(
                                      radius: 40,
                                      child: Image.network(catImage['image'], fit: BoxFit.cover, width: 60, height: 60,)
                                  ),
                                  const SizedBox(height: 10,),
                                  Text(catImage['cat'], style: const TextStyle( fontSize: 16, color: Colors.deepPurple, fontWeight: FontWeight.bold),)
                                ],
                              ),
                            ),
                          );
                        },
                    ),
                  );
                } else {
                  return const Center(child: SpinKitPianoWave(color: Colors.deepPurple, size: 40,));
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}