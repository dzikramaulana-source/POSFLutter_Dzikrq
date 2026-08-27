const express = require('express');
const { getDailyReport, getPeriodReport, getStockReport } = require('../controllers/reportController');
const { protect } = require('../middleware/auth');

const router = express.Router();

router.get('/daily', protect, getDailyReport);
router.get('/period', protect, getPeriodReport);
router.get('/stock', protect, getStockReport);

module.exports = router;
