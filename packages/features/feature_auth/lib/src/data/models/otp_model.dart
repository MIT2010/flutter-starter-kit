import '../../domain/entities/otp_entity.dart';

/// Model untuk parsing OTP response dari API.
class OtpModel {
  const OtpModel({
    required this.destination,
    required this.expiresIn,
    required this.requestedAt,
  });

  final String destination;
  final int expiresIn;
  final DateTime requestedAt;

  factory OtpModel.fromJson(Map<String, dynamic> json) {
    return OtpModel(
      destination: json['destination'] as String,
      expiresIn: json['expires_in'] as int,
      requestedAt: json.containsKey('requested_at')
          ? DateTime.parse(json['requested_at'] as String)
          : DateTime.now(),
    );
  }

  OtpEntity toEntity() {
    return OtpEntity(
      destination: destination,
      expiresIn: expiresIn,
      requestedAt: requestedAt,
    );
  }
}
