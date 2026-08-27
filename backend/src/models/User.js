const mongoose = require('mongoose');

const userSchema = new mongoose.Schema(
  {
    username: {
      type: String,
      required: [true, 'Username wajib diisi'],
      unique: true,
      trim: true,
      lowercase: true,
      minlength: [3, 'Username minimal 3 karakter'],
    },
    password: {
      type: String,
      required: [true, 'Password wajib diisi'],
      minlength: [6, 'Password minimal 6 karakter'],
    },
    name: {
      type: String,
      required: [true, 'Nama wajib diisi'],
      trim: true,
    },
    role: {
      type: String,
      enum: ['admin', 'kasir'],
      default: 'kasir',
    },
  },
  {
    timestamps: true,
  }
);

// Jangan kembalikan password di response JSON
userSchema.methods.toJSON = function () {
  const obj = this.toObject();
  delete obj.password;
  return obj;
};

module.exports = mongoose.model('User', userSchema);
