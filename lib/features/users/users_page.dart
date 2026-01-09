import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../data/models/user_model.dart';
import '../dashboard/dashboard_page.dart';

class UsersPage extends StatefulWidget {
  const UsersPage({super.key});

  @override
  State<UsersPage> createState() => _UsersPageState();
}

class _UsersPageState extends State<UsersPage> {
  @override
  Widget build(BuildContext context) {
    // Pastikan box 'users' sudah dibuka di main.dart
    final box = Hive.box<UserModel>('users');

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FD),
      body: Column(
        children: [
          // ================= HEADER =================
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: const BorderRadius.vertical(bottom: Radius.circular(32)),
              boxShadow: [
                BoxShadow(color: Colors.blueGrey.withOpacity(0.06), blurRadius: 30, offset: const Offset(0, 10))
              ],
            ),
            child: Row(
              children: [
                InkWell(
                  onTap: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const DashboardPage())),
                  borderRadius: BorderRadius.circular(14),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.grey[50],
                      border: Border.all(color: Colors.grey.shade200),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Icon(Icons.arrow_back_ios_new_rounded, size: 20, color: Colors.black87),
                  ),
                ),
                const SizedBox(width: 24),
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Karyawan', 
                      style: TextStyle(fontSize: 26, fontWeight: FontWeight.w900, color: Color(0xFF2D3436), letterSpacing: -0.5)
                    ),
                    SizedBox(height: 4),
                    Text('Kelola akses & tim toko', style: TextStyle(fontSize: 13, color: Colors.grey, fontWeight: FontWeight.w600)),
                  ],
                ),
                const Spacer(),
                
                // Tombol Tambah
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    gradient: const LinearGradient(colors: [Color(0xFF6C63FF), Color(0xFF4834D4)]),
                    boxShadow: [BoxShadow(color: const Color(0xFF6C63FF).withOpacity(0.4), blurRadius: 15, offset: const Offset(0, 8))]
                  ),
                  child: ElevatedButton.icon(
                    onPressed: () => _showUserForm(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                    icon: const Icon(Icons.person_add_rounded, color: Colors.white, size: 20),
                    label: const Text('Tambah', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                  ),
                )
              ],
            ),
          ),

          // ================= LIST KARYAWAN =================
          Expanded(
            child: ValueListenableBuilder(
              valueListenable: box.listenable(),
              builder: (context, Box<UserModel> box, _) {
                if (box.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.people_outline_rounded, size: 80, color: Colors.grey[300]),
                        const SizedBox(height: 16),
                        Text('Belum ada data karyawan', style: TextStyle(color: Colors.grey[400])),
                      ],
                    ),
                  );
                }

                return ListView.separated(
                  padding: const EdgeInsets.all(32),
                  itemCount: box.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 16),
                  itemBuilder: (context, index) {
                    final user = box.getAt(index)!;
                    return _UserCard(
                      user: user,
                      onEdit: () => _showUserForm(context, user: user),
                      onDelete: () => _deleteUser(context, user),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // Dialog Form Tambah/Edit User
  void _showUserForm(BuildContext context, {UserModel? user}) {
    final nameCtrl = TextEditingController(text: user?.name);
    final emailCtrl = TextEditingController(text: user?.email);
    final pinCtrl = TextEditingController(text: user?.pin);
    String role = user?.role ?? 'kasir';
    bool isActive = user?.isActive ?? true;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            title: Text(user == null ? 'Tambah Karyawan' : 'Edit Karyawan', style: const TextStyle(fontWeight: FontWeight.bold)),
            content: SizedBox(
              width: 400,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: nameCtrl,
                      decoration: const InputDecoration(labelText: 'Nama Lengkap', border: OutlineInputBorder()),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: emailCtrl,
                      decoration: const InputDecoration(labelText: 'Email', border: OutlineInputBorder()),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: pinCtrl,
                      decoration: const InputDecoration(labelText: 'PIN Akses (Login)', border: OutlineInputBorder()),
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      value: role,
                      decoration: const InputDecoration(labelText: 'Jabatan', border: OutlineInputBorder()),
                      items: const [
                        DropdownMenuItem(value: 'admin', child: Text('Admin (Full Akses)')),
                        DropdownMenuItem(value: 'kasir', child: Text('Kasir (POS Only)')),
                      ],
                      onChanged: (val) => setState(() => role = val!),
                    ),
                    const SizedBox(height: 16),
                    SwitchListTile(
                      title: const Text("Status Aktif"),
                      subtitle: Text(isActive ? "User bisa login" : "Akses dibekukan"),
                      value: isActive,
                      onChanged: (val) => setState(() => isActive = val),
                    )
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(context), child: const Text("Batal", style: TextStyle(color: Colors.grey))),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF6C63FF)),
                onPressed: () {
                  if (nameCtrl.text.isEmpty || pinCtrl.text.isEmpty) return;
                  
                  final box = Hive.box<UserModel>('users');
                  if (user == null) {
                    // Create
                    box.add(UserModel(name: nameCtrl.text, role: role, email: emailCtrl.text, pin: pinCtrl.text, isActive: isActive));
                  } else {
                    // Update
                    user.name = nameCtrl.text;
                    user.email = emailCtrl.text;
                    user.pin = pinCtrl.text;
                    user.role = role;
                    user.isActive = isActive;
                    user.save();
                  }
                  Navigator.pop(context);
                },
                child: const Text("Simpan", style: TextStyle(color: Colors.white)),
              ),
            ],
          );
        },
      ),
    );
  }

  void _deleteUser(BuildContext context, UserModel user) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Hapus User?"),
        content: Text("Yakin ingin menghapus ${user.name}?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Batal")),
          TextButton(
            onPressed: () {
              user.delete();
              Navigator.pop(ctx);
            },
            child: const Text("Hapus", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}

class _UserCard extends StatelessWidget {
  final UserModel user;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _UserCard({required this.user, required this.onEdit, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    final color = user.role == 'admin' ? const Color(0xFF6C63FF) : const Color(0xFF00B894);
    
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.06), blurRadius: 20, offset: const Offset(0, 8))],
      ),
      child: Row(
        children: [
          Container(
            width: 64, height: 64,
            decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(20)),
            child: Center(child: Text(user.name.isNotEmpty ? user.name[0].toUpperCase() : '?', style: TextStyle(fontSize: 26, fontWeight: FontWeight.w900, color: color))),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(user.name, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF2D3436))),
                const SizedBox(height: 4),
                Text(user.email, style: TextStyle(fontSize: 13, color: Colors.grey[400], fontWeight: FontWeight.w500)),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(6)),
                      child: Text(user.role.toUpperCase(), style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey[600])),
                    ),
                    const SizedBox(width: 8),
                    Icon(Icons.circle, size: 8, color: user.isActive ? Colors.green : Colors.red),
                    const SizedBox(width: 4),
                    Text(user.isActive ? 'Active' : 'Suspended', style: TextStyle(fontSize: 12, color: user.isActive ? Colors.green : Colors.red)),
                  ],
                ),
              ],
            ),
          ),
          PopupMenuButton(
            icon: Icon(Icons.more_vert_rounded, color: Colors.grey[400]),
            itemBuilder: (ctx) => [
              const PopupMenuItem(value: 'edit', child: Text('Edit')),
              const PopupMenuItem(value: 'delete', child: Text('Hapus', style: TextStyle(color: Colors.red))),
            ],
            onSelected: (val) => val == 'edit' ? onEdit() : onDelete(),
          ),
        ],
      ),
    );
  }
}