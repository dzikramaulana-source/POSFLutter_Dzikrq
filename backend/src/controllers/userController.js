const User = require('../models/User');

// @desc    Get all kasir
// @route   GET /api/users?search=
// @access  Private (admin)
const getKasir = async (req, res) => {
  try {
    const { search } = req.query;
    const filter = { role: 'kasir' };

    if (search) {
      filter.$or = [
        { name: { $regex: search, $options: 'i' } },
        { username: { $regex: search, $options: 'i' } },
      ];
    }

    const kasir = await User.find(filter).sort({ createdAt: -1 });
    res.json({ users: kasir });
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};

// @desc    Create kasir baru
// @route   POST /api/users
// @access  Private (admin)
const createKasir = async (req, res) => {
  try {
    const { username, password, name } = req.body;

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
      role: 'kasir',
    });

    res.status(201).json({ message: 'Kasir berhasil ditambahkan', user });
  } catch (error) {
    if (error.code === 11000) {
      return res.status(400).json({ message: 'Username sudah digunakan' });
    }
    res.status(500).json({ message: error.message });
  }
};

// @desc    Update kasir
// @route   PUT /api/users/:id
// @access  Private (admin)
const updateKasir = async (req, res) => {
  try {
    const { username, password, name } = req.body;

    const user = await User.findById(req.params.id);
    if (!user || user.role !== 'kasir') {
      return res.status(404).json({ message: 'Kasir tidak ditemukan' });
    }

    if (username && username.toLowerCase() !== user.username) {
      const userExists = await User.findOne({ username: username.toLowerCase() });
      if (userExists) {
        return res.status(400).json({ message: 'Username sudah digunakan' });
      }
      user.username = username;
    }

    if (name) user.name = name;
    if (password) user.password = password;

    await user.save();
    res.json({ message: 'Kasir berhasil diperbarui', user });
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};

// @desc    Delete kasir
// @route   DELETE /api/users/:id
// @access  Private (admin)
const deleteKasir = async (req, res) => {
  try {
    const user = await User.findById(req.params.id);
    if (!user || user.role !== 'kasir') {
      return res.status(404).json({ message: 'Kasir tidak ditemukan' });
    }
    await user.deleteOne();
    res.json({ message: 'Kasir berhasil dihapus' });
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};

module.exports = { getKasir, createKasir, updateKasir, deleteKasir };
