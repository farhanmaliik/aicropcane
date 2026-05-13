const mongoose = require('mongoose');
const bcrypt = require('bcrypt');
require('dotenv').config();

const authSchema = new mongoose.Schema({
  userID:   { type: String, required: true, unique: true },
  username: { type: String, required: true, unique: true },
  email:    { type: String, required: true, unique: true },
  password: { type: String, required: true },
  role:     { type: String, required: true, default: 'user' },
}, { timestamps: true });

const AuthModel = mongoose.models.auth || mongoose.model('auth', authSchema);

async function resetAdmin() {
  await mongoose.connect(process.env.MONGO_URI);
  console.log('Connected to MongoDB');

  const username = 'admin';
  const email    = 'admin@plantapp.com';
  const password = 'Admin@1234';
  const hashedPassword = await bcrypt.hash(password, 10);

  const result = await AuthModel.findOneAndUpdate(
    { username },
    { password: hashedPassword, email, role: 'admin' },
    { upsert: true, new: true }
  );

  console.log('Admin password reset successfully for:', result.username);
  console.log('You can now login with:');
  console.log('  Username: admin');
  console.log('  Password: Admin@1234');
  await mongoose.disconnect();
}

resetAdmin().catch(console.error);
