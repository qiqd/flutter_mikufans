import 'package:desktop_holo/entity/work.dart';
import 'package:desktop_holo/entity/source.dart';
import 'package:json_annotation/json_annotation.dart';
part 'detail.g.dart';

@JsonSerializable()
class Detail {
  final Work media;
  final List<Work> series;
  final List<Source> sources;
  Detail({required this.media, required this.series, required this.sources});
  factory Detail.fromJson(Map<String, dynamic> json) => _$DetailFromJson(json);
  Map<String, dynamic> toJson() => _$DetailToJson(this);
}
