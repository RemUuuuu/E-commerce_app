import 'dart:io';
import 'package:flutter/material.dart';
import '../../services/database_helper.dart';
import '../buyer/checkout_page.dart'; // Import file CheckoutPage

class CartPage extends StatefulWidget {
  const CartPage({super.key});

  @override
  _CartPageState createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  List<Map<String, dynamic>> _cartItems = [];
  double _totalPrice = 0.0;

  Future<void> _loadCartItems() async {
    try {
      final db = await DatabaseHelper().database;

      // Menggabungkan data cart dan produk untuk mendapatkan detail item
      final cartItems = await db.rawQuery('''
        SELECT 
          c.id, 
          c.productId, 
          c.quantity, 
          p.name, 
          p.price, 
          p.image, 
          p.stock 
        FROM cart c
        INNER JOIN products p ON c.productId = p.id
      ''');

      setState(() {
        _cartItems = cartItems;
        _totalPrice = _calculateTotalPrice(); // Hitung total harga
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load cart items: $e')),
      );
    }
  }

  double _calculateTotalPrice() {
    return _cartItems.fold<double>(
      0.0,
      (sum, item) => sum + (item['quantity'] * item['price']),
    );
  }

  Future<void> _updateQuantity(int cartId, int newQuantity) async {
    try {
      final db = await DatabaseHelper().database;

      // Update quantity di tabel cart
      await db.update(
        'cart',
        {'quantity': newQuantity},
        where: 'id = ?',
        whereArgs: [cartId],
      );

      // Refresh keranjang setelah update
      await _loadCartItems();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update quantity: $e')),
      );
    }
  }

  void _checkout() async {
    try {
      final db = await DatabaseHelper().database;

      for (var item in _cartItems) {
        // Validasi stok sebelum checkout
        if (item['quantity'] > item['stock']) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                  'Insufficient stock for ${item['name']} (Available: ${item['stock']})'),
            ),
          );
          return;
        }
      }

      // Kurangi stok produk berdasarkan quantity
      for (var item in _cartItems) {
        await db.rawUpdate(
          'UPDATE products SET stock = stock - ? WHERE id = ?',
          [item['quantity'], item['productId']],
        );
      }

      // Navigasi ke CheckoutPage
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => CheckoutPage(
            purchasedItems: _cartItems, // Daftar item yang di-checkout
            totalPrice: _totalPrice, // Total harga
          ),
        ),
      );

      // Kosongkan keranjang setelah checkout
      await db.delete('cart');

      setState(() {
        _cartItems.clear();
        _totalPrice = 0.0;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to checkout: $e')),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    _loadCartItems();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Cart')),
      body: _cartItems.isEmpty
          ? const Center(
              child: Text('Your cart is empty'),
            )
          : Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    itemCount: _cartItems.length,
                    itemBuilder: (context, index) {
                      final item = _cartItems[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(
                            horizontal: 16.0, vertical: 8.0),
                        child: ListTile(
                          leading: item['image'] != null
                              ? Image.file(
                                  File(item['image']),
                                  width: 50,
                                  height: 50,
                                  fit: BoxFit.cover,
                                )
                              : const Icon(Icons.image),
                          title: Text(item['name']),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Price: \$${item['price']}'),
                              Row(
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.remove),
                                    onPressed: () {
                                      if (item['quantity'] > 1) {
                                        _updateQuantity(
                                            item['id'], item['quantity'] - 1);
                                      }
                                    },
                                  ),
                                  Text('${item['quantity']}'),
                                  IconButton(
                                    icon: const Icon(Icons.add),
                                    onPressed: () {
                                      if (item['quantity'] < item['stock']) {
                                        _updateQuantity(
                                            item['id'], item['quantity'] + 1);
                                      } else {
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          SnackBar(
                                            content: Text(
                                                'Cannot add more. Only ${item['stock']} in stock.'),
                                          ),
                                        );
                                      }
                                    },
                                  ),
                                ],
                              ),
                            ],
                          ),
                          trailing: Text(
                            'Total: \$${item['price'] * item['quantity']}',
                            style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.green),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const Divider(),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    'Total Price: \$${_totalPrice.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: ElevatedButton(
                    onPressed: _checkout,
                    child: const Text('Checkout'),
                  ),
                ),
              ],
            ),
    );
  }
}
