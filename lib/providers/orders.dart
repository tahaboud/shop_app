import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';
import './products.dart';
import './cart.dart';
import 'package:http/http.dart' as http;

class OrderItem {
  final String id;
  final double amount;
  final List<CartItem> products;
  final DateTime dateTime;

  OrderItem({
    required this.id,
    required this.amount,
    required this.products,
    required this.dateTime,
  });
}

class Orders with ChangeNotifier {
  List<OrderItem> _orders = [];

  List<OrderItem> get orders {
    return [..._orders];
  }

  Future<void> fetchAndSetOrders() async {
    final url = Uri.parse(
        "https://fluttershopapp-c3ffb-default-rtdb.firebaseio.com/orders.json");
    try {
      final response = await http.get(url);
      final extractedData = jsonDecode(response.body) as Map<String, dynamic>;
      if (extractedData == null) return;
      final List<OrderItem> loadedOrders = [];
      final List<CartItem> orderProducts = [];
      extractedData.forEach((key, value) {
        value["products"].forEach((product) {
          orderProducts.add(CartItem(
            id: product["id"],
            title: product["title"],
            quantity: product["quantity"],
            price: product["price"],
          ));
        });
        loadedOrders.add(OrderItem(
          id: key,
          amount: value["amount"],
          products: orderProducts,
          dateTime: DateTime.parse(value["dateTime"]),
        ));
        loadedOrders.sort(((a, b) => b.dateTime.microsecondsSinceEpoch
            .compareTo(a.dateTime.microsecondsSinceEpoch)));
        _orders = loadedOrders;
        notifyListeners();
      });
    } catch (e) {
      rethrow;
    }
  }

  Future<void> addOrder(List<CartItem> cartProducts, double total) async {
    final timeStamp = DateTime.now();
    final url = Uri.parse(
        "https://fluttershopapp-c3ffb-default-rtdb.firebaseio.com/orders.json");
    try {
      final response = await http.post(url,
          body: jsonEncode({
            "amount": total,
            "products": cartProducts,
            "dateTime": timeStamp.toIso8601String(),
          }));
      _orders.insert(
        0,
        OrderItem(
          id: jsonDecode(response.body)["name"],
          amount: total,
          products: cartProducts as List<CartItem>,
          dateTime: timeStamp,
        ),
      );
      notifyListeners();
    } catch (e) {
      rethrow;
    }
  }
}
