// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'work.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Work _$MediaFromJson(Map<String, dynamic> json) => Work(
  id: json['id'] as String,
  subId: json['subId'] as String?,
  status: json['status'] as String?,
  title: json['title'] as String?,
  titleCn: json['titleCn'] as String,
  cover: json['cover'] as String,
  type: json['type'] as String?,
  airdate: json['airdate'] as String?,
);

Map<String, dynamic> _$MediaToJson(Work instance) => <String, dynamic>{
  'id': instance.id,
  'subId': instance.subId,
  'status': instance.status,
  'title': instance.title,
  'titleCn': instance.titleCn,
  'cover': instance.cover,
  'type': instance.type,
  'airdate': instance.airdate,
};
