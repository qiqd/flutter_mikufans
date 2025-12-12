// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'detail.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Detail _$DetailFromJson(Map<String, dynamic> json) => Detail(
  media: Media.fromJson(json['media'] as Map<String, dynamic>),
  series: (json['series'] as List<dynamic>)
      .map((e) => Media.fromJson(e as Map<String, dynamic>))
      .toList(),
  sources: (json['sources'] as List<dynamic>)
      .map((e) => Source.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$DetailToJson(Detail instance) => <String, dynamic>{
  'media': instance.media,
  'series': instance.series,
  'sources': instance.sources,
};
