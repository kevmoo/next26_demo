import 'package:json_annotation/json_annotation.dart';

part 'listing.g.dart';

abstract class ListingData {
  String get title;
  String get description;
  double get price;
  String get category;
}

@JsonSerializable()
class Listing implements ListingData {
  final String id;
  @override
  final String title;
  @override
  final String description;
  @override
  final double price;
  @override
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

@JsonSerializable()
class CreateListingRequest implements ListingData {
  @override
  final String title;
  @override
  final String description;
  @override
  final double price;
  @override
  final String category;

  final String imageBase64;
  final String imageMimeType;

  CreateListingRequest({
    required this.title,
    required this.description,
    required this.price,
    required this.category,
    required this.imageBase64,
    required this.imageMimeType,
  });

  factory CreateListingRequest.fromJson(Map<String, dynamic> json) =>
      _$CreateListingRequestFromJson(json);

  Map<String, dynamic> toJson() => _$CreateListingRequestToJson(this);
}
