require("dotenv").config();
const { Pool } = require('pg');

const pool = new Pool({
  user: process.env.DB_USER,
  password: process.env.DB_PASS,
  host: 'localhost',
  port: 5432, // default Postgres port
  database: process.env.DB_NAME
});

// psql -U ruby_reviews -d postgres -f server/schema.sql

module.exports = {
  query: (text, params) => pool.query(text, params)
};