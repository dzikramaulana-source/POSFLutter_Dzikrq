import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../models/report.dart';
import '../models/transaction.dart';
import '../providers/report_provider.dart';
import '../utils/formatter.dart';
import '../utils/payment_method.dart';
import 'transaction_detail_screen.dart';

/// Periode laporan yang bisa dipilih user.
enum ReportPeriod {
  today('Hari ini'),
  yesterday('Kemarin'),
  last7('7 Hari Terakhir'),
  last30('30 Hari Terakhir'),
  thisMonth('Bulan Ini'),
  lastMonth('Bulan Lalu'),
  custom('Custom');

  const ReportPeriod(this.label);
  final String label;

  /// Hitung rentang tanggal untuk periode ini (berbasis sekarang).
  (DateTime, DateTime) range(DateTime now) {
    switch (this) {
      case ReportPeriod.today:
        return (DateTime(now.year, now.month, now.day),
            DateTime(now.year, now.month, now.day));
      case ReportPeriod.yesterday:
        final y = now.subtract(const Duration(days: 1));
        return (DateTime(y.year, y.month, y.day), DateTime(y.year, y.month, y.day));
      case ReportPeriod.last7:
        return (DateTime(now.year, now.month, now.day - 6),
            DateTime(now.year, now.month, now.day));
      case ReportPeriod.last30:
        return (DateTime(now.year, now.month, now.day - 29),
            DateTime(now.year, now.month, now.day));
      case ReportPeriod.thisMonth:
        return (DateTime(now.year, now.month, 1),
            DateTime(now.year, now.month + 1, 0));
      case ReportPeriod.lastMonth:
        return (DateTime(now.year, now.month - 1, 1),
            DateTime(now.year, now.month, 0));
      case ReportPeriod.custom:
        return (DateTime(now.year, now.month, now.day),
            DateTime(now.year, now.month, now.day));
    }
  }
}

class ReportScreen extends StatefulWidget {
  const ReportScreen({super.key});

  @override
  State<ReportScreen> createState() => _ReportScreenState();
}

class _ReportScreenState extends State<ReportScreen> {
  ReportPeriod _period = ReportPeriod.today;
  DateTime _customStart = DateTime.now();
  DateTime _customEnd = DateTime.now();

  @override
  void initState() {
    super.initState();
    _applyPeriod(ReportPeriod.today);
  }

  Future<void> _applyPeriod(ReportPeriod period) async {
    final (start, end) = period.range(DateTime.now());
    setState(() {
      _period = period;
      _customStart = start;
      _customEnd = end;
    });
    await context.read<ReportProvider>().load(start: start, end: end);
  }

