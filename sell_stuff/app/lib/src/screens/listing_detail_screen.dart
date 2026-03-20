import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:sell_stuff_shared/shared.dart';

import '../widgets/constrained_content.dart';

class ListingDetailScreen extends StatelessWidget {
  final String id;

  const ListingDetailScreen({super.key, required this.id});

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Item Details')),
    body: FutureBuilder<DocumentSnapshot>(
      future: FirebaseFirestore.instance
          .collection(listingsCollection)
          .doc(id)
          .get(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const Center(child: Text('Something went wrong'));
        }
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || !snapshot.data!.exists) {
          return const Center(child: Text('Listing not found'));
        }

        final data = snapshot.data!.data() as Map<String, dynamic>;
        final listing = Listing.fromJson(data);

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: ConstrainedContent(
            width: ContentWidth.narrow,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (listing.imageUrl.isNotEmpty)
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: AspectRatio(
                      aspectRatio: 4 / 3,
                      child: Image.network(
                        listing.imageUrl,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                const SizedBox(height: 16),
                Text(
                  listing.title,
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const SizedBox(height: 8),
                Text(
                  '\$${listing.price.toStringAsFixed(2)}',
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(color: Colors.green),
                ),
                const SizedBox(height: 16),
                Text(
                  listing.description,
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                const SizedBox(height: 16),
                if (listing.category.isNotEmpty)
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Chip(label: Text(listing.category)),
                  ),
              ],
            ),
          ),
        );
      },
    ),
  );
}
