import 'package:hive/hive.dart';

// ID Type: 5 (Pastikan tidak bentrok dengan typeId lain)
class UserModel extends HiveObject {
  String name;
  String role; // 'admin' atau 'kasir'
  String email;
  String pin; // Password sederhana
  bool isActive;

  UserModel({
    required this.name,
    required this.role,
    required this.email,
    required this.pin,
    this.isActive = true,
  });
}

// Adapter Manual (Agar Anda tidak perlu run build_runner)
class UserModelAdapter extends TypeAdapter<UserModel> {
  @override
  final int typeId = 5;

  @override
  UserModel read(BinaryReader reader) {
    return UserModel(
      name: reader.readString(),
      role: reader.readString(),
      email: reader.readString(),
      pin: reader.readString(),
      isActive: reader.readBool(),
    );
  }

  @override
  void write(BinaryWriter writer, UserModel obj) {
    writer
      ..writeString(obj.name)
      ..writeString(obj.role)
      ..writeString(obj.email)
      ..writeString(obj.pin)
      ..writeBool(obj.isActive);
  }
}