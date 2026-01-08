import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../data/models/transaction_model.dart';

class TransactionPage extends StatelessWidget {
  const TransactionPage({super.key});

  @override
  Widget build(BuildContext context) {
    final box = Hive.box<TransactionModel>('transactions');

    return Scaffold(
      appBar: AppBar(title: const Text('Riwayat Transaksi')),
      body: ValueListenableBuilder(
        valueListenable: box.listenable(),
        builder: (_, Box<TransactionModel> box, __) {
          if (box.isEmpty) {
            return const Center(child: Text('Belum ada transaksi'));
          }

          return ListView.builder(
            itemCount: box.length,
            itemBuilder: (_, i) {
              final t = box.getAt(i)!;
              return ListTile(
                leading: const Icon(Icons.receipt_long),
                title: Text('Rp ${t.total}'),
                subtitle: Text(
                  '${t.method.toUpperCase()} • ${t.date}',
                ),
                trailing: Text('Kembali: ${t.change}'),
              );
            },
          );
        },
      ),
    );
  }
}