  Future<void> _pickCustomRange() async {
    final now = DateTime.now();
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(now.year - 3),
      lastDate: now,
      initialDateRange: DateTimeRange(
        start: _customStart,
        end: _customEnd,
      ),
      helpText: 'Pilih Rentang Tanggal',
      saveText: 'Terapkan',
    );
    if (picked != null) {
      setState(() {
        _period = ReportPeriod.custom;
        _customStart = picked.start;
        _customEnd = picked.end;
      });
      if (!mounted) return;
      await context
          .read<ReportProvider>()
          .load(start: picked.start, end: picked.end);
    }
  }

  Future<void> _refresh() async {
    final provider = context.read<ReportProvider>();
    final start = provider.start;
    final end = provider.end;
    if (start != null && end != null) {
      await provider.load(start: start, end: end);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Laporan Penjualan')),
      body: Column(
        children: [
          _buildPeriodFilter(),
          const Divider(height: 1),
          Expanded(child: _buildBody()),
        ],
      ),
    );
  }

  Widget _buildPeriodFilter() {
    final provider = context.watch<ReportProvider>();
    final isCustom = _period == ReportPeriod.custom;

    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: 8,
            runSpacing: 6,
            children: ReportPeriod.values.map((p) {
              return ChoiceChip(
                label: Text(p.label),
                selected: _period == p,
                onSelected: (_) => _applyPeriod(p),
              );
            }).toList(),
          ),
          if (isCustom) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _pickCustomRange,
                    icon: const Icon(Icons.date_range, size: 18),
                    label: Text(
                      '${_fmtDate(_customStart)} – ${_fmtDate(_customEnd)}',
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
              ],
            ),
          ] else if (provider.start != null && provider.end != null) ...[
            const SizedBox(height: 8),
            Text(
              '${_fmtDate(provider.start!)} – ${_fmtDate(provider.end!)}',
              style: Theme.of(context)
                  .textTheme
                  .bodySmall
                  ?.copyWith(color: Colors.grey[600]),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildBody() {
    final provider = context.watch<ReportProvider>();

    if (provider.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (provider.error != null && provider.report == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.cloud_off, size: 48, color: Colors.grey),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Text(
                provider.error!,
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 12),
            FilledButton(
              onPressed: _refresh,
              child: const Text('Coba Lagi'),
            ),
          ],
        ),
      );
    }

    final report = provider.report;
    if (report == null) {
      return const Center(child: Text('Belum ada data'));
    }

    return RefreshIndicator(
      onRefresh: _refresh,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
        children: [
          _buildSummarySection(report),
          const SizedBox(height: 20),
          if (report.previousSummary != null) ...[
            _buildComparisonCard(report),
            const SizedBox(height: 20),
          ],
          _sectionTitle(context, 'Grafik Penjualan'),
          const SizedBox(height: 8),
          _SalesChartCard(chartData: report.chartData),
          const SizedBox(height: 20),
          _buildTopProductsAndPayment(report),
          const SizedBox(height: 20),
          _sectionTitle(context, 'Ringkasan Keuntungan'),
          const SizedBox(height: 8),
          _buildProfitCard(report.summary),
          const SizedBox(height: 20),
          _sectionTitle(context, 'Daftar Transaksi'),
          const SizedBox(height: 8),
          _buildTransactionList(report, provider),
        ],
      ),
    );
  }

  // ---------- Ringkasan ----------

  Widget _buildSummarySection(PeriodReport report) {
    final summary = report.summary;
    final items = <_SummaryCardData>[
      _SummaryCardData(
        icon: Icons.payments,
        label: 'Total Penjualan',
        value: formatRupiah(summary.totalRevenue),
        color: Colors.green,
      ),
      _SummaryCardData(
        icon: Icons.receipt_long,
        label: 'Transaksi',
        value: formatNumber(summary.totalTransactions),
        color: Colors.blue,
      ),
      _SummaryCardData(
        icon: Icons.shopping_bag,
        label: 'Produk Terjual',
        value: formatNumber(summary.unitsSold),
        color: Colors.indigo,
      ),
      _SummaryCardData(
        icon: Icons.trending_up,
        label: 'Rata-rata Transaksi',
        value: formatRupiah(summary.averageTransaction),
        color: Colors.purple,
      ),
      _SummaryCardData(
        icon: Icons.savings,
        label: 'Modal',
        value: formatRupiah(summary.totalCost),
        color: Colors.orange,
      ),
      _SummaryCardData(
        icon: Icons.account_balance_wallet,
        label: 'Laba',
        value: formatRupiah(summary.totalProfit),
        color: Colors.teal,
      ),
      _SummaryCardData(
        icon: Icons.percent,
        label: 'Margin',
        value: '${summary.margin.toStringAsFixed(1)}%',
        color: Colors.brown,
      ),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final cols = width >= 900
            ? 4
            : width >= 600
                ? 3
                : 2;
        const spacing = 12.0;
        final cardWidth = (width - spacing * (cols - 1)) / cols;
        return Wrap(
          spacing: spacing,
          runSpacing: spacing,
          children: items
              .map((item) => SizedBox(
                    width: cardWidth,
                    child: _SummaryCard(
                      icon: item.icon,
                      label: item.label,
                      value: item.value,
                      color: item.color,
                    ),
                  ))
              .toList(),
        );
      },
    );
  }

  // ---------- Perbandingan periode ----------

  Widget _buildComparisonCard(PeriodReport report) {
    final current = report.summary.totalRevenue;
    final previous = report.previousSummary!.totalRevenue;
    final delta = current - previous;
    final percent = previous > 0 ? (delta / previous) * 100 : (current > 0 ? 100.0 : 0.0);
    final isUp = delta >= 0;
    final color = isUp ? Colors.green : Colors.red;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Perbandingan Periode Sebelumnya',
                style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _comparisonItem(
                    'Periode Ini',
                    formatRupiah(current),
                    Colors.teal,
                  ),
                ),
                Expanded(
                  child: _comparisonItem(
                    'Periode Lalu',
                    formatRupiah(previous),
                    Colors.grey[600]!,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(isUp ? Icons.arrow_upward : Icons.arrow_downward,
                    color: color, size: 20),
                const SizedBox(width: 6),
                Text(
                  '${isUp ? '+' : ''}${percent.toStringAsFixed(1)}%',
                  style: TextStyle(
                    color: color,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  'dari periode sebelumnya',
                  style: Theme.of(context)
                      .textTheme
                      .bodySmall
                      ?.copyWith(color: Colors.grey[600]),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _comparisonItem(String label, String value, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: Theme.of(context)
                .textTheme
                .bodySmall
                ?.copyWith(color: Colors.grey[600])),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: color,
          ),
        ),
      ],
    );
  }

  // ---------- Produk terlaris + metode pembayaran ----------

  Widget _buildTopProductsAndPayment(PeriodReport report) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final wide = constraints.maxWidth >= 700;
        final topProducts = _buildTopProducts(report.topProducts);
        final payment = _buildPaymentSection(report.paymentSummary);

        if (wide) {
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(flex: 3, child: topProducts),
              const SizedBox(width: 16),
              Expanded(flex: 2, child: payment),
            ],
          );
        }
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            topProducts,
            const SizedBox(height: 16),
            payment,
          ],
        );
      },
    );
  }

  Widget _buildTopProducts(List<TopSellingProduct> products) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionTitle(context, 'Produk Terlaris'),
        const SizedBox(height: 8),
        if (products.isEmpty)
          const _EmptyCard(message: 'Belum ada penjualan pada periode ini')
        else
          Card(
            child: Column(
              children: List.generate(products.length, (index) {
                final p = products[index];
                return ListTile(
                  dense: true,
                  leading: CircleAvatar(
                    radius: 14,
                    child: Text('${index + 1}',
                        style: const TextStyle(fontSize: 12)),
                  ),
                  title: Text(p.name,
                      maxLines: 1, overflow: TextOverflow.ellipsis),
                  subtitle: Text('${formatNumber(p.qty)} terjual'),
                  trailing: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        formatRupiah(p.revenue),
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        'Laba ${formatRupiah(p.profit)}',
                        style: Theme.of(context)
                            .textTheme
                            .bodySmall
                            ?.copyWith(color: Colors.grey[600]),
                      ),
                    ],
                  ),
                );
              }),
            ),
          ),
      ],
    );
  }

  Widget _buildPaymentSection(List<PaymentMethodSummary> payment) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionTitle(context, 'Metode Pembayaran'),
        const SizedBox(height: 8),
        if (payment.isEmpty)
          const _EmptyCard(message: 'Belum ada data pembayaran')
        else
          Card(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                children: [
                  SizedBox(
                    height: 150,
                    child: _PaymentPieChart(payment: payment),
                  ),
                  const SizedBox(height: 12),
                  ...payment.map((p) {
                    return ListTile(
                      dense: true,
                      contentPadding: EdgeInsets.zero,
                      leading: Icon(
                        _paymentIcon(p.method),
                        color: _paymentColor(p.method),
                      ),
                      title: Text(_paymentLabel(p.method)),
                      subtitle: Text('${formatNumber(p.count)} transaksi'),
                      trailing: Text(
                        formatRupiah(p.total),
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    );
                  }),
                ],
              ),
            ),
          ),
      ],
    );
  }

  // ---------- Keuntungan ----------

  Widget _buildProfitCard(ReportSummary summary) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Expanded(
              child: _profitItem('Total Penjualan', formatRupiah(summary.totalRevenue)),
            ),
            Expanded(
              child: _profitItem('Total Modal', formatRupiah(summary.totalCost)),
            ),
            Expanded(
              child: _profitItem('Laba Kotor', formatRupiah(summary.totalProfit)),
            ),
            Expanded(
              child: _profitItem(
                  'Margin', '${summary.margin.toStringAsFixed(1)}%'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _profitItem(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: Theme.of(context)
                .textTheme
                .bodySmall
                ?.copyWith(color: Colors.grey[600])),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  // ---------- Daftar transaksi ----------

  Widget _buildTransactionList(PeriodReport report, ReportProvider provider) {
    final tx = report.transactions;
    if (tx.items.isEmpty) {
      return const _EmptyCard(message: 'Tidak ada transaksi pada periode ini');
    }

    return Column(
      children: [
        Card(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        '${formatNumber(tx.total)} transaksi',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ),
                    Text(
                      'Hal ${tx.page}/${tx.totalPages}',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),
              ...tx.items.map((t) => _TransactionTile(transaction: t)),
            ],
          ),
        ),
        if (provider.hasMore) ...[
          const SizedBox(height: 8),
          provider.isLoadingMore
              ? const Padding(
                  padding: EdgeInsets.all(8),
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : OutlinedButton.icon(
                  onPressed: provider.loadMore,
                  icon: const Icon(Icons.more_horiz),
                  label: const Text('Muat Lebih'),
                ),
        ],
      ],
    );
  }

  // ---------- Helper ----------

  Widget _sectionTitle(BuildContext context, String title) {
    return Text(title, style: Theme.of(context).textTheme.titleMedium);
  }

  String _fmtDate(DateTime d) => DateFormat('dd/MM/yyyy').format(d);
}

