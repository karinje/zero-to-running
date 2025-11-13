import { test, expect } from '@playwright/test';

test.describe('Health Checks', () => {
  test('frontend should be accessible', async ({ page }) => {
    await page.goto('/');
    await expect(page).toHaveTitle(/Wander/i);
  });

  test('backend health endpoint should respond', async ({ request }) => {
    const response = await request.get('http://localhost:4000/health');
    expect(response.ok()).toBeTruthy();
    const body = await response.json();
    expect(body).toHaveProperty('status', 'ok');
  });
});

