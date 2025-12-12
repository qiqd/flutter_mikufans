// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'history.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

History _$HistoryFromJson(Map<String, dynamic> json) => History(
  media: Media.fromJson(json['media'] as Map<String, dynamic>),
  episodeIndex: (json['episodeIndex'] as num).toInt(),
  lastViewPosition: json['lastViewPosition'] as num,
  lastViewAt: DateTime.parse(json['lastViewAt'] as String),
);

Map<String, dynamic> _$HistoryToJson(History instance) => <String, dynamic>{
  'media': instance.media,
  'episodeIndex': instance.episodeIndex,
  'lastViewPosition': instance.lastViewPosition,
  'lastViewAt': instance.lastViewAt.toIso8601String(),
};
