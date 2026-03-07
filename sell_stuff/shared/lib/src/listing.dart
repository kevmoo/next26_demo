import 'package:json_annotation/json_annotation.dart';

part 'listing.g.dart';

@JsonSerializable()
class Listing {
  final String id;
  final String title;
  final String description;
  final double price;
  final String category;
  final String imageUrl;
  final String sellerId;

  Listing({
    required this.id,
    required this.title,
    required this.description,
    required this.price,
    required this.category,
    required this.imageUrl,
    required this.sellerId,
  });

  factory Listing.fromJson(Map<String, dynamic> json) =>
      _$ListingFromJson(json);

  Map<String, dynamic> toJson() => _$ListingToJson(this);
}
