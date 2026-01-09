import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../dashboard/dashboard_page.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  // Controller untuk Input
  final _taxCtrl = TextEditingController();
  final _qrisCtrl = TextEditingController();

  final Box _settingsBox = Hive.box('settings');

  @override
  void initState() {
    super.initState();
    // 1. Load Data Pajak
    final savedTax = _settingsBox.get('tax_rate', defaultValue: 0);
    _taxCtrl.text = savedTax.toString();

    // 2. Load Data QRIS (OTOMATIS TERISI DATA ANDA)
    // Saya masukkan string QRIS Anda sebagai 'defaultValue'.
    // Jadi kalau database kosong, QRIS Anda langsung muncul.
    const myStaticQris =
        "00020101021126610015COM.EIDUPAY.WWW011893600824000000099502090000009950303UMI51440014ID.CO.QRIS.WWW0215ID10243301369600303UMI5204481253033605802ID5915MBL-DAFFAXSTORE6010PURWAKARTA61054111162070703A0163044E17";

    final savedQris = _settingsBox.get('qris_data', defaultValue: myStaticQris);

    _qrisCtrl.text = savedQris.trim();

    if (!_settingsBox.containsKey('qris_data')) {
      _settingsBox.put('qris_data', myStaticQris);
    }
  }

  // --- FUNGSI SIMPAN PAJAK ---
  void _saveTax(int value) {
    _settingsBox.put('tax_rate', value);
    setState(() {}); // Refresh UI
  }

  // --- FUNGSI SIMPAN QRIS ---
  void _saveQris() {
    // Simpan string QRIS ke Hive
    _settingsBox.put('qris_data', _qrisCtrl.text.trim());

    // Tutup Keyboard
    FocusScope.of(context).unfocus();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Data QRIS berhasil disimpan!'),
        backgroundColor: Colors.green,
      ),
    );
  }

  // --- FUNGSI RESET DATABASE ---
  void _resetDatabase() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Reset Database?"),
        content: const Text(
          "Semua data transaksi dan produk akan dihapus permanen.",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Batal"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(context, true),
            child: const Text(
              "Hapus Semua",
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await Hive.box('products').clear();
      await Hive.box('transactions').clear();
      await Hive.box('audit_logs').clear();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Database berhasil di-reset!'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // --- UTILS EDIT NAMA/ALAMAT ---
  void _editSimple(
    BuildContext context,
    String key,
    String label,
    String? currentVal,
  ) {
    final ctrl = TextEditingController(text: currentVal);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        padding: EdgeInsets.fromLTRB(
          24,
          24,
          24,
          MediaQuery.of(ctx).viewInsets.bottom + 24,
        ),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Ubah $label",
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: ctrl,
              autofocus: true,
              decoration: InputDecoration(
                filled: true,
                fillColor: const Color(0xFFF5F6FA),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                hintText: "Masukkan $label baru",
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF6C63FF),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () {
                  _settingsBox.put(key, ctrl.text);
                  setState(() {}); // Refresh UI
                  Navigator.pop(ctx);
                },
                child: const Text(
                  "Simpan Perubahan",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _editNumber(
    BuildContext context,
    String key,
    String label,
    dynamic currentVal,
  ) {
    final ctrl = TextEditingController(text: currentVal?.toString() ?? '0');
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        padding: EdgeInsets.fromLTRB(
          24,
          24,
          24,
          MediaQuery.of(ctx).viewInsets.bottom + 24,
        ),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Atur $label",
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: ctrl,
              autofocus: true,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                filled: true,
                fillColor: const Color(0xFFF5F6FA),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                suffixText: "%",
                suffixStyle: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF6C63FF),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () {
                  final val = int.tryParse(ctrl.text) ?? 0;
                  _saveTax(val);
                  Navigator.pop(ctx);
                },
                child: const Text(
                  "Simpan Angka",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F6FF),
      body: Column(
        children: [
          // HEADER MODERN
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: const BorderRadius.vertical(
                bottom: Radius.circular(32),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.blueGrey.withOpacity(0.08),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Row(
              children: [
                InkWell(
                  onTap: () => Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (_) => const DashboardPage()),
                  ),
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.grey[50],
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    child: const Icon(
                      Icons.arrow_back_ios_new_rounded,
                      size: 20,
                      color: Colors.black87,
                    ),
                  ),
                ),
                const SizedBox(width: 24),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Pengaturan',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFF2D3436),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Konfigurasi Toko & Aplikasi',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey[500],
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // LIST PENGATURAN
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  // GROUP 1: TOKO
                  _SettingsGroup(
                    title: "IDENTITAS TOKO",
                    children: [
                      _SettingTile(
                        icon: Icons.storefront_rounded,
                        color: Colors.blueAccent,
                        title: "Nama Toko",
                        subtitle: _settingsBox.get(
                          'store_name',
                          defaultValue: 'Nama Toko Anda',
                        ),
                        onTap: () => _editSimple(
                          context,
                          'store_name',
                          'Nama Toko',
                          _settingsBox.get('store_name'),
                        ),
                      ),
                      _SettingTile(
                        icon: Icons.map_rounded,
                        color: Colors.redAccent,
                        title: "Alamat Lengkap",
                        subtitle: _settingsBox.get(
                          'store_address',
                          defaultValue: 'Alamat belum diatur',
                        ),
                        onTap: () => _editSimple(
                          context,
                          'store_address',
                          'Alamat Toko',
                          _settingsBox.get('store_address'),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // GROUP 2: TRANSAKSI
                  _SettingsGroup(
                    title: "TRANSAKSI & KEUANGAN",
                    children: [
                      _SettingTile(
                        icon: Icons.percent_rounded,
                        color: Colors.orange,
                        title: "Pajak (PPN)",
                        subtitle:
                            "${_settingsBox.get('tax_rate', defaultValue: 0)}% dari total belanja",
                        onTap: () => _editNumber(
                          context,
                          'tax_rate',
                          'Persentase Pajak',
                          _settingsBox.get('tax_rate'),
                        ),
                      ),
                      _SettingTile(
                        icon: Icons.print_rounded,
                        color: Colors.purple,
                        title: "Printer Struk",
                        subtitle: _settingsBox.get(
                          'printer_name',
                          defaultValue: 'Belum Terhubung',
                        ),
                        onTap: () => _editSimple(
                          context,
                          'printer_name',
                          'Nama Printer',
                          _settingsBox.get('printer_name'),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // === CARD KHUSUS QRIS (Sudah Terisi Otomatis) ===
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.03),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Row(
                          children: [
                            Icon(Icons.qr_code_2_rounded, color: Colors.blue),
                            SizedBox(width: 10),
                            Text(
                              "Data QRIS Statik",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          "Data di bawah otomatis dipakai untuk QRIS Dinamis. Pastikan kodenya benar.",
                          style: TextStyle(color: Colors.grey, fontSize: 12),
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _qrisCtrl,
                          maxLines: 3,
                          decoration: InputDecoration(
                            hintText: "Kode QRIS...",
                            hintStyle: TextStyle(
                              color: Colors.grey[400],
                              fontSize: 13,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide(
                                color: Colors.grey.shade300,
                              ),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide(
                                color: Colors.grey.shade300,
                              ),
                            ),
                            filled: true,
                            fillColor: const Color(0xFFF9FAFC),
                            contentPadding: const EdgeInsets.all(12),
                          ),
                        ),
                        const SizedBox(height: 12),
                        SizedBox(
                          width: double.infinity,
                          height: 45,
                          child: ElevatedButton.icon(
                            icon: const Icon(
                              Icons.save_rounded,
                              color: Colors.white,
                              size: 18,
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            onPressed: _saveQris,
                            label: const Text(
                              "Simpan Data QRIS",
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // ======================================
                  const SizedBox(height: 24),

                  // GROUP 3: SYSTEM
                  _SettingsGroup(
                    title: "SISTEM",
                    children: [
                      _SettingTile(
                        icon: Icons.cloud_upload_rounded,
                        color: Colors.teal,
                        title: "Backup Database",
                        subtitle: "Simpan data ke file lokal",
                        onTap: () => ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Fitur Backup akan segera hadir!'),
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // DANGER ZONE
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.red[50],
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.red.shade100),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Row(
                          children: [
                            Icon(
                              Icons.warning_amber_rounded,
                              color: Colors.red,
                            ),
                            SizedBox(width: 12),
                            Text(
                              "Zona Bahaya",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.red,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          "Reset akan menghapus semua produk & riwayat transaksi.",
                          style: TextStyle(color: Colors.red, fontSize: 12),
                        ),
                        const SizedBox(height: 16),
                        SizedBox(
                          width: double.infinity,
                          height: 45,
                          child: OutlinedButton(
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(color: Colors.red),
                              foregroundColor: Colors.red,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            onPressed: _resetDatabase,
                            child: const Text("Reset Database"),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 40),
                  Text(
                    "Agallagher POS v1.0",
                    style: TextStyle(
                      color: Colors.grey[400],
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1,
                    ),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// WIDGET HELPER
class _SettingsGroup extends StatelessWidget {
  final String title;
  final List<Widget> children;
  const _SettingsGroup({required this.title, required this.children});
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 8, bottom: 12),
          child: Text(
            title,
            style: TextStyle(
              color: Colors.grey[600],
              fontWeight: FontWeight.w700,
              fontSize: 12,
              letterSpacing: 1.2,
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.03),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(children: children),
        ),
      ],
    );
  }
}

class _SettingTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback? onTap;
  const _SettingTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    this.onTap,
  });
  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 22),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                        color: Color(0xFF2D3436),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: TextStyle(
                        color: Colors.grey[500],
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right_rounded, color: Colors.grey[300]),
            ],
          ),
        ),
      ),
    );
  }
}