IconData _paymentIcon(String method) {
  return paymentIcon(method);
}

Color _paymentColor(String method) {
  return paymentColor(method);
}

String _paymentLabel(String method) {
  return paymentLabel(method);
}

class _SummaryCardData {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _SummaryCardData({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });
}

class _SummaryCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _SummaryCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 26),
            const SizedBox(height: 10),
            Text(
              value,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: Theme.of(context)
                  .textTheme
                  .bodySmall
                  ?.copyWith(color: Colors.grey[600]),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyCard extends StatelessWidget {
  final String message;

  const _EmptyCard({required this.message});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Text(message,
            style: TextStyle(color: Colors.grey[600])),
      ),
    );
  }
}

class _SalesChartCard extends StatelessWidget {
  final List<ChartPoint> chartData;

  const _SalesChartCard({required this.chartData});

  @override
  Widget build(BuildContext context) {
    if (chartData.isEmpty) {
      return const _EmptyCard(message: 'Belum ada data penjualan');
    }

    final maxTotal =
        chartData.map((e) => e.total).reduce((a, b) => a > b ? a : b);
    final maxY = maxTotal <= 0 ? 1.0 : maxTotal * 1.15;

    // Tampilkan subset label jika terlalu banyak
    final step = chartData.length > 12
        ? (chartData.length / 6).ceil()
        : 1;

    return Card(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 16, 20, 12),
        child: SizedBox(
          height: 220,
          child: BarChart(
            BarChartData(
              maxY: maxY,
              minY: 0,
              alignment: BarChartAlignment.spaceAround,
              gridData: FlGridData(
                show: true,
                drawVerticalLine: false,
                getDrawingHorizontalLine: (value) => FlLine(
                  color: Colors.grey.shade200,
                  strokeWidth: 1,
                ),
              ),
              borderData: FlBorderData(show: false),
              titlesData: FlTitlesData(
                topTitles:
                    const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                rightTitles:
                    const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 52,
                    getTitlesWidget: (value, meta) {
                      return Text(
                        _shortMoney(value),
                        style: const TextStyle(fontSize: 10),
                      );
                    },
                  ),
                ),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 28,
                    getTitlesWidget: (value, meta) {
                      final index = value.toInt();
                      if (index < 0 || index >= chartData.length) {
                        return const SizedBox.shrink();
                      }
                      if (index % step != 0) {
                        return const SizedBox.shrink();
                      }
                      return Padding(
                        padding: const EdgeInsets.only(top: 6),
                        child: Text(
                          _shortLabel(chartData[index].label),
                          style: const TextStyle(fontSize: 9),
                        ),
                      );
                    },
                  ),
                ),
              ),
              barTouchData: BarTouchData(
                touchTooltipData: BarTouchTooltipData(
                  getTooltipColor: (_) => Colors.teal.shade700,
                  getTooltipItem: (group, groupIndex, rod, rodIndex) {
                    final label = chartData[group.x].label;
                    return BarTooltipItem(
                      '$label\n${formatRupiah(rod.toY)}',
                      const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    );
                  },
                ),
              ),
              barGroups: List.generate(chartData.length, (index) {
                return BarChartGroupData(
                  x: index,
                  barRods: [
                    BarChartRodData(
                      toY: chartData[index].total,
                      width: chartData.length > 15 ? 6 : 14,
                      color: Colors.teal,
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(4),
                      ),
                    ),
                  ],
                );
              }),
            ),
          ),
        ),
      ),
    );
  }

  String _shortLabel(String label) {
    // "2026-08-22" -> "22/08", "04:00" tetap "04:00"
    if (label.contains('-')) {
      final parts = label.split('-');
      if (parts.length == 3) return '${parts[2]}/${parts[1]}';
    }
    return label;
  }

  String _shortMoney(double value) {
    if (value >= 1000000) {
      return '${(value / 1000000).toStringAsFixed(1)}jt';
    }
    if (value >= 1000) {
      return '${(value / 1000).toStringAsFixed(0)}rb';
    }
    return value.toStringAsFixed(0);
  }
}

