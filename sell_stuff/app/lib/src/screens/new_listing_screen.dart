import 'package:desktop_drop/desktop_drop.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import '../widgets/constrained_content.dart';
import 'new_listing_state.dart';

class NewListingScreen extends StatefulWidget {
  const NewListingScreen({super.key});

  @override
  State<NewListingScreen> createState() => _NewListingScreenState();
}

class _NewListingScreenState extends State<NewListingScreen> {
  final _formKey = GlobalKey<FormState>();
  final _state = NewItemState();
  bool _isLoading = false;
  bool _isDragging = false;

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();

    setState(() => _isLoading = true);

    try {
      await _state.submit();

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
            child: ConstrainedContent(
              width: ContentWidth.narrow,
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    TextFormField(
                      decoration: const InputDecoration(labelText: 'Title'),
                      validator: (value) =>
                          value == null || value.isEmpty ? 'Required' : null,
                      onSaved: (value) => _state.title = value ?? '',
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      decoration: const InputDecoration(
                        labelText: 'Description',
                      ),
                      onSaved: (value) => _state.description = value ?? '',
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      decoration: const InputDecoration(labelText: 'Price'),
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      validator: (value) =>
                          value == null || value.isEmpty ? 'Required' : null,
                      onSaved: (value) => _state.priceString = value ?? '',
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      decoration: const InputDecoration(labelText: 'Category'),
                      onSaved: (value) => _state.category = value ?? '',
                    ),
                    const SizedBox(height: 20),
                    DropTarget(
                      onDragDone: (detail) async {
                        if (detail.files.isNotEmpty) {
                          setState(() {
                            _state.selectedImage = detail.files.first;
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
                        child: _state.selectedImage != null
                            ? _buildImagePreview()
                            : _buildImagePickerPlaceholder(),
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
          ),
  );

  Widget _buildImagePreview() => kIsWeb
      ? Image.network(_state.selectedImage!.path, fit: BoxFit.contain)
      : FutureBuilder<Uint8List>(
          future: _state.selectedImage!.readAsBytes(),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              return Image.memory(snapshot.data!, fit: BoxFit.contain);
            }
            return const Center(child: CircularProgressIndicator());
          },
        );

  Widget _buildImagePickerPlaceholder() => Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(Icons.cloud_upload, size: 50, color: Colors.grey),
        const SizedBox(height: 8),
        Text(
          'Drag & drop an image here,\n'
          'or click to browse',
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.grey.shade600),
        ),
        TextButton(
          onPressed: () async {
            final picker = ImagePicker();
            final picked = await picker.pickImage(source: ImageSource.gallery);
            if (picked != null) {
              setState(() => _state.selectedImage = picked);
            }
          },
          child: const Text('Browse Files'),
        ),
      ],
    ),
  );
}
