// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'trainer_application.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$TrainerApplicationImpl _$$TrainerApplicationImplFromJson(
  Map<String, dynamic> json,
) => _$TrainerApplicationImpl(
  fullName: json['fullName'] as String,
  bio: json['bio'] as String,
  yearsOfExperience: (json['yearsOfExperience'] as num).toInt(),
  specializations:
      (json['specializations'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
  certificationDetails: json['certificationDetails'] as String,
  idDocumentUrl: json['idDocumentUrl'] as String,
  certificationDocumentUrls:
      (json['certificationDocumentUrls'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
  profilePhotoUrl: json['profilePhotoUrl'] as String,
  contactEmail: json['contactEmail'] as String,
  phoneNumber: json['phoneNumber'] as String,
  status: json['status'] as String?,
  feedback: json['feedback'] as String?,
  reviewedAt:
      json['reviewedAt'] == null
          ? null
          : DateTime.parse(json['reviewedAt'] as String),
  socialLinks: (json['socialLinks'] as Map<String, dynamic>?)?.map(
    (k, e) => MapEntry(k, e as String),
  ),
);

Map<String, dynamic> _$$TrainerApplicationImplToJson(
  _$TrainerApplicationImpl instance,
) => <String, dynamic>{
  'fullName': instance.fullName,
  'bio': instance.bio,
  'yearsOfExperience': instance.yearsOfExperience,
  'specializations': instance.specializations,
  'certificationDetails': instance.certificationDetails,
  'idDocumentUrl': instance.idDocumentUrl,
  'certificationDocumentUrls': instance.certificationDocumentUrls,
  'profilePhotoUrl': instance.profilePhotoUrl,
  'contactEmail': instance.contactEmail,
  'phoneNumber': instance.phoneNumber,
  'status': instance.status,
  'feedback': instance.feedback,
  'reviewedAt': instance.reviewedAt?.toIso8601String(),
  'socialLinks': instance.socialLinks,
};

_$TrainerApplicationStatusImpl _$$TrainerApplicationStatusImplFromJson(
  Map<String, dynamic> json,
) => _$TrainerApplicationStatusImpl(
  status: json['status'] as String,
  feedback: json['feedback'] as String?,
  reviewedAt:
      json['reviewedAt'] == null
          ? null
          : DateTime.parse(json['reviewedAt'] as String),
  reviewerId: json['reviewerId'] as String,
);

Map<String, dynamic> _$$TrainerApplicationStatusImplToJson(
  _$TrainerApplicationStatusImpl instance,
) => <String, dynamic>{
  'status': instance.status,
  'feedback': instance.feedback,
  'reviewedAt': instance.reviewedAt?.toIso8601String(),
  'reviewerId': instance.reviewerId,
};
