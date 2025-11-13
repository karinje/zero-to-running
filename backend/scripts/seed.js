#!/usr/bin/env node

/**
 * Database Seeding Script
 * Populates the database with sample data for development
 */

require('dotenv').config();
const { Pool } = require('pg');
const fs = require('fs');
const path = require('path');

// Database configuration
const pool = new Pool({
  host: process.env.POSTGRES_HOST || 'postgres',
  port: process.env.POSTGRES_PORT || 5432,
  database: process.env.POSTGRES_DB || 'wander_dev',
  user: process.env.POSTGRES_USER || 'wander_user',
  password: process.env.POSTGRES_PASSWORD || 'dev_password_change_in_prod',
});

// Load seed data
const usersData = JSON.parse(
  fs.readFileSync(path.join(__dirname, 'seeds', 'users.json'), 'utf8')
);
const productsData = JSON.parse(
  fs.readFileSync(path.join(__dirname, 'seeds', 'products.json'), 'utf8')
);

async function seed() {
  const client = await pool.connect();
  
  try {
    await client.query('BEGIN');

    console.log('🌱 Starting database seeding...');

    // Clear existing data (idempotent)
    console.log('🧹 Clearing existing data...');
    await client.query('TRUNCATE TABLE app.users CASCADE');
    await client.query('DROP TABLE IF EXISTS app.products CASCADE');
    await client.query('DROP TABLE IF EXISTS app.orders CASCADE');

    // Create products table
    console.log('📦 Creating products table...');
    await client.query(`
      CREATE TABLE IF NOT EXISTS app.products (
        id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
        name VARCHAR(255) NOT NULL,
        price DECIMAL(10, 2) NOT NULL,
        description TEXT,
        created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
        updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
      )
    `);

    // Create orders table
    console.log('🛒 Creating orders table...');
    await client.query(`
      CREATE TABLE IF NOT EXISTS app.orders (
        id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
        user_id UUID NOT NULL REFERENCES app.users(id) ON DELETE CASCADE,
        product_id UUID NOT NULL REFERENCES app.products(id) ON DELETE CASCADE,
        quantity INTEGER NOT NULL DEFAULT 1,
        total_price DECIMAL(10, 2) NOT NULL,
        status VARCHAR(50) DEFAULT 'pending',
        created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
        updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
      )
    `);

    // Insert users
    console.log(`👥 Inserting ${usersData.length} users...`);
    for (const user of usersData) {
      await client.query(
        'INSERT INTO app.users (email, name) VALUES ($1, $2) ON CONFLICT (email) DO NOTHING',
        [user.email, user.name]
      );
    }

    // Insert products
    console.log(`📦 Inserting ${productsData.length} products...`);
    const productIds = [];
    for (const product of productsData) {
      const result = await client.query(
        'INSERT INTO app.products (name, price, description) VALUES ($1, $2, $3) RETURNING id',
        [product.name, product.price, product.description]
      );
      productIds.push(result.rows[0].id);
    }

    // Get user IDs
    const userResult = await client.query('SELECT id FROM app.users ORDER BY created_at');
    const userIds = userResult.rows.map(row => row.id);

    // Create orders (30-50 orders)
    console.log('🛒 Creating orders...');
    const orderCount = Math.floor(Math.random() * 21) + 30; // 30-50 orders
    for (let i = 0; i < orderCount; i++) {
      const userId = userIds[Math.floor(Math.random() * userIds.length)];
      const productId = productIds[Math.floor(Math.random() * productIds.length)];
      const quantity = Math.floor(Math.random() * 3) + 1; // 1-3 items
      
      // Get product price
      const productResult = await client.query(
        'SELECT price FROM app.products WHERE id = $1',
        [productId]
      );
      const totalPrice = parseFloat(productResult.rows[0].price) * quantity;
      
      const statuses = ['pending', 'completed', 'shipped', 'cancelled'];
      const status = statuses[Math.floor(Math.random() * statuses.length)];

      await client.query(
        `INSERT INTO app.orders (user_id, product_id, quantity, total_price, status)
         VALUES ($1, $2, $3, $4, $5)`,
        [userId, productId, quantity, totalPrice, status]
      );
    }

    await client.query('COMMIT');
    
    // Get counts
    const userCount = await client.query('SELECT COUNT(*) FROM app.users');
    const productCount = await client.query('SELECT COUNT(*) FROM app.products');
    const orderCount = await client.query('SELECT COUNT(*) FROM app.orders');

    console.log('✅ Seeding completed successfully!');
    console.log(`   Users: ${userCount.rows[0].count}`);
    console.log(`   Products: ${productCount.rows[0].count}`);
    console.log(`   Orders: ${orderCount.rows[0].count}`);
    
  } catch (error) {
    await client.query('ROLLBACK');
    console.error('❌ Error seeding database:', error);
    process.exit(1);
  } finally {
    client.release();
    await pool.end();
  }
}

seed();

