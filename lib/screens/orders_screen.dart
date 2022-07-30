import 'package:flutter/material.dart';
import '../widgets/app_drawer.dart';
import '../providers/orders.dart' show Orders;
import 'package:provider/provider.dart';
import "../widgets/order_item.dart";

class OrdersScreen extends StatefulWidget {
  static const routeName = "/orders";
  const OrdersScreen({Key? key}) : super(key: key);

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  @override
  void initState() {
    // Future.delayed(Duration.zero).then((value) async {
    //   setState(() {
    //     _isLoading = true;
    //   });
    //   await Provider.of<Orders>(context, listen: false).fetchAndSetOrders();
    //   setState(() {
    //     _isLoading = false;
    //   });
    // });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text("Your Orders"),
        ),
        drawer: const AppDrawer(),
        body: FutureBuilder(
          future:
              Provider.of<Orders>(context, listen: false).fetchAndSetOrders(),
          builder: (ctx, dataSnapshot) {
            if (dataSnapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            } else {
              if (dataSnapshot.error != null) {
                return const Center(
                  child: Text("An error occured"),
                );
              } else {
                return Consumer<Orders>(builder: ((context, orders, child) {
                  return orders.orders.isEmpty
                      ? const Center(
                          child: Text("No orders yet"),
                        )
                      : ListView.builder(
                          itemBuilder: (context, index) => OrderItem(
                            order: orders.orders[index],
                          ),
                          itemCount: orders.orders.length,
                        );
                }));
              }
            }
          },
        ));
  }
}
