const request = require('supertest');
const app = require('../../src/index');

describe('API Integration Tests', () => {
  test('GET / should return API info', async () => {
    const response = await request(app).get('/');
    expect(response.status).toBe(200);
    expect(response.body).toHaveProperty('message');
    expect(response.body).toHaveProperty('version');
  });

  test('GET /api/v1 should return API routes', async () => {
    const response = await request(app).get('/api/v1');
    expect(response.status).toBe(200);
  });
});

