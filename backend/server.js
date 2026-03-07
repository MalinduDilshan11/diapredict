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
    console.error(' Signup error:', err);
    res.json({ 
      success: false, 
      message: 'Signup failed. Please try again.' 
    });
  }
});


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

    console.log(' Login successful for:', user.name, '<', email, '>');


    res.json({ 
      success: true, 
      message: 'Login successful',
      name: user.name,           
      email: user.email          
    });
  } catch (err) {
    console.error('❌ Login error:', err);
    res.json({ 
      success: false, 
      message: 'Login failed' 
    });
  }
});

app.get('/', (req, res) => {
  res.send('DiaPredict Backend is running! ');
});

// Start server - bind to all interfaces
app.listen(3000, '0.0.0.0', () => {
  console.log('🚀 Server running on http://localhost:3000');
});

User.find({})
  .then(users => {
    if (users.length > 0) {
      console.log('📋 Current users in database:');
      users.forEach(u => console.log(`   - ${u.name} (${u.email})`));
    }
  })
  .catch(err => console.error('Error reading users:', err));




  const riskSchema = new mongoose.Schema({
  email: { type: String, required: true },
  Age: { type: String, required: true },
  Sex: String,
  Height: Number,
  Weight: Number,
  BMI: Number,
  HighBP: { type: String, enum: ['Yes', 'No'] },
  HighChol: { type: String, enum: ['Yes', 'No'] },
  GenHlth: String,
  PhysActivity: { type: String, enum: ['Yes', 'No'] },
  Fruits: { type: String, enum: ['Yes', 'No'] },
  Veggies: { type: String, enum: ['Yes', 'No'] },
  DiffWalk: { type: String, enum: ['Yes', 'No'] },
  createdAt: { type: Date, default: Date.now }
});

const Risk = mongoose.model('Risk', riskSchema);

app.post('/risk', async (req, res) => {
  try {
    const newRisk = new Risk(req.body);
    await newRisk.save();

    console.log('Risk saved for email:', req.body.email);

    res.json({ success: true, message: 'Risk assessment saved successfully' });
  } catch (err) {
    console.error('Error saving risk:', err);
    res.json({ success: false, message: 'Failed to save risk assessment' });
  }
});


const predictionSchema = new mongoose.Schema({
  email: { type: String, required: true },
  predictedRisk: { type: String, required: true },
  updatedAt: { type: Date, default: Date.now }
});

const Prediction = mongoose.model('Prediction', predictionSchema);



app.post('/prediction', async (req, res) => {
  const { email, predictedRisk } = req.body;

  if (!email || !predictedRisk) {
    return res.json({ success: false, message: 'Email and predictedRisk are required' });
  }

  try {
    const updatedPrediction = await Prediction.findOneAndUpdate(
      { email },                    
      { predictedRisk, updatedAt: new Date() }, 
      { upsert: true, new: true }   
    );

    console.log(`Prediction saved for ${email}: ${predictedRisk}`);
    res.json({ success: true, message: 'Prediction saved successfully', prediction: updatedPrediction });
  } catch (err) {
    console.error('Error saving prediction:', err);
    res.json({ success: false, message: 'Failed to save prediction' });
  }
});


app.get('/prediction/:email', async (req, res) => {
  const { email } = req.params;

  try {
    const prediction = await Prediction.findOne({ email }).sort({ updatedAt: -1 });

    if (!prediction) {
      return res.json({ success: false, message: 'No prediction found' });
    }

    res.json({
      success: true,
      predictedRisk: prediction.predictedRisk,
      updatedAt: prediction.updatedAt
    });

  } catch (err) {
    console.error('Error fetching prediction:', err);
    res.json({ success: false, message: 'Failed to fetch prediction' });
  }
});

const nutritionSummarySchema = new mongoose.Schema({
  email: { type: String, required: true },
  riskLevel: { type: String, required: true },
  summary: { type: Object, required: true },
  createdAt: { type: Date, default: Date.now }
});

