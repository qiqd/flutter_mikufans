import 'package:mikufans/entity/media.dart';
import 'package:mikufans/entity/source.dart';
import 'package:json_annotation/json_annotation.dart';
part 'detail.g.dart';

@JsonSerializable()
class Detail {
  final Media media;
  final List<Media> series;
  final List<Source> sources;
  Detail({required this.media, required this.series, required this.sources});
  factory Detail.fromJson(Map<String, dynamic> json) => _$DetailFromJson(json);
  Map<String, dynamic> toJson() => _$DetailToJson(this);
}
