import 'package:equatable/equatable.dart';

class AdminUser extends Equatable {
  final String id;
  final String email;
  final bool verified;
  final DateTime created;
  final DateTime updated;

  const AdminUser({
    required this.id,
    required this.email,
    required this.verified,
    required this.created,
    required this.updated,
  });

  @override
  List<Object?> get props => [id, email, verified, created, updated];
}