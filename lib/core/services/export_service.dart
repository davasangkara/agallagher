import 'dart:io';
import 'package:excel/excel.dart';
import 'package:hive/hive.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import '../../data/models/transaction_model.dart';

class ExportService {
  
  static Future<void> exportTransactionToExcel() async {
    // 1. Ambil Data dari Hive
    final box = Hive.box<TransactionModel>('transactions');
    final transactions = box.values.toList();

    // Sortir dari yang terbaru
    transactions.sort((a, b) => b.time.compareTo(a.time));

    // 2. Buat File Excel
    var excel = Excel.createExcel();
    
    // Hapus sheet default "Sheet1" dan buat sheet "Laporan"
    String sheetName = 'Laporan Penjualan';
    Sheet sheet = excel[sheetName];
    excel.delete('Sheet1'); 

    // 3. Buat Header Kolom (Styling Sederhana)
    List<String> headers = [
      'No',
      'Tanggal & Jam',
      'Items (Produk)',
      'Metode Bayar',
      'Subtotal',
      'Total Bayar'
    ];
    
    sheet.appendRow(headers.map((e) => TextCellValue(e)).toList());

    // 4. Isi Data Baris per Baris
    final currency = NumberFormat.currency(locale: 'id_ID', symbol: '', decimalDigits: 0);
    final dateFormat = DateFormat('dd/MM/yyyy HH:mm');

    for (var i = 0; i < transactions.length; i++) {
      final trx = transactions[i];
      
      // Menggabungkan item menjadi 1 string: "Kopi (2), Roti (1)"
      String itemsString = trx.items.map((e) => "${e.productName} (${e.qty})").join(", ");
      
      List<CellValue> rowData = [
        IntCellValue(i + 1), // No
        TextCellValue(dateFormat.format(DateTime.fromMillisecondsSinceEpoch(trx.time))), // Tanggal
        TextCellValue(itemsString), // Items
        TextCellValue(trx.method.toUpperCase()), // Metode
        IntCellValue(trx.total), // Total Angka (untuk rumus excel)
        TextCellValue("Rp ${currency.format(trx.total)}"), // Total Formatted
      ];
      
      sheet.appendRow(rowData);
    }

    // 5. Simpan ke File Temporary
    // Kita encode excel ke bytes
    var fileBytes = excel.save();
    
    if (fileBytes != null) {
      // Cari folder temporary di HP
      final directory = await getTemporaryDirectory();
      final path = "${directory.path}/Laporan_Transaksi_${DateTime.now().millisecondsSinceEpoch}.xlsx";
      
      // Tulis file
      File(path)
        ..createSync(recursive: true)
        ..writeAsBytesSync(fileBytes);

      // 6. Bagikan File (Share Sheet)
      // Ini akan membuka popup mau dikirim ke WA/Email/Save to Files
      await Share.shareXFiles([XFile(path)], text: 'Laporan Penjualan Export');
    }
  }
}