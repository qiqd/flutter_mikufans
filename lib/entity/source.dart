import 'package:desktop_holo/entity/episode.dart';
import 'package:json_annotation/json_annotation.dart';
part 'source.g.dart';

@JsonSerializable()
class Source {
  final int? index;
  final String? name;
  List<Episode> episodes = List.empty();
  Source({required this.index, required this.name, required this.episodes});
  factory Source.fromJson(Map<String, dynamic> json) => _$SourceFromJson(json);
  Map<String, dynamic> toJson() => _$SourceToJson(this);
}
