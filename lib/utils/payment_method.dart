import 'package:flutter/material.dart';

/// Helper bersama untuk metode pembayaran (ikon, warna, label).
///
/// Dipakai di halaman kasir, laporan, dan detail transaksi agar konsisten.
IconData paymentIcon(String method) {
  return switch (method) {
    'qris' => Icons.qr_code,
    'debit' => Icons.credit_card,
    'transfer' => Icons.account_balance,
    _ => Icons.payments,
  };
}

Color paymentColor(String method) {
  return switch (method) {
    'qris' => Colors.teal,
    'debit' => Colors.blue,
    'transfer' => Colors.orange,
    _ => Colors.green,
  };
}

String paymentLabel(String method) {
  return switch (method) {
    'qris' => 'QRIS',
    'debit' => 'Debit',
    'transfer' => 'Transfer',
    _ => 'Tunai',
  };
}
