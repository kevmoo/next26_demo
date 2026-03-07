// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'listing.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Listing _$ListingFromJson(Map<String, dynamic> json) => Listing(
  id: json['id'] as String,
  title: json['title'] as String,
  description: json['description'] as String,
  price: (json['price'] as num).toDouble(),
  category: json['category'] as String,
  imageUrl: json['imageUrl'] as String,
  sellerId: json['sellerId'] as String,
);

Map<String, dynamic> _$ListingToJson(Listing instance) => <String, dynamic>{
  'id': instance.id,
  'title': instance.title,
  'description': instance.description,
  'price': instance.price,
  'category': instance.category,
  'imageUrl': instance.imageUrl,
  'sellerId': instance.sellerId,
};
