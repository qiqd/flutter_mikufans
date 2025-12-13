import 'package:json_annotation/json_annotation.dart';
part 'media.g.dart';

@JsonSerializable()
class Work {
  final String? id;
  final String? subId;
  final String? status;
  final String? title;
  final String? titleCn;
  final String? cover;
  final String? type;
  final String? airdate;
  final String? actors;
  final String? directors;
  final String? summary;
  final String? rating;
  final String? ratingCount;

  Work({
    required this.id,
    this.subId,
    this.status,
    this.title,
    required this.titleCn,
    required this.cover,
    this.type,
    this.airdate,
    this.actors,
    this.directors,
    this.summary,
    this.rating,
    this.ratingCount,
  });
  factory Work.fromJson(Map<String, dynamic> json) => _$MediaFromJson(json);

  Map<String, dynamic> toJson() => _$MediaToJson(this);
}
