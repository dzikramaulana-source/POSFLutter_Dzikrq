const express = require('express');
const {
  createTransaction,
  getTransactions,
  getTransactionById,
} = require('../controllers/transactionController');
const { protect } = require('../middleware/auth');

const router = express.Router();

router.route('/').get(protect, getTransactions).post(protect, createTransaction);
router.route('/:id').get(protect, getTransactionById);

module.exports = router;
