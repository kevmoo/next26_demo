import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:sell_stuff_shared/shared.dart';

class SellPageScreen extends StatefulWidget {
  const SellPageScreen({super.key});

  @override
  State<SellPageScreen> createState() => _SellPageScreenState();
}

class _SellPageScreenState extends State<SellPageScreen> {
  final _formKey = GlobalKey<FormState>();
  String _title = '';
  String _description = '';
  String _priceString = '';
  String _category = '';
  String _imageUrl = '';
  bool _isLoading = false;

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();

    final price = double.tryParse(_priceString);
    if (price == null || price <= 0) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Invalid price')));
      return;
    }

    setState(() => _isLoading = true);

    try {
      final callable = FirebaseFunctions.instance.httpsCallable(
        createListingCallable,
      );
      await callable.call<dynamic>({
        'id': '',
        'title': _title,
        'description': _description,
        'price': price,
        'category': _category,
        'imageUrl': _imageUrl,
        'sellerId': '', // Handled by server backend
      });

      if (mounted) {
        context.pop();
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Sell an Item')),
    body: _isLoading
        ? const Center(child: CircularProgressIndicator())
        : SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  TextFormField(
                    decoration: const InputDecoration(labelText: 'Title'),
                    validator: (value) =>
                        value == null || value.isEmpty ? 'Required' : null,
                    onSaved: (value) => _title = value ?? '',
                  ),
                  TextFormField(
                    decoration: const InputDecoration(labelText: 'Description'),
                    onSaved: (value) => _description = value ?? '',
                  ),
                  TextFormField(
                    decoration: const InputDecoration(labelText: 'Price'),
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    validator: (value) =>
                        value == null || value.isEmpty ? 'Required' : null,
                    onSaved: (value) => _priceString = value ?? '',
                  ),
                  TextFormField(
                    decoration: const InputDecoration(labelText: 'Category'),
                    onSaved: (value) => _category = value ?? '',
                  ),
                  TextFormField(
                    decoration: const InputDecoration(labelText: 'Image URL'),
                    onSaved: (value) => _imageUrl = value ?? '',
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _submitForm,
                    child: const Text('Submit Listing'),
                  ),
                ],
              ),
            ),
          ),
  );
}
