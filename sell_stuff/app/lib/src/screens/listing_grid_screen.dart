import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:sell_stuff_shared/shared.dart';

class ListingGridScreen extends StatelessWidget {
  const ListingGridScreen({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: const Text('Sell Stuff'),
      actions: [
        IconButton(
          icon: const Icon(Icons.add),
          onPressed: () => context.push('/sell'),
        ),
        IconButton(
          icon: const Icon(Icons.logout),
          onPressed: () => FirebaseAuth.instance.signOut(),
        ),
      ],
    ),
    body: StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection(listingsCollection)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const Center(child: Text('Something went wrong'));
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final docs = snapshot.data!.docs;
        if (docs.isEmpty) {
          return const Center(child: Text('No items for sale yet.'));
        }

        return GridView.builder(
          padding: const EdgeInsets.all(16),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 0.75,
          ),
          itemCount: docs.length,
          itemBuilder: (context, index) {
            final data = docs[index].data() as Map<String, dynamic>;
            final listing = Listing.fromJson(data);

            return GestureDetector(
              onTap: () => context.push('/listing/${listing.id}'),
              child: Card(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(
                      child: listing.imageUrl.isNotEmpty
                          ? Image.network(listing.imageUrl, fit: BoxFit.cover)
                          : const Icon(Icons.image, size: 50),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        listing.title,
                        style: Theme.of(context).textTheme.titleMedium,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: Text(
                        '\$${listing.price.toStringAsFixed(2)}',
                        style: Theme.of(
                          context,
                        ).textTheme.bodyLarge?.copyWith(color: Colors.green),
                      ),
                    ),
                    const SizedBox(height: 8),
                  ],
                ),
              ),
            );
          },
        );
      },
    ),
  );
}
