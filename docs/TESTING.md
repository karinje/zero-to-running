# Testing Guide

This project includes comprehensive testing setup for backend, frontend, and end-to-end testing.

## Test Structure

```
backend/
  tests/
    unit/          # Unit tests
    integration/   # Integration tests
    fixtures/      # Test data

frontend/
  tests/
    unit/          # Component and utility tests

e2e/
  tests/           # End-to-end tests
  fixtures/        # E2E test data
```

## Running Tests

### All Tests

```bash
make test
```

### Backend Tests

```bash
# Run all backend tests
make test-backend

# Or directly
docker-compose exec backend npm test

# Watch mode
docker-compose exec backend npm run test:watch

# With coverage
docker-compose exec backend npm run test:coverage
```

### Frontend Tests

```bash
# Run all frontend tests
make test-frontend

# Or directly
docker-compose exec frontend npm test

# UI mode
docker-compose exec frontend npm run test:ui

# With coverage
docker-compose exec frontend npm run test:coverage
```

### E2E Tests

```bash
# Run E2E tests (requires services to be running)
make test-e2e

# Or directly
cd e2e && npm test

# Headed mode (see browser)
cd e2e && npm run test:headed

# UI mode
cd e2e && npm run test:ui
```

## Backend Testing (Jest)

### Writing Tests

```javascript
// tests/unit/example.test.js
const { myFunction } = require('../../src/utils/example');

describe('myFunction', () => {
  test('should return expected value', () => {
    expect(myFunction()).toBe('expected');
  });
});
```

### Integration Tests

```javascript
// tests/integration/api.test.js
const request = require('supertest');
const app = require('../../src/index');

describe('API Endpoints', () => {
  test('GET /health', async () => {
    const response = await request(app).get('/health');
    expect(response.status).toBe(200);
  });
});
```

### Coverage Goals

- **Unit tests**: 80%+ coverage
- **Integration tests**: All API endpoints
- **Database tests**: Connection and query tests

## Frontend Testing (Vitest)

### Component Tests

```javascript
// tests/unit/components.test.jsx
import { render, screen } from '@testing-library/react';
import MyComponent from '../../src/components/MyComponent';

describe('MyComponent', () => {
  test('renders correctly', () => {
    render(<MyComponent />);
    expect(screen.getByText('Hello')).toBeInTheDocument();
  });
});
```

### Coverage Goals

- **Unit tests**: 70%+ coverage
- **Component tests**: Critical components
- **Service tests**: API service layer

## E2E Testing (Playwright)

### Writing E2E Tests

```javascript
// e2e/tests/example.spec.js
import { test, expect } from '@playwright/test';

test('user can navigate to home page', async ({ page }) => {
  await page.goto('/');
  await expect(page).toHaveTitle(/Wander/i);
});
```

### E2E Test Scenarios

1. **Setup Workflow** - Verify services start correctly
2. **Health Checks** - All services respond
3. **API Integration** - Frontend-backend communication
4. **Database Connectivity** - Data persistence

## Test Fixtures

### Backend Fixtures

```javascript
// tests/fixtures/testData.js
module.exports = {
  sampleUser: {
    id: 1,
    name: 'Test User',
    email: 'test@example.com',
  },
};
```

### E2E Fixtures

```json
// e2e/fixtures/test-data.json
{
  "users": [
    {
      "name": "Test User",
      "email": "test@example.com"
    }
  ]
}
```

## Continuous Integration

Tests run automatically on:
- Pre-commit (via Husky)
- Pre-push (via Husky)
- CI/CD pipeline (when configured)

## Best Practices

1. **Write tests first** - TDD helps design better code
2. **Test behavior, not implementation** - Focus on what, not how
3. **Keep tests isolated** - Each test should be independent
4. **Use descriptive names** - Test names should explain what they test
5. **Mock external dependencies** - Don't rely on external services
6. **Maintain coverage** - Aim for high but meaningful coverage

## Troubleshooting

### Tests fail in Docker

Ensure services are running:
```bash
make dev
```

### E2E tests timeout

Increase timeout in `playwright.config.js`:
```javascript
use: {
  timeout: 60000, // 60 seconds
}
```

### Coverage not generating

Check that coverage is enabled:
```bash
npm run test:coverage
```

## Test Commands Reference

| Command | Description |
|---------|-------------|
| `make test` | Run all tests |
| `make test-backend` | Backend tests only |
| `make test-frontend` | Frontend tests only |
| `make test-e2e` | E2E tests only |
| `npm test` | Run tests (in container) |
| `npm run test:watch` | Watch mode |
| `npm run test:coverage` | Generate coverage report |

