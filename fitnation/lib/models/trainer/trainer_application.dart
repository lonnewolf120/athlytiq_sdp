import 'package:freezed_annotation/freezed_annotation.dart';

part 'trainer_application.freezed.dart';
part 'trainer_application.g.dart';

@freezed
class TrainerApplication with _$TrainerApplication {
  const factory TrainerApplication({
    required String fullName,
    required String bio,
    required int yearsOfExperience,
    required List<String> specializations,
    required String certificationDetails,
    required String idDocumentUrl,
    required List<String> certificationDocumentUrls,
    required String profilePhotoUrl,
    required String contactEmail,
    required String phoneNumber,
    String? status,
    String? feedback,
    DateTime? reviewedAt,
    Map<String, String>? socialLinks,
  }) = _TrainerApplication;

  factory TrainerApplication.fromJson(Map<String, dynamic> json) =>
      _$TrainerApplicationFromJson(json);
}

@freezed
class TrainerApplicationStatus with _$TrainerApplicationStatus {
  const factory TrainerApplicationStatus({
    required String status,
    String? feedback,
    DateTime? reviewedAt,
    required String reviewerId,
  }) = _TrainerApplicationStatus;

  factory TrainerApplicationStatus.fromJson(Map<String, dynamic> json) =>
      _$TrainerApplicationStatusFromJson(json);
}

enum TrainerSpecialization {
  weightTraining('Weight Training'),
  cardio('Cardio'),
  yoga('Yoga'),
  pilates('Pilates'),
  crossfit('CrossFit'),
  martialArts('Martial Arts'),
  dance('Dance'),
  sports('Sports Training'),
  rehabilitation('Rehabilitation'),
  nutrition('Nutrition');

  final String displayName;
  const TrainerSpecialization(this.displayName);
}
