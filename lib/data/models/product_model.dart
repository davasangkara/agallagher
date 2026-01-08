import 'package:hive/hive.dart';

class Product extends HiveObject {
  String name;
  int price;
  int stock;

  Product({
    required this.name,
    required this.price,
    required this.stock,
  });
}

// ================= ADAPTER =================
class ProductAdapter extends TypeAdapter<Product> {
  @override
  final int typeId = 0;

  @override
  Product read(BinaryReader reader) {
    return Product(
      name: reader.readString(),
      price: reader.readInt(),
      stock: reader.readInt(),
    );
  }

  @override
  void write(BinaryWriter writer, Product obj) {
    writer
      ..writeString(obj.name)
      ..writeInt(obj.price)
      ..writeInt(obj.stock);
  }
}
