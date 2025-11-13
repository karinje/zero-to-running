-- PostgreSQL Database Initialization Script
-- This script runs automatically when the database container is first created
-- It sets up the initial schema and any required extensions

-- Create extensions if needed
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "pg_trgm";

-- Create a schema for application tables (optional, but good practice)
CREATE SCHEMA IF NOT EXISTS app;

-- Set default search path
ALTER DATABASE wander_dev SET search_path TO app, public;

-- Example: Create a simple users table for demonstration
-- This can be removed or modified based on actual requirements
CREATE TABLE IF NOT EXISTS app.users (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    email VARCHAR(255) UNIQUE NOT NULL,
    name VARCHAR(255) NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Create an index on email for faster lookups
CREATE INDEX IF NOT EXISTS idx_users_email ON app.users(email);

-- Add a comment to the table
COMMENT ON TABLE app.users IS 'User accounts table';

-- Log successful initialization
DO $$
BEGIN
    RAISE NOTICE 'Database initialization completed successfully';
END $$;

