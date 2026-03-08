const request = require('supertest');
const app = require('../server');   // Correct path
const mongoose = require('mongoose');
const { MongoMemoryServer } = require('mongodb-memory-server');

let mongoServer;

beforeAll(async () => {
  mongoServer = await MongoMemoryServer.create();
  const uri = mongoServer.getUri();
  await mongoose.connect(uri);
});

afterAll(async () => {
  await mongoose.disconnect();
  await mongoServer.stop();
});

describe('User Routes', () => {
  test('POST /signup - success', async () => {
    const res = await request(app)
      .post('/signup')
      .send({ name: 'Test User', email: 'test@example.com', password: 'pass123' });

    expect(res.statusCode).toBe(200);
    expect(res.body.success).toBe(true);
  });

  test('POST /signup - duplicate email', async () => {
    await request(app)
      .post('/signup')
      .send({ name: 'Dup', email: 'test@example.com', password: 'pass' });

    const res = await request(app)
      .post('/signup')
      .send({ name: 'Dup2', email: 'test@example.com', password: 'pass' });

    expect(res.body.success).toBe(false);
    expect(res.body.message).toContain('exists');
  });

  test('POST /login - success', async () => {
    const res = await request(app)
      .post('/login')
      .send({ email: 'test@example.com', password: 'pass123' });

    expect(res.statusCode).toBe(200);
    expect(res.body.success).toBe(true);
    expect(res.body.name).toBe('Test User');
  });

  test('POST /login - invalid creds', async () => {
    const res = await request(app)
      .post('/login')
      .send({ email: 'test@example.com', password: 'wrong' });

    expect(res.body.success).toBe(false);
  });
});

describe('Risk and Prediction Routes', () => {
  test('POST /risk - save assessment', async () => {
    const data = {
      email: 'test@example.com',
      Age: '30-34',
      Sex: 'Male',
      BMI: 25,
      HighBP: 'No',
      HighChol: 'No',
      GenHlth: 'Good',
      PhysActivity: 'Yes',
      Fruits: 'Yes',
      Veggies: 'Yes',
      DiffWalk: 'No'
    };

    const res = await request(app).post('/risk').send(data);
    expect(res.body.success).toBe(true);
  });

  test('POST /prediction - save and GET', async () => {
    await request(app)
      .post('/prediction')
      .send({ email: 'test@example.com', predictedRisk: 'LOW' });

    const res = await request(app).get('/prediction/test@example.com');

    expect(res.body.success).toBe(true);
    expect(res.body.predictedRisk).toBe('LOW');
  });
});

describe('Meal Plan Routes', () => {
  test('POST /mealplan - save and GET', async () => {
    const plan = {
      day01: {
        breakfast: { protein: ['Eggs'], staple: ['Bread'] },
        lunch: { protein: ['Chicken'], vegetable: ['Salad'] }
      }
    };

    await request(app)
      .post('/mealplan')
      .send({ email: 'test@example.com', riskLevel: 'LOW', plan });

    const res = await request(app).get('/mealplan/test@example.com');

    expect(res.body.success).toBe(true);
    expect(res.body.plan).toEqual(expect.objectContaining(plan));
  });

  test('GET /nutrition_summary', async () => {
  const res = await request(app).get('/nutrition_summary/test@example.com');
  expect(res.statusCode).toBe(200);
});
});