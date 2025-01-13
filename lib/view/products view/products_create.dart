import 'dart:convert';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:multi_select_flutter/dialog/multi_select_dialog_field.dart';
import 'package:multi_select_flutter/util/multi_select_item.dart';

import 'package:triveni/service/products%20services/product_services.dart';

class ProductsCreate extends StatefulWidget {
  const ProductsCreate({super.key});

  @override
  State<ProductsCreate> createState() => _ProductsCreateState();
}

class _ProductsCreateState extends State<ProductsCreate> {
  final _repo = ProductServices();

  final _productNameController = TextEditingController();
  final _productDescController = TextEditingController();
  final _productecoFriendlyAlternativeController = TextEditingController();
  String? _productCategoryController;
  List<String> _productSubCategoryController = [];
  final _productBrandController = TextEditingController();
  final List<String> options = [
    'Shampoo and Conditioner',
    'Soap and Body Wash',
  ];
  final List<String> _items = [
    'Shampoo and conditioner',
    'Soap and Body Wash',
  ];

  // Function to add data to Firestore

  // Handle form submission
  Future<void> handleSubmit() async {
    final docRef = FirebaseFirestore.instance.collection('products').doc();
    // Collect all data
    Map<String, dynamic> productData = {
      'id': docRef.id,
      'productName': _productNameController.text,
      'productDescription': _productDescController.text,
      'ecoFriendlyAlternative': _productecoFriendlyAlternativeController.text,
      'category': {
        'category': _productCategoryController,
        'subcategory': _productSubCategoryController
      },
      'brand': _productBrandController.text,
      'imageUrl': _repo.imageUrl, // Add the image URL to Firestore data
    };

    // Submit the data to Firestore
    await _repo.addData('products', productData);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Product'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _productNameController,
              decoration: const InputDecoration(labelText: 'Product Name'),
            ),
            TextField(
              controller: _productDescController,
              decoration:
                  const InputDecoration(labelText: 'Product Description'),
            ),
            TextField(
              controller: _productecoFriendlyAlternativeController,
              decoration:
                  const InputDecoration(labelText: 'Eco-Friendly Alternative'),
            ),
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Select a category',
              ),
              items: [
                'Personal Care',
                'Household Cleaning',
              ]
                  .map(
                    (e) => DropdownMenuItem<String>(
                      value: e,
                      child: Text(e),
                    ),
                  )
                  .toList(),
              onChanged: (value) {
                setState(() {
                  _productCategoryController = value;
                });
              },
              value: _productCategoryController,
            ),
            MultiSelectDialogField(
              items: _items.map((e) => MultiSelectItem(e, e)).toList(),
              title: Text("Select Items"),
              selectedColor: Colors.purple,
              decoration: BoxDecoration(
                color: Colors.purple.withOpacity(0.1),
                borderRadius: BorderRadius.all(Radius.circular(10)),
                border: Border.all(color: Colors.purple, width: 2),
              ),
              buttonText: Text(
                "Select Items",
                style: TextStyle(color: Colors.purple, fontSize: 16),
              ),
              onConfirm: (values) {
                setState(() {
                  _productSubCategoryController = values.cast<String>();
                });
              },
            ),
            TextField(
              controller: _productBrandController,
              decoration: const InputDecoration(labelText: 'Product Brand'),
            ),
            TextButton(
                onPressed: () {
                  // _repo.uploadImage();
                },
                child: _repo.isLoading
                    ? const CircularProgressIndicator()
                    : const Text('Upload image')),
            TextButton(
              onPressed: () {
                handleSubmit(); // Handle form submission
              },
              child: const Text('Submit Product'),
            ),
            if (_repo.imageUrl.isNotEmpty)
              Row(
                children: [
                  Image.network(
                    _repo.imageUrl,
                    height: 100,
                  ), // Display the uploaded image
                ],
              ),
          ],
        ),
      ),
    );
  }
}
