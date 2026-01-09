import 'package:hive/hive.dart';

// Tipe adapter harus unik, kita pakai 0 untuk Product
class Product extends HiveObject {
  String name;
  int price;
  int stock;
  // --- DATA BARU ---
  String category;
  String sku; // Kode Barang/Barcode
  String description;

  Product({
    required this.name,
    required this.price,
    required this.stock,
    this.category = 'Umum', // Default value
    this.sku = '-',
    this.description = '',
  });
}

// ================= ADAPTER MANUAL =================
class ProductAdapter extends TypeAdapter<Product> {
  @override
  final int typeId = 0;

  @override
  Product read(BinaryReader reader) {
    return Product(
      name: reader.readString(),
      price: reader.readInt(),
      stock: reader.readInt(),
      // BACA DATA BARU (Urutan harus sama dengan write)
      category: reader.readString(),
      sku: reader.readString(),
      description: reader.readString(),
    );
  }

  @override
  void write(BinaryWriter writer, Product obj) {
    writer
      ..writeString(obj.name)
      ..writeInt(obj.price)
      ..writeInt(obj.stock)
      // TULIS DATA BARU
      ..writeString(obj.category)
      ..writeString(obj.sku)
      ..writeString(obj.description);
  }
}
