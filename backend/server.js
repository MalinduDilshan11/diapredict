const express = require('express');
const mongoose = require('mongoose');
const cors = require('cors');

const app = express();
app.use(cors());
app.use(express.json());

mongoose.connect(
  'mongodb+srv://malindu:123@cluster0.9sulaf9.mongodb.net/diapredict'
)
.then(() => console.log('✅ MongoDB connected'))
.catch((err) => console.error('MongoDB connection error:', err));


// User Schema
const userSchema = new mongoose.Schema({
  email: { type: String, required: true, unique: true },
  password: { type: String, required: true },
  createdAt: { type: Date, default: Date.now },
});

const User = mongoose.model('User', userSchema);

// Signup route
app.post('/signup', async (req, res) => {
  const { email, password } = req.body;

  if (!email || !password) return res.json({ success: false, message: 'Email and password required' });

  try {
    const exists = await User.findOne({ email });
    if (exists) return res.json({ success: false, message: 'User already exists' });

    const newUser = new User({ email, password });
    await newUser.save();

    console.log('🟢 User saved:', email);
    res.json({ success: true, message: 'Signup successful' });
  } catch (err) {
    console.error('Signup error:', err);
    res.json({ success: false, message: 'Signup failed' });
  }
});

// Login route
app.post('/login', async (req, res) => {
  const { email, password } = req.body;

  if (!email || !password) return res.json({ success: false, message: 'Email and password required' });

  try {
    const user = await User.findOne({ email, password });
    if (!user) return res.json({ success: false, message: 'Invalid email or password' });

    console.log('✅ Login success for', email);
    res.json({ success: true, message: 'Login successful' });
  } catch (err) {
    console.error('Login error:', err);
    res.json({ success: false, message: 'Login failed' });
  }
});


app.listen(3000, '0.0.0.0', () => console.log(' Server running on port 3000'));

User.find().then(users => console.log('All users in DB:', users));

