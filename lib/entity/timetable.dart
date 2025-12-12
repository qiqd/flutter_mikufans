import 'package:json_annotation/json_annotation.dart';
import 'package:mikufans/entity/media.dart';
part 'timetable.g.dart';

@JsonSerializable()
class Timetable {
  final int week;
  final List<Media> medias;

  Timetable(this.week, this.medias);
  factory Timetable.fromJson(Map<String, dynamic> json) =>
      _$TimetableFromJson(json);
  Map<String, dynamic> toJson() => _$TimetableToJson(this);
}
