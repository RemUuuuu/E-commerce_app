import 'package:flutter/material.dart';
import 'pages/auth/login_page.dart';
import 'pages/auth/register_page.dart';
import 'pages/seller/seller_home_page.dart';
import 'pages/seller/add_product_page.dart';
import 'pages/seller/edit_product_page.dart';
import 'pages/buyer/buyer_home_page.dart';
import 'pages/buyer/product_detail_page.dart';
import 'pages/buyer/cart_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'E-Commerce App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      initialRoute: '/',
      onGenerateRoute: (settings) {
        switch (settings.name) {
          case '/':
            return MaterialPageRoute(builder: (_) => const LoginPage());
          case '/register':
            return MaterialPageRoute(builder: (_) => const RegisterPage());
          case '/sellerHome':
            return MaterialPageRoute(builder: (_) => const SellerHomePage());
          case '/addProduct':
            return MaterialPageRoute(builder: (_) => const AddProductPage());
          case '/editProduct':
            final product = settings.arguments as Map<String, dynamic>;
            return MaterialPageRoute(
              builder: (_) => EditProductPage(product: product),
            );
          case '/buyerHome':
            return MaterialPageRoute(builder: (_) => const BuyerHomePage());
          case '/productDetail':
            final product =
                Map<String, dynamic>.from(settings.arguments as Map);
            return MaterialPageRoute(
              builder: (_) => ProductDetailPage(product: product),
            );
          case '/cart':
            return MaterialPageRoute(builder: (_) => const CartPage());
          default:
            return MaterialPageRoute(builder: (_) => const LoginPage());
        }
      },
    );
  }
}
