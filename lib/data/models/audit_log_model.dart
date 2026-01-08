import 'package:hive/hive.dart';

part 'audit_log_model.g.dart';

@HiveType(typeId: 1)
class AuditLog extends HiveObject {
  @HiveField(0)
  final String action; // CREATE, UPDATE, DELETE

  @HiveField(1)
  final String productName;

  @HiveField(2)
  final String role;

  @HiveField(3)
  final DateTime time;

  AuditLog({
    required this.action,
    required this.productName,
    required this.role,
    required this.time,
  });
}
