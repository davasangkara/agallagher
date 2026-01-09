import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../data/models/user_model.dart';
import '../../data/local/shared_pref_service.dart';
import '../dashboard/dashboard_page.dart';

class UsersPage extends StatefulWidget {
  const UsersPage({super.key});

  @override
  State<UsersPage> createState() => _UsersPageState();
}

class _UsersPageState extends State<UsersPage> {
  
  void _deleteUser(BuildContext context, UserModel user) async {
    final currentUser = await SharedPrefService.getName();
    if (user.name == currentUser) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Row(
              children: [
                Icon(Icons.warning_amber_rounded, color: Colors.white),
                SizedBox(width: 12),
                Text("Tidak bisa menghapus akun sendiri!"),
              ],
            ),
            backgroundColor: const Color(0xFFFC8181),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
      }
      return;
    }

    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        backgroundColor: Colors.white,
        title: Row(
          children: const [
            Icon(Icons.warning_rounded, color: Color(0xFFFC8181), size: 28),
            SizedBox(width: 12),
            Text(
              "Hapus Karyawan?", 
              style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF2D3748))
            ),
          ],
        ),
        content: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFFFFF5F5), Color(0xFFFED7D7)],
            ),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Text(
            "Akun ${user.name} akan dihapus permanen. Akses login akan hilang.",
            style: const TextStyle(color: Color(0xFF2D3748)),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text("Batal", style: TextStyle(color: Color(0xFF718096))),
          ),
          Container(
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFFC8181), Color(0xFFF56565)],
              ),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFFC8181).withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                shadowColor: Colors.transparent,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text("Hapus", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await user.delete();
      setState(() {});
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Row(
              children: [
                Icon(Icons.check_circle_rounded, color: Colors.white),
                SizedBox(width: 12),
                Text("User berhasil dihapus"),
              ],
            ),
            backgroundColor: const Color(0xFF48BB78),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
      }
    }
  }

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
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
            backgroundColor: Colors.white,
            title: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    user == null ? Icons.person_add_rounded : Icons.edit_rounded,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  user == null ? 'Tambah Karyawan' : 'Edit Karyawan',
                  style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF2D3748)),
                ),
              ],
            ),
            content: SizedBox(
              width: 400,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildTextField(
                      controller: nameCtrl,
                      label: 'Nama Lengkap',
                      icon: Icons.person_rounded,
                      iconColor: const Color(0xFF667EEA),
                    ),
                    const SizedBox(height: 16),
                    _buildTextField(
                      controller: emailCtrl,
                      label: 'Email',
                      icon: Icons.email_rounded,
                      iconColor: const Color(0xFF43E97B),
                    ),
                    const SizedBox(height: 16),
                    _buildTextField(
                      controller: pinCtrl,
                      label: 'PIN Akses (Login)',
                      icon: Icons.lock_rounded,
                      iconColor: const Color(0xFFFEAC5E),
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 16),
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            const Color(0xFFFAFBFF),
                            Colors.grey[50]!,
                          ],
                        ),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                      ),
                      child: DropdownButtonFormField<String>(
                        value: role,
                        decoration: const InputDecoration(
                          labelText: 'Jabatan',
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                          prefixIcon: Icon(Icons.badge_rounded, color: Color(0xFFFA709A)),
                        ),
                        items: const [
                          DropdownMenuItem(
                            value: 'admin',
                            child: Row(
                              children: [
                                Icon(Icons.admin_panel_settings_rounded, size: 20, color: Color(0xFF667EEA)),
                                SizedBox(width: 8),
                                Text('Admin (Full Akses)'),
                              ],
                            ),
                          ),
                          DropdownMenuItem(
                            value: 'kasir',
                            child: Row(
                              children: [
                                Icon(Icons.point_of_sale_rounded, size: 20, color: Color(0xFF43E97B)),
                                SizedBox(width: 8),
                                Text('Kasir (POS Only)'),
                              ],
                            ),
                          ),
                        ],
                        onChanged: (val) => setState(() => role = val!),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: isActive
                            ? [const Color(0xFFF0FFF4), const Color(0xFFC6F6D5)]
                            : [const Color(0xFFFFF5F5), const Color(0xFFFED7D7)],
                        ),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: isActive ? const Color(0xFF9AE6B4) : const Color(0xFFFCA5A5),
                        ),
                      ),
                      child: SwitchListTile(
                        title: const Text(
                          "Status Aktif",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Row(
                          children: [
                            Icon(
                              Icons.circle,
                              size: 8,
                              color: isActive ? const Color(0xFF48BB78) : const Color(0xFFFC8181),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              isActive ? "User bisa login" : "Akses dibekukan",
                              style: TextStyle(
                                color: isActive ? const Color(0xFF48BB78) : const Color(0xFFFC8181),
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                        value: isActive,
                        activeColor: const Color(0xFF48BB78),
                        onChanged: (val) => setState(() => isActive = val),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("Batal", style: TextStyle(color: Color(0xFF718096))),
              ),
              Container(
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
                  ),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF667EEA).withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: () {
                    if (nameCtrl.text.isEmpty || pinCtrl.text.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: const Row(
                            children: [
                              Icon(Icons.warning_amber_rounded, color: Colors.white),
                              SizedBox(width: 12),
                              Text("Nama dan PIN wajib diisi!"),
                            ],
                          ),
                          backgroundColor: const Color(0xFFFC8181),
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                      );
                      return;
                    }
                    
                    final box = Hive.box<UserModel>('users');
                    if (user == null) {
                      box.add(UserModel(
                        name: nameCtrl.text,
                        role: role,
                        email: emailCtrl.text,
                        pin: pinCtrl.text,
                        isActive: isActive,
                      ));
                    } else {
                      user.name = nameCtrl.text;
                      user.email = emailCtrl.text;
                      user.pin = pinCtrl.text;
                      user.role = role;
                      user.isActive = isActive;
                      user.save();
                    }
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: const Row(
                          children: [
                            Icon(Icons.check_circle_rounded, color: Colors.white),
                            SizedBox(width: 12),
                            Text("Data berhasil disimpan"),
                          ],
                        ),
                        backgroundColor: const Color(0xFF48BB78),
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    );
                  },
                  child: const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8),
                    child: Text(
                      "Simpan",
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required Color iconColor,
    TextInputType? keyboardType,
  }) {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFFAFBFF), Color(0xFFF8F9FE)],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          labelText: label,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          prefixIcon: Container(
            margin: const EdgeInsets.all(8),
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [iconColor.withOpacity(0.2), iconColor.withOpacity(0.1)],
              ),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: iconColor, size: 20),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final box = Hive.box<UserModel>('users');

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FE),
      body: Column(
        children: [
          // ================= HEADER =================
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Colors.white, Color(0xFFFAFBFF)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
              borderRadius: const BorderRadius.vertical(bottom: Radius.circular(32)),
              border: const Border(
                bottom: BorderSide(color: Color(0xFFE2E8F0), width: 1),
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF667EEA).withOpacity(0.08),
                  blurRadius: 24,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final isWide = constraints.maxWidth > 600;
                
                if (isWide) {
                  return Row(
                    children: [
                      InkWell(
                        onTap: () => Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (_) => const DashboardPage()),
                        ),
                        borderRadius: BorderRadius.circular(16),
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFFF0FFF4), Color(0xFFE0F2FE)],
                            ),
                            border: Border.all(color: const Color(0xFF9AE6B4)),
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF43E97B).withOpacity(0.2),
                                blurRadius: 8,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.arrow_back_ios_new_rounded,
                            size: 20,
                            color: Color(0xFF48BB78),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: const [
                                Icon(Icons.people_rounded, color: Color(0xFF667EEA), size: 24),
                                SizedBox(width: 8),
                                Flexible(
                                  child: Text(
                                    'Karyawan',
                                    style: TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.w900,
                                      color: Color(0xFF2D3748),
                                      letterSpacing: -0.5,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [Color(0xFFE0E7FF), Color(0xFFFCE7F3)],
                                ),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Text(
                                '✨ Kelola akses & tim',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: Color(0xFF667EEA),
                                  fontWeight: FontWeight.w600,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          gradient: const LinearGradient(
                            colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF667EEA).withOpacity(0.4),
                              blurRadius: 16,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: ElevatedButton.icon(
                          onPressed: () => _showUserForm(context),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            shadowColor: Colors.transparent,
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          ),
                          icon: const Icon(Icons.person_add_rounded, color: Colors.white, size: 20),
                          label: const Text(
                            'Tambah',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                } else {
                  return Column(
                    children: [
                      Row(
                        children: [
                          InkWell(
                            onTap: () => Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(builder: (_) => const DashboardPage()),
                            ),
                            borderRadius: BorderRadius.circular(16),
                            child: Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [Color(0xFFF0FFF4), Color(0xFFE0F2FE)],
                                ),
                                border: Border.all(color: const Color(0xFF9AE6B4)),
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(0xFF43E97B).withOpacity(0.2),
                                    blurRadius: 8,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: const Icon(
                                Icons.arrow_back_ios_new_rounded,
                                size: 20,
                                color: Color(0xFF48BB78),
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          const Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Icon(Icons.people_rounded, color: Color(0xFF667EEA), size: 24),
                                    SizedBox(width: 8),
                                    Text(
                                      'Karyawan',
                                      style: TextStyle(
                                        fontSize: 22,
                                        fontWeight: FontWeight.w900,
                                        color: Color(0xFF2D3748),
                                        letterSpacing: -0.5,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                            gradient: const LinearGradient(
                              colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF667EEA).withOpacity(0.4),
                                blurRadius: 16,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          child: ElevatedButton.icon(
                            onPressed: () => _showUserForm(context),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.transparent,
                              shadowColor: Colors.transparent,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                            ),
                            icon: const Icon(Icons.person_add_rounded, color: Colors.white, size: 20),
                            label: const Text(
                              'Tambah Karyawan',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                }
              },
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
                        Container(
                          padding: const EdgeInsets.all(32),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFFFAFBFF), Color(0xFFF8F9FE)],
                            ),
                            shape: BoxShape.circle,
                            border: Border.all(color: const Color(0xFFE2E8F0), width: 2),
                          ),
                          child: Icon(
                            Icons.people_outline_rounded,
                            size: 80,
                            color: Colors.grey[300],
                          ),
                        ),
                        const SizedBox(height: 24),
                        const Text(
                          'Belum ada data karyawan',
                          style: TextStyle(
                            color: Color(0xFFA0AEC0),
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Klik tombol "Tambah" untuk menambah karyawan',
                          style: TextStyle(
                            color: Color(0xFFCBD5E0),
                            fontSize: 14,
                          ),
                        ),
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
}

// Widget Kartu Karyawan
class _UserCard extends StatefulWidget {
  final UserModel user;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _UserCard({
    required this.user,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  State<_UserCard> createState() => _UserCardState();
}

class _UserCardState extends State<_UserCard> {
  bool isHovered = false;

  @override
  Widget build(BuildContext context) {
    final isAdmin = widget.user.role == 'admin';
    final gradientColors = isAdmin
        ? [const Color(0xFF667EEA), const Color(0xFF764BA2)]
        : [const Color(0xFF43E97B), const Color(0xFF38F9D7)];
    
    return MouseRegion(
      onEnter: (_) => setState(() => isHovered = true),
      onExit: (_) => setState(() => isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        transform: Matrix4.identity()..scale(isHovered ? 1.02 : 1.0),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Colors.white, Color(0xFFFAFBFF)],
          ),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: isHovered
                ? gradientColors[0].withOpacity(0.3)
                : const Color(0xFFE2E8F0),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: isHovered
                  ? gradientColors[0].withOpacity(0.15)
                  : Colors.grey.withOpacity(0.06),
              blurRadius: isHovered ? 24 : 16,
              offset: Offset(0, isHovered ? 12 : 8),
            ),
          ],
        ),
        child: Row(
          children: [
            // Avatar Gradient
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: gradientColors),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: gradientColors[0].withOpacity(0.4),
                    blurRadius: 12,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Center(
                child: Text(
                  widget.user.name.isNotEmpty ? widget.user.name[0].toUpperCase() : '?',
                  style: const TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 20),
            
            // Info User
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.user.name,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2D3748),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Icon(
                        Icons.email_rounded,
                        size: 14,
                        color: Colors.grey[400],
                      ),
                      const SizedBox(width: 6),
                      Text(
                        widget.user.email.isEmpty ? "Tanpa Email" : widget.user.email,
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey[400],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(colors: gradientColors),
                          borderRadius: BorderRadius.circular(10),
                          boxShadow: [
                            BoxShadow(
                              color: gradientColors[0].withOpacity(0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            Icon(
                              isAdmin ? Icons.admin_panel_settings_rounded : Icons.point_of_sale_rounded,
                              size: 14,
                              color: Colors.white,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              widget.user.role.toUpperCase(),
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: widget.user.isActive
                                ? [const Color(0xFFF0FFF4), const Color(0xFFC6F6D5)]
                                : [const Color(0xFFFFF5F5), const Color(0xFFFED7D7)],
                          ),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: widget.user.isActive
                                ? const Color(0xFF9AE6B4)
                                : const Color(0xFFFCA5A5),
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.circle,
                              size: 8,
                              color: widget.user.isActive
                                  ? const Color(0xFF48BB78)
                                  : const Color(0xFFFC8181),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              widget.user.isActive ? 'Active' : 'Suspended',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: widget.user.isActive
                                    ? const Color(0xFF48BB78)
                                    : const Color(0xFFFC8181),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            
            // Menu Opsi
            Container(
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFFAFBFF), Color(0xFFF8F9FE)],
                ),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: PopupMenuButton(
                icon: Icon(Icons.more_vert_rounded, color: Colors.grey[600]),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                itemBuilder: (ctx) => [
                  PopupMenuItem(
                    value: 'edit',
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: const Row(
                        children: [
                          Icon(Icons.edit_rounded, size: 20, color: Color(0xFF667EEA)),
                          SizedBox(width: 12),
                          Text('Edit', style: TextStyle(fontWeight: FontWeight.w600)),
                        ],
                      ),
                    ),
                  ),
                  PopupMenuItem(
                    value: 'delete',
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: const Row(
                        children: [
                          Icon(Icons.delete_rounded, size: 20, color: Color(0xFFFC8181)),
                          SizedBox(width: 12),
                          Text(
                            'Hapus',
                            style: TextStyle(
                              color: Color(0xFFFC8181),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
                onSelected: (val) => val == 'edit' ? widget.onEdit() : widget.onDelete(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}