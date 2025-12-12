// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'source.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Source _$SourceFromJson(Map<String, dynamic> json) => Source(
  index: (json['index'] as num).toInt(),
  name: json['name'] as String,
  episodes: (json['episodes'] as List<dynamic>)
      .map((e) => Episode.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$SourceToJson(Source instance) => <String, dynamic>{
  'index': instance.index,
  'name': instance.name,
  'episodes': instance.episodes,
};
