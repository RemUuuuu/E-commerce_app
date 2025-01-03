import 'dart:io';
import 'package:flutter/material.dart';
import '../../services/database_helper.dart';

class ProductDetailPage extends StatelessWidget {
  final Map<String, dynamic> product;

  const ProductDetailPage({super.key, required this.product});

  Future<void> _addToCart(BuildContext context) async {
    try {
      final db = await DatabaseHelper().database;

      // Validasi stok
      if (product['stock'] <= 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Stock not available!')),
        );
        return;
      }

      // Periksa apakah produk sudah ada di keranjang
      final existingCartItem = await db.query(
        'cart',
        where: 'productId = ?',
        whereArgs: [product['id']],
      );

      if (existingCartItem.isNotEmpty) {
        // Tambahkan quantity jika produk sudah ada
        final currentQuantity =
            (existingCartItem.first['quantity'] as int?) ?? 0;
        await db.update(
          'cart',
          {'quantity': currentQuantity + 1},
          where: 'productId = ?',
          whereArgs: [product['id']],
        );
      } else {
        // Tambahkan produk ke keranjang jika belum ada
        await db.insert(
          'cart',
          {'productId': product['id'], 'quantity': 1},
        );
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Product added to cart successfully!')),
      );

      Navigator.pushNamed(context, '/cart');
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to add to cart: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(product['name'])),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Gambar produk
            product['image'] != null
                ? ClipRRect(
                    borderRadius: BorderRadius.vertical(
                      bottom: Radius.circular(16),
                    ),
                    child: Image.file(
                      File(product['image']),
                      height: 250,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          height: 250,
                          color: Colors.grey,
                          child: const Center(
                            child: Text('No Image Available'),
                          ),
                        );
                      },
                    ),
                  )
                : Container(
                    height: 250,
                    color: Colors.grey.shade200,
                    child: const Center(
                      child: Icon(Icons.image, size: 50, color: Colors.grey),
                    ),
                  ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Nama produk
                  Text(
                    product['name'],
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  // Harga produk
                  Text(
                    '\$${product['price']}',
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
                  ),
                  const SizedBox(height: 8),
                  // Stok produk
                  Text(
                    'Stock: ${product['stock']}',
                    style: TextStyle(
                      fontSize: 18,
                      color: product['stock'] > 0
                          ? Colors.black
                          : Colors.redAccent,
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Deskripsi produk
                  const Text(
                    'Description',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    product['description'],
                    style: const TextStyle(fontSize: 16, height: 1.5),
                  ),
                  const SizedBox(height: 32),
                  // Tombol Add to Cart
                  Center(
                    child: ElevatedButton.icon(
                      onPressed: () => _addToCart(context),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 32, vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                      ),
                      icon: const Icon(Icons.shopping_cart),
                      label: const Text('Add to Cart'),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
