import "package:flutter/material.dart";
import '../providers/orders.dart';
import '../providers/cart.dart' show Cart;
import 'package:provider/provider.dart';
import '../widgets/cart_item.dart';

class CartScreen extends StatefulWidget {
  static const routeName = "/cart";

  const CartScreen({Key? key}) : super(key: key);

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  var _isLoading = false;
  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<Cart>(context);
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text("Your Cart")),
      body: Column(
        children: [
          Card(
            margin: const EdgeInsets.all(15),
            child: Padding(
                padding: const EdgeInsets.all(8),
                child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Total",
                        style: TextStyle(fontSize: 20),
                      ),
                      const SizedBox(
                        width: 10,
                      ),
                      const Spacer(),
                      Chip(
                        label: Text(
                          "\$${cart.totalAmount.toStringAsFixed(2)}",
                          style: TextStyle(
                              color: Theme.of(context)
                                  .primaryTextTheme
                                  .titleMedium!
                                  .color),
                        ),
                        backgroundColor: Theme.of(context).primaryColor,
                      ),
                      TextButton(
                        onPressed: (cart.totalAmount <= 0 || _isLoading)
                            ? null
                            : () async {
                                setState(() {
                                  _isLoading = true;
                                });
                                try {
                                  await Provider.of<Orders>(
                                    context,
                                    listen: false,
                                  ).addOrder(
                                    cart.items.values.toList(),
                                    cart.totalAmount,
                                  );
                                  cart.clear();
                                  scaffoldMessenger.showSnackBar(const SnackBar(
                                      content: Text("Order placed")));
                                } catch (e) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                          content:
                                              Text("Order failed to add")));
                                }
                                setState(() {
                                  _isLoading = false;
                                });
                              },
                        style: TextButton.styleFrom(
                          onSurface: Colors.black,
                          primary: Colors.purple,
                        ),
                        child: _isLoading
                            ? const CircularProgressIndicator()
                            : const Text("ORDER NOW"),
                      ),
                    ])),
          ),
          const SizedBox(height: 10),
          Expanded(
            child: ListView.builder(
              itemBuilder: (context, index) => CartItem(
                id: cart.items.values.toList()[index].id,
                productId: cart.items.keys.toList()[index],
                title: cart.items.values.toList()[index].title,
                quantity: cart.items.values.toList()[index].quantity,
                price: cart.items.values.toList()[index].price,
              ),
              itemCount: cart.items.length,
            ),
          ),
        ],
      ),
    );
  }
}
