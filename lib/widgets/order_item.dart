import 'dart:math';
import "package:flutter/material.dart";

import 'package:intl/intl.dart';
import '../providers/orders.dart' as ord;

class OrderItem extends StatefulWidget {
  final ord.OrderItem order;
  const OrderItem({required this.order, Key? key}) : super(key: key);

  @override
  State<OrderItem> createState() => _OrderItemState();
}

class _OrderItemState extends State<OrderItem> {
  var _expanded = false;
  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(10),
      child: Column(
        children: [
          ListTile(
            title: Text(
              "\$${widget.order.amount}",
            ),
            subtitle: Text(
              DateFormat("dd MM yyyy hh:mm").format(widget.order.dateTime),
            ),
            trailing: IconButton(
              icon: Icon(_expanded ? Icons.expand_less : Icons.expand_more),
              onPressed: () {
                setState(() {
                  _expanded = !_expanded;
                });
              },
            ),
          ),
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeIn,
            constraints: BoxConstraints(
              maxHeight: _expanded ? 100.0 : 0,
              minHeight: _expanded ? 100 : 0,
            ),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 4),
              height: min(widget.order.products.length * 20.0 + 10, 100.0),
              child: ListView.builder(
                itemBuilder: (context, index) => Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      widget.order.products[index].title,
                      style: const TextStyle(
                          fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      "${widget.order.products[index].quantity}x \$${widget.order.products[index].price}",
                      style: const TextStyle(fontSize: 18, color: Colors.grey),
                    ),
                  ],
                ),
                itemCount: widget.order.products.length,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
