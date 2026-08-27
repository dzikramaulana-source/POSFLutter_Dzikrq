// Seed script: buat user admin awal
// Jalankan dengan: npm run seed
require('dotenv').config();
const mongoose = require('mongoose');
const User = require('./src/models/User');
const Product = require('./src/models/Product');

const seed = async () => {
  try {
    await mongoose.connect(process.env.MONGO_URI, { serverSelectionTimeoutMS: 5000 });
    console.log('Terhubung ke MongoDB...');

    // Buat admin
    const adminExists = await User.findOne({ username: 'admin' });
    if (!adminExists) {
      await User.create({
        username: 'admin',
        password: 'admin123',
        name: 'Administrator',
        role: 'admin',
      });
      console.log('✅ Admin dibuat: username=admin, password=admin123');
    } else {
      console.log('ℹ️ Admin sudah ada, dilewati.');
    }

    // Seed produk contoh jika kosong
    const productCount = await Product.countDocuments();
    if (productCount === 0) {
      await Product.create([
        { name: 'Kopi Hitam', sku: 'KOPI-001', price: 10000, cost: 5000, stock: 50, category: 'Minuman' },
        { name: 'Es Teh Manis', sku: 'TEH-001', price: 7000, cost: 3000, stock: 80, category: 'Minuman' },
        { name: 'Nasi Goreng', sku: 'NASGOR-001', price: 25000, cost: 15000, stock: 30, category: 'Makanan' },
        { name: 'Air Mineral 600ml', sku: 'AIR-001', price: 5000, cost: 3000, stock: 100, category: 'Minuman' },
        { name: 'Roti Bakar Coklat', sku: 'ROTI-001', price: 18000, cost: 10000, stock: 20, category: 'Makanan' },
      ]);
      console.log('✅ 5 produk contoh dibuat.');
    } else {
      console.log('ℹ️ Produk sudah ada, dilewati.');
    }

    await mongoose.disconnect();
    console.log('Seed selesai.');
    process.exit(0);
  } catch (error) {
    console.error('Seed gagal:', error.message);
    process.exit(1);
  }
};

seed();
