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

async function createAdmin() {
  await mongoose.connect(process.env.MONGO_URI);

  const username = 'admin';
  const email    = 'admin@plantapp.com';
  const password = 'Admin@1234';

  const existing = await AuthModel.findOne({ $or: [{ username }, { email }] });
  if (existing) {
    console.log('Admin user already exists:', existing.username, '/', existing.email);
    await mongoose.disconnect();
    return;
  }

  const hashedPassword = await bcrypt.hash(password, 10);
  await AuthModel.create({
    userID:   'admin001',
    username,
    email,
    password: hashedPassword,
    role:     'admin',
  });

  console.log('✅ Admin user created!');
  console.log('   Username : admin');
  console.log('   Email    : admin@plantapp.com');
  console.log('   Password : Admin@1234');
  await mongoose.disconnect();
}

createAdmin().catch(console.error);
