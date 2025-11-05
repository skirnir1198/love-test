import 'package:json_annotation/json_annotation.dart';

part 'diagnosis_data.g.dart';

@JsonSerializable()
class Diagnosis {
  final String title;
  final List<String> questions;
  final List<DiagnosisResult> results;

  Diagnosis({
    required this.title,
    required this.questions,
    required this.results,
  });

  factory Diagnosis.fromJson(Map<String, dynamic> json) =>
      _$DiagnosisFromJson(json);

  Map<String, dynamic> toJson() => _$DiagnosisToJson(this);
}

@JsonSerializable()
class DiagnosisResult {
  @JsonKey(name: 'type_name')
  final String typeName;
  @JsonKey(name: 'description_hint')
  final String descriptionHint;

  DiagnosisResult({required this.typeName, required this.descriptionHint});

  factory DiagnosisResult.fromJson(Map<String, dynamic> json) =>
      _$DiagnosisResultFromJson(json);

  Map<String, dynamic> toJson() => _$DiagnosisResultToJson(this);
}
