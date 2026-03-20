import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:sell_stuff_shared/shared.dart';

import '../widgets/constrained_content.dart';

class ListingGridScreen extends StatelessWidget {
  const ListingGridScreen({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
    floatingActionButton: FloatingActionButton(
      onPressed: () => context.go('/sell'),
      child: const Icon(Icons.add),
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

        return ConstrainedContent(
          width: ContentWidth.wide,
          child: GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
              maxCrossAxisExtent: 300,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 0.75,
            ),
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final data = docs[index].data() as Map<String, dynamic>;
              final listing = Listing.fromJson(data);
              return _ListingCard(listing: listing);
            },
          ),
        );
      },
    ),
  );
}

class _ListingCard extends StatefulWidget {
  final Listing listing;

  const _ListingCard({required this.listing});

  @override
  State<_ListingCard> createState() => _ListingCardState();
}

class _ListingCardState extends State<_ListingCard> {
  bool _isHovering = false;

  @override
  Widget build(BuildContext context) => MouseRegion(
    cursor: SystemMouseCursors.click,
    onEnter: (_) => setState(() => _isHovering = true),
    onExit: (_) => setState(() => _isHovering = false),
    child: GestureDetector(
      onTap: () => context.go('/listing/${widget.listing.id}'),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        transform: Matrix4.translationValues(0, _isHovering ? -4 : 0, 0),
        child: Card(
          elevation: _isHovering ? 8 : 2,
          clipBehavior: Clip.hardEdge,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: widget.listing.imageUrl.isNotEmpty
                    ? Image.network(
                        widget.listing.imageUrl,
                        fit: BoxFit.contain,
                      )
                    : const Icon(Icons.image, size: 50),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  widget.listing.title,
                  style: Theme.of(context).textTheme.titleMedium,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: Text(
                  '\$${widget.listing.price.toStringAsFixed(2)}',
                  style: Theme.of(
                    context,
                  ).textTheme.bodyLarge?.copyWith(color: Colors.green),
                ),
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    ),
  );
}
