import 'package:hive/hive.dart';

@HiveType(typeId: 4)
class TransactionItem {
  @HiveField(0)
  String productName;

  @HiveField(1)
  int price;

  @HiveField(2)
  int qty;

  TransactionItem({
    required this.productName,
    required this.price,
    required this.qty,
  });
}

@HiveType(typeId: 3)
class TransactionModel extends HiveObject {
  @HiveField(0)
  int time; // SIMPAN SEBAGAI INT

  @HiveField(1)
  int total;

  @HiveField(2)
  String method;

  @HiveField(3)
  int paid;

  @HiveField(4)
  int change;

  @HiveField(5)
  List<TransactionItem> items;

  TransactionModel({
    required DateTime time,
    required this.total,
    required this.method,
    required this.paid,
    required this.change,
    required this.items,
  }) : time = time.millisecondsSinceEpoch;

  DateTime get date => DateTime.fromMillisecondsSinceEpoch(time);
}
