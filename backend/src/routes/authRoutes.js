const express = require('express');
const { registerUser, loginUser, getMe } = require('../controllers/authController');
const { protect, authorize } = require('../middleware/auth');

const router = express.Router();

router.post('/register', protect, authorize('admin'), registerUser);
router.post('/login', loginUser);
router.get('/me', protect, getMe);

module.exports = router;
