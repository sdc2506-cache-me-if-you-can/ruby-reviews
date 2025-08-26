require('dotenv').config();
const express = require('express');
const router = require('./routes.js');

const app = express();

app.use('/', router);

app.listen(process.env.PORT, () => {
  console.log('Server is running on port', process.env.PORT);
});