import 'package:cloud_functions/cloud_functions.dart';
import 'package:desktop_drop/desktop_drop.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
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
  XFile? _selectedImage;
  bool _isLoading = false;
  bool _isDragging = false;

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
      var imageUrl = '';
      if (_selectedImage != null) {
        final timestamp = DateTime.now().millisecondsSinceEpoch;
        final ref = FirebaseStorage.instance.ref().child(
          'listings/${timestamp}_${_selectedImage!.name}',
        );
        final bytes = await _selectedImage!.readAsBytes();
        await ref.putData(
          bytes,
          SettableMetadata(contentType: _selectedImage!.mimeType),
        );
        imageUrl = await ref.getDownloadURL();
      }

      final callable = FirebaseFunctions.instance.httpsCallable(
        createListingCallable,
      );
      await callable.call<dynamic>({
        'id': '',
        'title': _title,
        'description': _description,
        'price': price,
        'category': _category,
        'imageUrl': imageUrl,
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
                  const SizedBox(height: 20),
                  DropTarget(
                    onDragDone: (detail) async {
                      if (detail.files.isNotEmpty) {
                        setState(() {
                          _selectedImage = detail.files.first;
                        });
                      }
                    },
                    onDragEntered: (detail) =>
                        setState(() => _isDragging = true),
                    onDragExited: (detail) =>
                        setState(() => _isDragging = false),
                    child: Container(
                      height: 200,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: _isDragging ? Colors.blue : Colors.grey,
                          width: 2,
                        ),
                        borderRadius: BorderRadius.circular(12),
                        color: _isDragging ? Colors.blue.withAlpha(25) : null,
                      ),
                      child: _selectedImage != null
                          ? (kIsWeb
                                ? Image.network(
                                    _selectedImage!.path,
                                    fit: BoxFit.cover,
                                  )
                                : FutureBuilder<Uint8List>(
                                    future: _selectedImage!.readAsBytes(),
                                    builder: (context, snapshot) {
                                      if (snapshot.hasData) {
                                        return Image.memory(
                                          snapshot.data!,
                                          fit: BoxFit.cover,
                                        );
                                      }
                                      return const Center(
                                        child: CircularProgressIndicator(),
                                      );
                                    },
                                  ))
                          : Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(
                                    Icons.cloud_upload,
                                    size: 50,
                                    color: Colors.grey,
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Drag & drop an image here,\n'
                                    'or click to browse',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      color: Colors.grey.shade600,
                                    ),
                                  ),
                                  TextButton(
                                    onPressed: () async {
                                      final picker = ImagePicker();
                                      final picked = await picker.pickImage(
                                        source: ImageSource.gallery,
                                      );
                                      if (picked != null) {
                                        setState(() => _selectedImage = picked);
                                      }
                                    },
                                    child: const Text('Browse Files'),
                                  ),
                                ],
                              ),
                            ),
                    ),
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
