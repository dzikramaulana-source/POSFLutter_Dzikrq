const express = require('express');
const {
  getKasir,
  createKasir,
  updateKasir,
  deleteKasir,
} = require('../controllers/userController');
const { protect, authorize } = require('../middleware/auth');

const router = express.Router();

router
  .route('/')
  .get(protect, authorize('admin'), getKasir)
  .post(protect, authorize('admin'), createKasir);
router
  .route('/:id')
  .put(protect, authorize('admin'), updateKasir)
  .delete(protect, authorize('admin'), deleteKasir);

module.exports = router;
