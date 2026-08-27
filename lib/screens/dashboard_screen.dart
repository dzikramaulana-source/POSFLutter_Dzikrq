import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import 'kasir_screen.dart';
import 'product_screen.dart';
import 'report_screen.dart';
import 'user_management_screen.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  Future<void> _logout(BuildContext context) async {
    await context.read<AuthProvider>().logout();
    // AuthGate (home) otomatis menampilkan LoginScreen setelah _user = null
  }

  List<_MenuCard> _buildMenus(BuildContext context) {
    final user = context.read<AuthProvider>().user;
    final isAdmin = user?.role == 'admin';

    if (isAdmin) {
      // Admin: hanya menu Produk di grid; Laporan & Manajemen Kasir di AppBar
      return [
        _MenuCard(
          icon: Icons.inventory_2,
          label: 'Produk',
          color: Colors.blue,
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const ProductScreen()),
          ),
        ),
      ];
    }

    // Kasir: hanya pembayaran (Kasir) di grid; Laporan di AppBar
    return [
      _MenuCard(
        icon: Icons.point_of_sale,
        label: 'Kasir',
        color: Colors.green,
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const KasirScreen()),
        ),
      ),
    ];
  }

  List<Widget> _buildAppBarActions(BuildContext context) {
    final user = context.read<AuthProvider>().user;
    final isAdmin = user?.role == 'admin';

    return [
      // Laporan (tersedia untuk admin & kasir)
      IconButton(
        icon: const Icon(Icons.assessment),
        tooltip: 'Laporan',
        onPressed: () => Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const ReportScreen()),
        ),
      ),
      // Manajemen Karyawan/Kasir (khusus admin)
      if (isAdmin)
        IconButton(
          icon: const Icon(Icons.group),
          tooltip: 'Manajemen Karyawan',
          onPressed: () => Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const UserManagementScreen()),
          ),
        ),
      IconButton(
        icon: const Icon(Icons.logout),
        tooltip: 'Logout',
        onPressed: () => _logout(context),
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final user = authProvider.user;
    final name = user?.name ?? 'Pengguna';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard POS'),
        actions: _buildAppBarActions(context),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 20,
                      child: Text(
                        name.isNotEmpty ? name[0].toUpperCase() : '?',
                        style: const TextStyle(fontSize: 18),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Selamat datang, $name',
                            style: Theme.of(context).textTheme.titleSmall,
                          ),
                          Text(
                            '@${user?.username ?? ''} • ${user?.role ?? ''}',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: Colors.grey[600],
                                ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final spacing = 12.0;
                  final cellWidth = (constraints.maxWidth - spacing) / 2;
                  final cellHeight = (constraints.maxHeight - spacing) / 2;
                  return GridView.count(
                    crossAxisCount: 2,
                    mainAxisSpacing: spacing,
                    crossAxisSpacing: spacing,
                    physics: const NeverScrollableScrollPhysics(),
                    childAspectRatio: cellWidth / cellHeight,
                    children: _buildMenus(context),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MenuCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _MenuCard({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 40, color: color),
            const SizedBox(height: 8),
            Text(
              label,
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ],
        ),
      ),
    );
  }
}
