import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:printer_app/printer_page.dart';

class HomePage extends StatelessWidget {
  final List<Map<String, dynamic>> data = [
    {
      'title': 'Baguette Tradition',
      'price': 1.20,
      'qty': 2,
      'icon': Icons.bakery_dining,
    },
    {
      'title': 'Pack Eau Minérale (6x1.5L)',
      'price': 4.50,
      'qty': 1,
      'icon': Icons.water_drop,
    },
    {'title': 'Tomates Grappes - 1KG', 'price': 2.99, 'qty': 1, 'icon': Icons.eco},
    {
      'title': 'Poulet Rôti Label Rouge',
      'price': 7.50,
      'qty': 1,
      'icon': Icons.restaurant,
    },
    {
      'title': 'Fromage Râpé 200g',
      'price': 3.20,
      'qty': 2,
      'icon': Icons.food_bank,
    },
  ];

  final f = NumberFormat("#,##0.00' EUR'", "fr_FR");

  HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    num total = data
        .map((e) => (e['price'] as num) * (e['qty'] as int))
        .reduce((value, element) => value + element);

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text(
          'Amdy Market',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.blueAccent,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Hero Header
          Container(
            padding: const EdgeInsets.all(24),
            decoration: const BoxDecoration(
              color: Colors.blueAccent,
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(30),
                bottomRight: Radius.circular(30),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Total à payer',
                  style: TextStyle(color: Colors.white70, fontSize: 18),
                ),
                Text(
                  f.format(total),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              itemCount: data.length,
              itemBuilder: (c, i) {
                final item = data[i];
                return Card(
                  elevation: 2,
                  margin: const EdgeInsets.only(bottom: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(12),
                    leading: CircleAvatar(
                      backgroundColor: Colors.blueAccent.withOpacity(0.1),
                      child: Icon(
                        item['icon'] as IconData?,
                        color: Colors.blueAccent,
                      ),
                    ),
                    title: Text(
                      item['title'].toString(),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    subtitle: Text(
                      "${f.format(item['price'])} x ${item['qty']}",
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                    trailing: Text(
                      f.format((item['price']) * (item['qty'])),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.blueAccent,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: ElevatedButton.icon(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => PrintPage(data: data)),
              );
            },
            icon: const Icon(Icons.print, size: 24),
            label: const Text(
              'Générer le Reçu',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blueAccent,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              elevation: 4,
            ),
          ),
        ),
      ),
    );
  }
}
