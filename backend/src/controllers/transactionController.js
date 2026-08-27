const Transaction = require('../models/Transaction');
const Product = require('../models/Product');

// @desc    Buat transaksi baru + kurangi stok
// @route   POST /api/transactions
// @access  Private
const createTransaction = async (req, res) => {
  try {
    const { items, paymentMethod, cashReceived } = req.body;

    if (!items || !Array.isArray(items) || items.length === 0) {
      return res.status(400).json({ message: 'Keranjang belanja kosong' });
    }

    const user = req.user;

    // Validasi & siapkan data transaksi
    const txItems = [];
    let total = 0;
    let totalCost = 0;

    for (const item of items) {
      if (!item.product || !item.qty || item.qty <= 0) {
        return res.status(400).json({ message: 'Data item tidak valid' });
      }

      const product = await Product.findById(item.product);
      if (!product) {
        return res.status(404).json({ message: `Produk tidak ditemukan: ${item.product}` });
      }

      if (product.stock < item.qty) {
        return res.status(400).json({
          message: `Stok "${product.name}" tidak cukup (tersisa ${product.stock})`,
        });
      }

      // Kurangi stok
      product.stock -= item.qty;
      await product.save();

      const subtotal = product.price * item.qty;
      total += subtotal;
      totalCost += product.cost * item.qty;

      txItems.push({
        product: product._id,
        name: product.name,
        price: product.price,
        cost: product.cost,
        qty: item.qty,
        subtotal,
      });
    }

    // Generate nomor invoice: TRX-YYYYMMDD-XXXX
    const dateStr = new Date().toISOString().slice(0, 10).replace(/-/g, '');
    const todayStart = new Date();
    todayStart.setHours(0, 0, 0, 0);
    const todayEnd = new Date();
    todayEnd.setHours(23, 59, 59, 999);
    const count = await Transaction.countDocuments({
      createdAt: { $gte: todayStart, $lt: todayEnd },
    });
    const invoiceNumber = `TRX-${dateStr}-${String(count + 1).padStart(4, '0')}`;

    // Hitung kembalian
    const change = paymentMethod === 'cash' && cashReceived ? cashReceived - total : 0;
    if (change < 0) {
      return res.status(400).json({ message: 'Uang yang diterima kurang dari total belanja' });
    }

    const transaction = await Transaction.create({
      invoiceNumber,
      items: txItems,
      total,
      totalCost,
      profit: total - totalCost,
      paymentMethod: paymentMethod || 'cash',
      cashReceived: paymentMethod === 'cash' ? cashReceived || 0 : 0,
      change,
      createdBy: user._id,
    });

    const populated = await Transaction.findById(transaction._id).populate('createdBy', 'name username');
    res.status(201).json({
      message: 'Transaksi berhasil',
      transaction: populated,
    });
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};

// @desc    Get all transactions (opsional filter tanggal)
// @route   GET /api/transactions?date=YYYY-MM-DD
// @access  Private
const getTransactions = async (req, res) => {
  try {
    const { date, limit } = req.query;
    const filter = {};

    if (date) {
      const start = new Date(date);
      start.setHours(0, 0, 0, 0);
      const end = new Date(date);
      end.setHours(23, 59, 59, 999);
      filter.createdAt = { $gte: start, $lte: end };
    }

    const transactions = await Transaction.find(filter)
      .populate('createdBy', 'name username')
      .sort({ createdAt: -1 })
      .limit(parseInt(limit) || 100);

    res.json({ transactions });
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};

// @desc    Get single transaction
// @route   GET /api/transactions/:id
// @access  Private
const getTransactionById = async (req, res) => {
  try {
    const transaction = await Transaction.findById(req.params.id).populate(
      'createdBy',
      'name username'
    );
    if (!transaction) {
      return res.status(404).json({ message: 'Transaksi tidak ditemukan' });
    }
    res.json({ transaction });
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};

module.exports = { createTransaction, getTransactions, getTransactionById };
