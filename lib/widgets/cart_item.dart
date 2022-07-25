import "package:flutter/material.dart";
import 'package:my_shop/providers/cart.dart';
import 'package:provider/provider.dart';

class CartItem extends StatelessWidget {
  final String id;
  final String productId;
  final double price;
  final int quantity;
  final String title;
  const CartItem(
      {required this.id,
      required this.productId,
      required this.price,
      required this.quantity,
      required this.title,
      Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      confirmDismiss: (direction) {
        return showDialog(
            context: context,
            builder: (_) {
              return AlertDialog(
                title: Text("Are you sure?"),
                content:
                    Text("Do you want to remove this item from your cart?"),
                actions: [
                  TextButton(
                      onPressed: () {
                        Navigator.of(_).pop(false);
                      },
                      child: Text("No")),
                  TextButton(
                      onPressed: () {
                        Navigator.of(_).pop(true);
                      },
                      child: Text("Yes")),
                ],
              );
            });
      },
      key: ValueKey(id),
      background: Container(
        color: Theme.of(context).errorColor,
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 4),
        child: const Icon(
          Icons.delete,
          color: Colors.white,
          size: 40,
        ),
      ),
      direction: DismissDirection.endToStart,
      onDismissed: (direction) {
        Provider.of<Cart>(context, listen: false).removeItem(productId);
      },
      child: Card(
          margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 4),
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: ListTile(
              leading: CircleAvatar(
                child: Padding(
                  padding: const EdgeInsets.all(5),
                  child: FittedBox(
                    child: Text("\$$price"),
                  ),
                ),
              ),
              title: Text(title),
              subtitle: Text("Total: \$${(price * quantity)}"),
              trailing: Text("$quantity x"),
            ),
          )),
    );
  }
}
