require('dotenv').config();
const express = require('express');
const router = require('./routes');
const path = require('path');

const app = express();

app.use('/loaderio-ada5397f8066e6f74bfeca25f781179e.txt', express.static(path.join(__dirname, '/tests', 'loaderio.txt')));
app.use(express.json());
app.use('/', router);

app.listen(process.env.PORT, () => {
  console.log('Server is running on port', process.env.PORT);
});