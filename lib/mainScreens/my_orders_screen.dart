import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:user_app/assistant_methods/assistant_methods.dart';
import 'package:user_app/global/global.dart';
import 'package:user_app/widgets/order_card.dart';
import 'package:user_app/widgets/progress_bar.dart';
import 'package:user_app/widgets/simple_Appbar.dart';
import 'package:user_app/mainScreens/payment_screen.dart'; // Import Payment Screen

class MyOrdersScreen extends StatefulWidget {
  const MyOrdersScreen({super.key});

  @override
  State<MyOrdersScreen> createState() => _MyOrdersScreenState();
}

class _MyOrdersScreenState extends State<MyOrdersScreen> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: SimpleAppBar(
          title: "My Orders",
        ),
        body: Column(
          children: [
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection("users")
                    .doc(sharedPreferences?.getString("uid"))
                    .collection("orders")
                    .where("status", isEqualTo: "normal")
                    .orderBy("orderTime", descending: true)
                    .snapshots(),
                builder: (c, snapshot) {
                  return snapshot.hasData
                      ? ListView.builder(
                    itemCount: snapshot.data?.docs.length,
                    itemBuilder: (c, index) {
                      return FutureBuilder<QuerySnapshot>(
                        future: FirebaseFirestore.instance
                            .collection("items")
                            .where(
                          "itemId",
                          whereIn: separateOrderItemIds(
                            (snapshot.data?.docs[index].data()
                            as Map<String, dynamic>)["productIds"],
                          ),
                        )
                            .where(
                          "orderedBy",
                          whereIn: (snapshot.data?.docs[index].data()
                          as Map<String, dynamic>)["uid"],
                        )
                            .orderBy("publishedDate", descending: true)
                            .get(),
                        builder: (c, snap) {
                          return snap.hasData
                              ? OrderCard(
                            itemCount: snap.data?.docs.length,
                            data: snap.data?.docs,
                            orderId: snapshot.data?.docs[index].id,
                            seperateQuantitiesList:
                            separateOrderItemQuantities(
                              (snapshot.data?.docs[index].data()
                              as Map<String, dynamic>)["productIds"],
                            ),
                          )
                              : Center(
                            child: circularProgress(),
                          );
                        },
                      );
                    },
                  )
                      : Center(
                    child: circularProgress(),
                  );
                },
              ),
            ),
            // ✅ Added Payment Button Below the Orders List
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const PaymentScreen()),
                  );
                },
                style: ElevatedButton.styleFrom(
                  primary: Colors.green, // Payment Button Color
                  padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                ),
                child: const Text(
                  "Proceed to Payment",
                  style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
