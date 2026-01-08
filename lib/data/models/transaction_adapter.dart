import 'package:hive/hive.dart';
import 'transaction_model.dart';

// ===== ITEM =====
class TransactionItemAdapter extends TypeAdapter<TransactionItem> {
  @override
  final int typeId = 4;

  @override
  TransactionItem read(BinaryReader reader) {
    return TransactionItem(
      productName: reader.readString(),
      price: reader.readInt(),
      qty: reader.readInt(),
    );
  }

  @override
  void write(BinaryWriter writer, TransactionItem obj) {
    writer
      ..writeString(obj.productName)
      ..writeInt(obj.price)
      ..writeInt(obj.qty);
  }
}

// ===== TRANSACTION =====
class TransactionModelAdapter extends TypeAdapter<TransactionModel> {
  @override
  final int typeId = 3;

  @override
  TransactionModel read(BinaryReader reader) {
    return TransactionModel(
      time: DateTime.fromMillisecondsSinceEpoch(reader.readInt()),
      total: reader.readInt(),
      method: reader.readString(),
      paid: reader.readInt(),
      change: reader.readInt(),
      items: (reader.readList() as List).cast<TransactionItem>(),
    );
  }

  @override
  void write(BinaryWriter writer, TransactionModel obj) {
    writer
      ..writeInt(obj.time)
      ..writeInt(obj.total)
      ..writeString(obj.method)
      ..writeInt(obj.paid)
      ..writeInt(obj.change)
      ..writeList(obj.items);
  }
}
