import 'package:flutter/material.dart';
import 'package:flutter_test_remote/product_details_screen.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ProductCategoryScreen extends StatefulWidget {
  const ProductCategoryScreen({super.key});

  @override
  _ProductCategoryScreenState createState() => _ProductCategoryScreenState();
}

class _ProductCategoryScreenState extends State<ProductCategoryScreen> {
  List<String> categories = [];
  List<dynamic> filteredProducts = [];
  bool isLoading = true;
  String selectedCategory = '';

  @override
  void initState() {
    super.initState();
    fetchCategories();
  }

  Future<void> fetchCategories() async {
    final response = await http.get(
      Uri.parse('https://dummyjson.com/products/categories'),
    );
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data is List) {
        setState(() {
          categories = List<String>.from(data.map((e) => e['slug'].toString()));
          isLoading = false;
        });
      } else {
        throw Exception('Unexpected response format for categories');
      }
    } else {
      throw Exception('Failed to load categories');
    }
  }

  Future<void> fetchProductsByCategory(String category) async {
    setState(() {
      isLoading = true;
      selectedCategory = category;
    });
    final response = await http.get(
      Uri.parse('https://dummyjson.com/products/category/$category'),
    );
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      setState(() {
        filteredProducts = data['products'];
        isLoading = false;
      });
    } else {
      throw Exception('Failed to load products for category');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Product Categories')),
      body:
      isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
        children: [
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children:
              categories.map((category) {
                return Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 4.0,
                  ),
                  child: ChoiceChip(
                    label: Text(category),
                    selected: selectedCategory == category,
                    onSelected: (isSelected) {
                      if (isSelected) {
                        fetchProductsByCategory(category);
                      }
                    },
                  ),
                );
              }).toList(),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: filteredProducts.length,
              itemBuilder: (context, index) {
                final product = filteredProducts[index];
                return ListTile(
                  leading: Image.network(
                    product['thumbnail'],
                    width: 50,
                    height: 50,
                    fit: BoxFit.cover,
                  ),
                  title: Text(product['title']),
                  subtitle: Text('Price: \$${product['price']}'),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder:
                            (context) =>
                            ProductDetailsScreen(product: product),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
