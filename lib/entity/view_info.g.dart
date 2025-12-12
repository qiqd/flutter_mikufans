// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'view_info.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ViewInfo _$ViewInfoFromJson(Map<String, dynamic> json) => ViewInfo(
  episodeName: json['episodeName'] as String?,
  episodeId: json['episodeId'] as String?,
  urls: (json['urls'] as List<dynamic>).map((e) => e as String).toList(),
);

Map<String, dynamic> _$ViewInfoToJson(ViewInfo instance) => <String, dynamic>{
  'episodeName': instance.episodeName,
  'episodeId': instance.episodeId,
  'urls': instance.urls,
};
