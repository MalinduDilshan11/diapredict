const express = require('express');
const mongoose = require('mongoose');
const cors = require('cors');

const app = express();
app.use(cors());
app.use(express.json());

// Connect to MongoDB Atlas
mongoose.connect(
  'mongodb+srv://malindu:123@cluster0.9sulaf9.mongodb.net/diapredict?retryWrites=true&w=majority'
)
.then(() => console.log('✅ MongoDB connected successfully'))
.catch((err) => console.error('❌ MongoDB connection error:', err));

// User Schema - Now includes 'name'
const userSchema = new mongoose.Schema({
  name: { type: String, required: true },                    // ← NEW: Full name
  email: { type: String, required: true, unique: true },
  password: { type: String, required: true },
  createdAt: { type: Date, default: Date.now },
});

const User = mongoose.model('User', userSchema);

// Signup route - Now accepts and saves 'name'
app.post('/signup', async (req, res) => {
  const { name, email, password } = req.body;

  // Validate all required fields
  if (!name || !email || !password) {
    return res.json({ 
      success: false, 
      message: 'Name, email and password are required' 
    });
  }

  try {
    // Check if email already exists
    const exists = await User.findOne({ email });
    if (exists) {
      return res.json({ 
        success: false, 
        message: 'User with this email already exists' 
      });
    }

    // Create and save new user
    const newUser = new User({ name, email, password });
    await newUser.save();

    console.log('🟢 New user registered:', name, '<', email, '>');
    res.json({ 
      success: true, 
      message: 'Signup successful' 
    });
  } catch (err) {
    console.error('❌ Signup error:', err);
    res.json({ 
      success: false, 
      message: 'Signup failed. Please try again.' 
    });
  }
});

// Login route - Still only uses email + password
app.post('/login', async (req, res) => {
  const { email, password } = req.body;

  if (!email || !password) {
    return res.json({ 
      success: false, 
      message: 'Email and password required' 
    });
  }

  try {
    const user = await User.findOne({ email, password });
    if (!user) {
      return res.json({ 
        success: false, 
        message: 'Invalid email or password' 
      });
    }

    console.log('✅ Login successful for:', user.name, '<', email, '>');
    res.json({ 
      success: true, 
      message: 'Login successful' 
    });
  } catch (err) {
    console.error('❌ Login error:', err);
    res.json({ 
      success: false, 
      message: 'Login failed' 
    });
  }
});

// Optional: Root route for testing
app.get('/', (req, res) => {
  res.send('DiaPredict Backend is running! 🚀');
});

// Start server - bind to all interfaces
app.listen(3000, '0.0.0.0', () => {
  console.log('🚀 Server running on http://localhost:3000');
});

// Optional: Log all users on startup (for debugging - remove later if needed)
User.find({})
  .then(users => {
    if (users.length > 0) {
      console.log('📋 Current users in database:');
      users.forEach(u => console.log(`   - ${u.name} (${u.email})`));
    }
  })
  .catch(err => console.error('Error reading users:', err));