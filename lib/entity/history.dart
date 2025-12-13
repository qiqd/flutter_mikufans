import 'dart:ffi';

import 'package:mikufans/entity/work.dart';
import 'package:json_annotation/json_annotation.dart';
part 'history.g.dart';

@JsonSerializable()
class History {
  Work media;
  bool isLove = false;
  int episodeIndex;
  int lastViewPosition;
  DateTime lastViewAt;
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
