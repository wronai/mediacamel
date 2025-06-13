const { Pool } = require('pg');
const dotenv = require('dotenv');

// Load environment variables
dotenv.config();

const pool = new Pool({
  user: process.env.DB_USER,
  host: process.env.DB_HOST,
  database: process.env.DB_NAME,
  password: process.env.DB_PASSWORD,
  port: process.env.DB_PORT,
  // Don't wait for more than 5 seconds to connect
  connectionTimeoutMillis: 5000,
  // Don't wait for more than 10 seconds for a query to complete
  query_timeout: 10000,
  // Automatically close idle clients after 1 second
  idle_in_transaction_session_timeout: 1000,
});

// Simple query to check if the database is ready
pool.query('SELECT NOW()', (err) => {
  pool.end(); // Close the connection
  
  if (err) {
    console.error('Database connection failed:', err);
    process.exit(1);
  }
  
  console.log('Database connection successful');
  process.exit(0);
});
