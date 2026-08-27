const User = require('../models/User');
const jwt = require('jsonwebtoken');

const generateToken = (id) => {
  return jwt.sign({ id }, process.env.JWT_SECRET, {
    expiresIn: process.env.JWT_EXPIRES_IN || '7d',
  });
};

// @desc    Register user baru
// @route   POST /api/auth/register
// @access  Private (admin)
const registerUser = async (req, res) => {
  try {
    const { username, password, name, role } = req.body;

    if (!username || !password || !name) {
      return res.status(400).json({ message: 'Username, password, dan nama wajib diisi' });
    }

    const userExists = await User.findOne({ username: username.toLowerCase() });
    if (userExists) {
      return res.status(400).json({ message: 'Username sudah terdaftar' });
    }

    const user = await User.create({
      username,
      password,
      name,
      role: role || 'kasir',
    });

    res.status(201).json({
      message: 'Registrasi berhasil',
      user,
      token: generateToken(user._id),
    });
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};

// @desc    Login user
// @route   POST /api/auth/login
// @access  Public
const loginUser = async (req, res) => {
  try {
    const { username, password } = req.body;

    if (!username || !password) {
      return res.status(400).json({ message: 'Username dan password wajib diisi' });
    }

    const user = await User.findOne({ username: username.toLowerCase() });
    if (!user || user.password !== password) {
      return res.status(401).json({ message: 'Username atau password salah' });
    }

    res.json({
      message: 'Login berhasil',
      user,
      token: generateToken(user._id),
    });
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};

// @desc    Get data user yang sedang login
// @route   GET /api/auth/me
// @access  Private
const getMe = async (req, res) => {
  res.json({ user: req.user });
};

module.exports = { registerUser, loginUser, getMe };
