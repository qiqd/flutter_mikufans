import 'package:json_annotation/json_annotation.dart';
part 'view_info.g.dart';

@JsonSerializable()
class ViewInfo {
  final String? episodeName;
  final String? episodeId;
  final List<String> urls;
  ViewInfo({this.episodeName, this.episodeId, required this.urls});
  factory ViewInfo.fromJson(Map<String, dynamic> json) =>
      _$ViewInfoFromJson(json);
  Map<String, dynamic> toJson() => _$ViewInfoToJson(this);
}
