class QrisHelper {
  static String generateDynamicQris(String staticQris, int amount) {
    try {
      // 1. BERSIHKAN STRING (Hapus spasi/enter yang tidak sengaja ter-copy)
      // Ini krusial karena 1 spasi saja membuat QR Invalid.
      String cleanQris = staticQris.trim().replaceAll('\n', '').replaceAll(' ', '');

      // 2. Ambil Data Mentah (Buang 4 digit CRC lama di belakang)
      // Contoh: ...6304ABCD -> ambil sampai 6304
      if (cleanQris.length < 4) return staticQris; // Safety check
      String raw = cleanQris.substring(0, cleanQris.length - 4);

      // 3. SIAPKAN TAG 54 (NOMINAL)
      // Format: "54" + Panjang(2 digit) + Nominal
      String amountStr = amount.toString();
      String lengthStr = amountStr.length.toString().padLeft(2, '0');
      String tag54 = "54$lengthStr$amountStr";

      // 4. SISIPKAN TAG 54
      // Kita tidak mengubah tipe QR (tetap 11/Statik) agar tidak ditolak server.
      // Kita hanya menyuntikkan nominal.
      
      // Cek apakah sudah ada nominal sebelumnya?
      if (!raw.contains("54$lengthStr")) {
        // Cari Tag 58 (Country Code "ID") -> "5802ID"
        // Ini adalah patokan paling aman untuk menyisipkan nominal sebelumnya.
        if (raw.contains("5802ID")) {
          raw = raw.replaceFirst("5802ID", "$tag54" "5802ID");
        } else {
          // Jika struktur aneh, kembalikan asli (daripada error)
          return staticQris; 
        }
      }

      // 5. HITUNG CRC16 BARU
      // Tambahkan header CRC "6304"
      raw += "6304"; 
      
      // Hitung kode keamanan baru
      String crc = _getCRC16(raw);
      
      // Gabungkan menjadi QR Baru
      String finalQris = raw + crc;
      
      // Debug: Lihat string baru di terminal (opsional)
      // print("QRIS BARU: $finalQris");
      
      return finalQris;

    } catch (e) {
      return staticQris; // Jika error, pakai QR asli (manual input)
    }
  }

  // ALGORITMA CRC-16/CCITT-FALSE (Standar Baku QRIS)
  static String _getCRC16(String data) {
    int crc = 0xFFFF;
    int polynomial = 0x1021;

    for (int i = 0; i < data.length; i++) {
      int b = data.codeUnitAt(i);
      for (int i = 0; i < 8; i++) {
        bool bit = ((b >> (7 - i) & 1) == 1);
        bool c15 = ((crc >> 15 & 1) == 1);
        crc <<= 1;
        if (c15 ^ bit) crc ^= polynomial;
      }
    }
    
    crc &= 0xffff;
    return crc.toRadixString(16).toUpperCase().padLeft(4, '0');
  }
}