class _PaymentPieChart extends StatelessWidget {
  final List<PaymentMethodSummary> payment;

  const _PaymentPieChart({required this.payment});

  @override
  Widget build(BuildContext context) {
    final total = payment.fold<double>(0, (sum, p) => sum + p.total);
    if (total <= 0) {
      return const Center(child: Text('Belum ada data'));
    }

    final colors = [
      Colors.teal,
      Colors.blue,
      Colors.orange,
      Colors.purple,
    ];

    return PieChart(
      PieChartData(
        sectionsSpace: 2,
        centerSpaceRadius: 28,
        sections: List.generate(payment.length, (index) {
          final p = payment[index];
          final percent = (p.total / total * 100).toStringAsFixed(0);
          return PieChartSectionData(
            value: p.total,
            color: colors[index % colors.length],
            radius: 36,
            title: '$percent%',
            titleStyle: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          );
        }),
      ),
    );
  }
}

class _TransactionTile extends StatelessWidget {
  final Transaction transaction;

  const _TransactionTile({required this.transaction});

  @override
  Widget build(BuildContext context) {
    final itemCount =
        transaction.items.fold<int>(0, (sum, i) => sum + i.qty);

    return ListTile(
      dense: true,
      title: Row(
        children: [
          Expanded(
            child: Text(
              transaction.invoiceNumber,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          Text(
            formatRupiah(transaction.total),
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ],
      ),
      subtitle: Padding(
        padding: const EdgeInsets.only(top: 2),
        child: Row(
          children: [
            Icon(_paymentIcon(transaction.paymentMethod),
                size: 14, color: _paymentColor(transaction.paymentMethod)),
            const SizedBox(width: 4),
            Text(_paymentLabel(transaction.paymentMethod)),
            const SizedBox(width: 12),
            Text('${formatNumber(itemCount)} item'),
          ],
        ),
      ),
      trailing: const Icon(Icons.chevron_right, size: 20),
      onTap: () => _showDetail(context),
    );
  }

  void _showDetail(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (context) => TransactionDetailScreen(transaction: transaction),
      ),
    );
  }
}

