import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:multi_select_flutter/dialog/multi_select_dialog_field.dart';
import 'package:multi_select_flutter/util/multi_select_item.dart';
import 'package:triveni/service/products%20services/product_services.dart';

class ProductsUpdate extends StatefulWidget {
  final String docId;
  const ProductsUpdate({super.key, required this.docId});

  @override
  State<ProductsUpdate> createState() => _ProductsUpdateState();
}

class _ProductsUpdateState extends State<ProductsUpdate> {
  final _repo = ProductServices();

  final _productNameController = TextEditingController();
  final _productDescController = TextEditingController();
  final _productecoFriendlyAlternativeController = TextEditingController();
  String? _productCategoryController;
  List<String> _productSubCategoryController = [];
  final _productBrandController = TextEditingController();
  final List<String> _items = [
    'Shampoo and Conditioner',
    'Soap and Body Wash',
  ];

  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchProductData();
  }

  Future<void> _fetchProductData() async {
    try {
      DocumentSnapshot doc = await FirebaseFirestore.instance
          .collection('products')
          .doc(widget.docId)
          .get();

      if (doc.exists) {
        final data = doc.data() as Map<String, dynamic>;
        setState(() {
          _productNameController.text = data['productName'] ?? '';
          _productDescController.text = data['productDescription'] ?? '';
          _productecoFriendlyAlternativeController.text =
              data['ecoFriendlyAlternative'] ?? '';
          _productCategoryController = data['category']?['category'];
          _productSubCategoryController =
              List<String>.from(data['category']?['subcategory'] ?? []);
          _productBrandController.text = data['brand'] ?? '';
          _repo.imageUrl = data['imageUrl'] ?? '';
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Error: ${e.toString()}')));
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _updateProduct() async {
    try {
      setState(() {
        _isLoading = true;
      });

      await FirebaseFirestore.instance
          .collection('products')
          .doc(widget.docId)
          .update({
        'productName': _productNameController.text,
        'productDescription': _productDescController.text,
        'ecoFriendlyAlternative': _productecoFriendlyAlternativeController.text,
        'category': {
          'category': _productCategoryController,
          'subcategory': _productSubCategoryController,
        },
        'brand': _productBrandController.text,
        'imageUrl': _repo.imageUrl,
      });

      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Product updated successfully!')));
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Error: ${e.toString()}')));
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Update Product'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(
                    controller: _productNameController,
                    decoration:
                        const InputDecoration(labelText: 'Product Name'),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: _productDescController,
                    decoration:
                        const InputDecoration(labelText: 'Product Description'),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: _productecoFriendlyAlternativeController,
                    decoration: const InputDecoration(
                        labelText: 'Eco-Friendly Alternative'),
                  ),
                  const SizedBox(height: 10),
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
                  const SizedBox(height: 10),
                  MultiSelectDialogField(
                    items: _items.map((e) => MultiSelectItem(e, e)).toList(),
                    title: const Text("Select Items"),
                    selectedColor: Colors.purple,
                    decoration: BoxDecoration(
                      color: Colors.purple.withOpacity(0.1),
                      borderRadius: const BorderRadius.all(Radius.circular(10)),
                      border: Border.all(color: Colors.purple, width: 2),
                    ),
                    buttonText: const Text(
                      "Select Items",
                      style: TextStyle(color: Colors.purple, fontSize: 16),
                    ),
                    onConfirm: (values) {
                      setState(() {
                        _productSubCategoryController = values.cast<String>();
                      });
                    },
                    initialValue: _productSubCategoryController,
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: _productBrandController,
                    decoration:
                        const InputDecoration(labelText: 'Product Brand'),
                  ),
                  const SizedBox(height: 10),
                  TextButton(
                    onPressed: () {
                      // _repo.uploadImage();
                    },
                    child: _repo.isLoading
                        ? const CircularProgressIndicator()
                        : const Text('Upload Image'),
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
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _updateProduct,
                    child: const Text('Submit Product'),
                  ),
                ],
              ),
            ),
    );
  }
}
