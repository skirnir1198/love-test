// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'diagnosis_data.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Diagnosis _$DiagnosisFromJson(Map<String, dynamic> json) => Diagnosis(
  title: json['title'] as String,
  questions: (json['questions'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  results: (json['results'] as List<dynamic>)
      .map((e) => DiagnosisResult.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$DiagnosisToJson(Diagnosis instance) => <String, dynamic>{
  'title': instance.title,
  'questions': instance.questions,
  'results': instance.results,
};

DiagnosisResult _$DiagnosisResultFromJson(Map<String, dynamic> json) =>
    DiagnosisResult(
      typeName: json['type_name'] as String,
      descriptionHint: json['description_hint'] as String,
    );

Map<String, dynamic> _$DiagnosisResultToJson(DiagnosisResult instance) =>
    <String, dynamic>{
      'type_name': instance.typeName,
      'description_hint': instance.descriptionHint,
    };