const NutritionSummary = mongoose.model("NutritionSummary", nutritionSummarySchema);

const nutritionSchema = new mongoose.Schema({
  foodName: { type: String, required: true, unique: true },
  glycemicIndex: Number,
  calories: Number,
  carbohydrates: Number,
  protein: Number,
  fat: Number
});
const Nutrition = mongoose.model('Nutrition', nutritionSchema);


const mealPlanSchema = new mongoose.Schema({
  email: { type: String, required: true },
  riskLevel: { type: String, required: true },
  plan: { type: Object, required: true },
  createdAt: { type: Date, default: Date.now }
});

const MealPlan = mongoose.model("MealPlan", mealPlanSchema);

// SAVE MEAL PLAN + NUTRITION SUMMARY
app.post('/mealplan', async (req, res) => {
  const { email, riskLevel, plan } = req.body;

  if (!email || !riskLevel || !plan) {
    return res.json({
      success: false,
      message: "email, riskLevel and plan are required"
    });
  }

  try {

    //  SAVE MEAL PLAN 
    const newPlan = new MealPlan({
      email,
      riskLevel,
      plan
    });

    await newPlan.save();

    console.log("Meal plan saved for:", email);


    // CALCULATE NUTRITION 
    const summary = {};

    for (const [day, meals] of Object.entries(plan)) {

      const dayTotals = {
        calories: 0,
        protein: 0,
        carbohydrates: 0,
        fat: 0,
        glycemicIndex: 0
      };

      let glycemicCount = 0;

      for (const meal of Object.values(meals)) {

        for (const foodList of Object.values(meal)) {

          for (const foodName of foodList) {

            const foodData = await Nutrition.findOne({ foodName });

            if (!foodData) {
              console.warn("Nutrition info missing for:", foodName);
              continue;
            }

            dayTotals.calories += foodData.calories || 0;
            dayTotals.protein += foodData.protein || 0;
            dayTotals.carbohydrates += foodData.carbohydrates || 0;
            dayTotals.fat += foodData.fat || 0;
            dayTotals.glycemicIndex += foodData.glycemicIndex || 0;

            glycemicCount++;
          }
        }
      }

      if (glycemicCount > 0) {
        dayTotals.glycemicIndex =
          +(dayTotals.glycemicIndex / glycemicCount).toFixed(2);
      }

      summary[day] = dayTotals;
    }


    //  SAVE SUMMARY 
    const newSummary = new NutritionSummary({
      email,
      riskLevel,
      summary
    });

    await newSummary.save();


    res.json({
      success: true,
      message: "Meal plan and nutrition summary saved successfully"
    });

  } catch (err) {

    console.error("Meal plan error:", err);

    res.json({
      success: false,
      message: "Failed to save meal plan"
    });
  }
});

// Get nutrition summary for a user
app.get('/nutrition_summary/:email', async (req, res) => {
  const { email } = req.params;
  try {
    const summary = await NutritionSummary.findOne({ email }).sort({ createdAt: -1 });
    if (!summary) return res.json({ success: false, message: 'No summary found' });
    res.json({ success: true, summary: summary.summary });
  } catch (err) {
    console.error('Error fetching nutrition summary:', err);
    res.json({ success: false, message: 'Failed to fetch nutrition summary' });
  }
});

app.get('/mealplan/:email', async (req, res) => {
  const { email } = req.params;

  try {
    const mealPlan = await MealPlan.findOne({ email }).sort({ createdAt: -1 });

    if (!mealPlan) {
      return res.json({
        success: false,
        message: "No meal plan found"
      });
    }

    res.json({
      success: true,
      plan: mealPlan.plan
    });

  } catch (err) {

    console.error("Error fetching meal plan:", err);

    res.json({
      success: false,
      message: "Failed to fetch meal plan"
    });

  }
});