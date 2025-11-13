// Test setup file
// This runs before all tests

// Set test environment
process.env.NODE_ENV = 'test';
process.env.LOG_LEVEL = 'error'; // Suppress logs during tests

// Increase timeout for integration tests
jest.setTimeout(10000);

