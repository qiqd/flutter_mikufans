import 'package:mikufans/entity/media.dart';
import 'package:json_annotation/json_annotation.dart';
part 'history.g.dart';

@JsonSerializable()
class History {
  final Media media;
  final int episodeIndex;
  final num lastViewPosition;
  final DateTime lastViewAt;
  History({
    required this.media,
    required this.episodeIndex,
    required this.lastViewPosition,
    required this.lastViewAt,
  });
  factory History.fromJson(Map<String, dynamic> json) =>
      _$HistoryFromJson(json);
  Map<String, dynamic> toJson() => _$HistoryToJson(this);
}
