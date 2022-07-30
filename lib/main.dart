import 'package:flutter/material.dart';
import '../helpers/custom_routes.dart';
import './screens/splash_screen.dart';
import './providers/auth.dart';
import 'screens/auth_screen.dart';
import '../screens/edit_product_screen.dart';
import './screens/user_products_screen.dart';
import './screens/orders_screen.dart';
import './providers/orders.dart';
import './screens/cart_screen.dart';
import './providers/cart.dart';
import './screens/product_detail_screen.dart';
import 'package:provider/provider.dart';

import './screens/products_overview_screen.dart';

import './providers/products.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (context) => Auth()),
          ChangeNotifierProxyProvider<Auth, Products>(
              create: (ctx) => Products(null, null, []),
              update: (ctx, auth, previousProducts) => Products(
                  auth.token,
                  auth.userId,
                  previousProducts == null ? [] : previousProducts.items)),
          ChangeNotifierProxyProvider<Auth, Orders>(
              create: (ctx) => Orders(null, [], null),
              update: (ctx, auth, previousOrders) => Orders(
                  auth.token,
                  previousOrders == null ? [] : previousOrders.orders,
                  auth.userId)),
          ChangeNotifierProvider(create: (context) => Cart()),
        ],
        child: Consumer<Auth>(
            builder: (ctx, auth, child) => MaterialApp(
                  title: 'My Shop',
                  theme: ThemeData(
                    pageTransitionsTheme: PageTransitionsTheme(builders: {
                      TargetPlatform.android: CustomPageTransitionBuilder(),
                      TargetPlatform.iOS: CustomPageTransitionBuilder(),
                    }),
                    primarySwatch: Colors.purple,
                    fontFamily: "Lato",
                  ).copyWith(
                    colorScheme: ThemeData()
                        .colorScheme
                        .copyWith(secondary: Colors.deepOrange),
                  ),
                  home: auth.isAuth
                      ? const ProductsOverviewScreen()
                      : FutureBuilder(
                          builder: ((context, snapshot) =>
                              snapshot.connectionState ==
                                      ConnectionState.waiting
                                  ? const SplashScreen()
                                  : const AuthScreen()),
                          future: auth.tryAutoLogin(),
                        ),
                  routes: {
                    ProductDetailScreen.routeName: (context) =>
                        const ProductDetailScreen(),
                    CartScreen.routeName: (context) => const CartScreen(),
                    OrdersScreen.routeName: (context) => const OrdersScreen(),
                    UserProductsScreen.routeName: (context) =>
                        const UserProductsScreen(),
                    EditProductScreen.routeName: (context) =>
                        const EditProductScreen(),
                  },
                )));
  }
}
