import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/transaction.dart';
import '../utils/formatter.dart';
import '../utils/payment_method.dart';
import '../utils/receipt_printer.dart';

/// Halaman detail transaksi.
///
/// Dibuka dari Daftar Transaksi (Laporan) berdasarkan transaksi yang dipilih.
/// Menampilkan nomor, tanggal, waktu, metode pembayaran, rincian item,
/// total pembayaran, serta tombol cetak/download struk.
class TransactionDetailScreen extends StatelessWidget {
  final Transaction transaction;

  const TransactionDetailScreen({super.key, required this.transaction});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail Transaksi'),
        actions: [
          IconButton(
            icon: const Icon(Icons.download),
            tooltip: 'Download Struk',
            onPressed: () => ReceiptPrinter.downloadReceipt(transaction),
          ),
          IconButton(
            icon: const Icon(Icons.print),
            tooltip: 'Cetak Struk',
            onPressed: () => ReceiptPrinter.printReceipt(transaction),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Kartu info transaksi: nomor, tanggal, waktu, metode bayar
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'No. Transaksi',
                    style: Theme.of(context)
                        .textTheme
                        .bodySmall
                        ?.copyWith(color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    transaction.invoiceNumber,
                    style: Theme.of(context)
                        .textTheme
                        .titleMedium
                        ?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const Divider(height: 24),
                  _InfoRow(
                    icon: Icons.event,
                    label: 'Tanggal',
                    value:
                        DateFormat('EEEE, dd MMMM yyyy', 'id_ID').format(
                      transaction.createdAt,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _InfoRow(
                    icon: Icons.schedule,
                    label: 'Waktu',
                    value:
                        DateFormat('HH:mm:ss', 'id_ID').format(
                      transaction.createdAt,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _InfoRow(
                    icon: Icons.person_outline,
                    label: 'Kasir',
                    value: transaction.createdByName,
                  ),
                  const SizedBox(height: 12),
                  _InfoRow(
                    icon: paymentIcon(transaction.paymentMethod),
                    label: 'Metode Pembayaran',
                    value: paymentLabel(transaction.paymentMethod),
                    iconColor: paymentColor(transaction.paymentMethod),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text('Rincian Item', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          // Daftar item
          Card(
            child: Column(
              children: [
                ...transaction.items.map((item) {
                  return ListTile(
                    dense: true,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 4,
                    ),
                    title: Text(
                      item.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    subtitle: Text(
                      '${formatNumber(item.qty)} × ${formatRupiah(item.price)}',
                    ),
                    trailing: Text(
                      formatRupiah(item.subtotal),
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                  );
                }),
                const Divider(height: 1),
                ListTile(
                  dense: true,
                  title: const Text('Subtotal'),
                  trailing: Text(formatRupiah(transaction.total)),
                ),
                const Divider(height: 1),
                ListTile(
                  dense: true,
                  title: const Text(
                    'Total Pembayaran',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  trailing: Text(
                    formatRupiah(transaction.total),
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
                if (transaction.paymentMethod == 'cash') ...[
                  ListTile(
                    dense: true,
                    title: const Text('Uang Diterima'),
                    trailing: Text(formatRupiah(transaction.cashReceived)),
                  ),
                  ListTile(
                    dense: true,
                    title: const Text('Kembalian'),
                    trailing: Text(formatRupiah(transaction.change)),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Laba transaksi ini: ${formatRupiah(transaction.profit)}',
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color? iconColor;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 20, color: iconColor ?? Colors.grey[600]),
        const SizedBox(width: 10),
        Expanded(
          child: Text(label, style: Theme.of(context).textTheme.bodyMedium),
        ),
        Text(
          value,
          style: const TextStyle(fontWeight: FontWeight.w600),
          textAlign: TextAlign.end,
        ),
      ],
    );
  }
}
