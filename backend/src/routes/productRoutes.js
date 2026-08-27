const express = require('express');
const {
  getProducts,
  getProductById,
  createProduct,
  updateProduct,
  deleteProduct,
} = require('../controllers/productController');
const { protect, authorize } = require('../middleware/auth');

const router = express.Router();

// Kasir boleh melihat produk (untuk transaksi), hanya admin yang mengubah data
router
  .route('/')
  .get(protect, getProducts)
  .post(protect, authorize('admin'), createProduct);
router
  .route('/:id')
  .get(protect, getProductById)
  .put(protect, authorize('admin'), updateProduct)
  .delete(protect, authorize('admin'), deleteProduct);

module.exports = router;
