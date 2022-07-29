import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:my_shop/models/http_exception.dart';

class Product with ChangeNotifier {
  final String id;
  final String title;
  final String description;
  final double price;
  final String imageUrl;
  bool isFavorite;

  Product({
    required this.id,
    required this.title,
    required this.description,
    required this.price,
    required this.imageUrl,
    this.isFavorite = false,
  });

  Future<void> toggleFavoriteStatus(String token, String userId) async {
    try {
      final url = Uri.parse(
          "https://fluttershopapp-c3ffb-default-rtdb.firebaseio.com/userFavourites/$userId/$id.json?auth=$token");
      final response = await http.put(url,
          body: jsonEncode({
            "isFavorite": !isFavorite,
          }));
      if (response.statusCode >= 400) {
        throw HttpException("Failed to add item to favorites");
      }
      isFavorite = !isFavorite;
      notifyListeners();
    } catch (e) {
      rethrow;
    }
  }
}
