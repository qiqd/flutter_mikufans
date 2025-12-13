// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'history.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

History _$HistoryFromJson(Map<String, dynamic> json) => History(
  media: Work.fromJson(json['media'] as Map<String, dynamic>),
  episodeIndex: (json['episodeIndex'] as num).toInt(),
  lastViewPosition: (json['lastViewPosition'] as num).toInt(),
  lastViewAt: DateTime.parse(json['lastViewAt'] as String),
)..isLove = json['isLove'] as bool;

Map<String, dynamic> _$HistoryToJson(History instance) => <String, dynamic>{
  'media': instance.media,
  'isLove': instance.isLove,
  'episodeIndex': instance.episodeIndex,
  'lastViewPosition': instance.lastViewPosition,
  'lastViewAt': instance.lastViewAt.toIso8601String(),
};
