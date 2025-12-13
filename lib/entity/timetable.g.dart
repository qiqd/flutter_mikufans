// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'timetable.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Timetable _$TimetableFromJson(Map<String, dynamic> json) => Timetable(
  (json['week'] as num).toInt(),
  (json['medias'] as List<dynamic>)
      .map((e) => Work.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$TimetableToJson(Timetable instance) => <String, dynamic>{
  'week': instance.week,
  'medias': instance.medias,
};
