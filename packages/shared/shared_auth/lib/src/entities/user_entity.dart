import 'package:equatable/equatable.dart';

/// Entity user yang dipakai lintas fitur.
/// Tidak tahu JSON, tidak tahu API — murni representasi bisnis.
class UserEntity extends Equatable {
  const UserEntity({
    required this.id,
    required this.name,
    required this.email,
    this.avatarUrl,
    this.phoneNumber,
    this.role,
  });

  final String id;
  final String name;
  final String email;
  final String? avatarUrl;
  final String? phoneNumber;
  final String? role;

  /// Inisial nama untuk avatar placeholder
  String get initials {
    final parts = name.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
    }
    return name.isNotEmpty ? name[0].toUpperCase() : '?';
  }

  @override
  List<Object?> get props => [id, name, email, avatarUrl, phoneNumber, role];
}
