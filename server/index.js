require('dotenv').config();
const express = require('express');
const router = require('./routes');
const path = require('path');

const app = express();

app.use(`/${process.env.LOADER}`, express.static(path.join(__dirname, '/tests', process.env.LOADER)));
app.use(express.json());
app.use('/', router);

app.listen(process.env.PORT, () => {
  console.log('Server is running on port', process.env.PORT);
});