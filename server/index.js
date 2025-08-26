require("dotenv").config();
const express = require('express');
const db = require('./db');

const app = express();


app.get('/', async (req, res) => {
  try {
    const result = await db.query('SELECT * FROM reviews LIMIT 2');
    res.json(result.rows);
  } catch (err) {
    console.error(err);
  }
});

app.listen(process.env.PORT, () => {
  console.log('Server is running on port', process.env.PORT);
});