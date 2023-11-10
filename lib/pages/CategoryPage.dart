import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class CategoryPage extends StatefulWidget {
  const CategoryPage({super.key});

  @override
  State<CategoryPage> createState() => _CategoryPageState();
}

class _CategoryPageState extends State<CategoryPage> {

  late Stream<QuerySnapshot>  catStream;
  int count = 1;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    var firebase = FirebaseFirestore.instance;
    catStream = firebase.collection("image_slider").snapshots();
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Material(
      child: Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        color: Colors.white,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Divider(thickness: 0.5, color: Colors.grey,),
            const Text("Category", style: TextStyle( fontSize: 25, color: Colors.deepPurple, fontWeight: FontWeight.bold, letterSpacing: 2.0 ),),
            const Divider(thickness: 0.5, color: Colors.grey,),
            StreamBuilder<QuerySnapshot>(
              stream: catStream,
              builder: (context, snapshot) {
                if (snapshot.hasData && snapshot.data!.docs.length > 1) {
                  count = snapshot.data!.docs.length;
                  return SizedBox(
                    width: MediaQuery.of(context).size.width,
                    height: 500,
                    child: GridView.builder(
                      itemCount: count,
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3),
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