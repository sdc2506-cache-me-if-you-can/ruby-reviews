const db = require('./db');

async function getReviews(req, res) {
  // query params:
  /*
    page: integer (default 1),
    count: integer (default 5),
    sort: text ("newest", "helpful", "relevant"),
    product_id: integer, required
  */
  try {
    const result = await db.query('SELECT * FROM reviews LIMIT 5');
    res.json(result.rows);
  } catch (err) {
    console.error(err);
  }
  // status: 200 OK
}

async function getMeta(req, res) {
  // query params:
  // product_id: integer, required
  // status: 200 OK
  res.send('/reviews/meta');
}

async function postReview(req, res) {
  // body params: (raw json)
  /*
    product_id,
    rating,
    summary,
    body,
    recommend,
    name,
    email,
    photos,
    characteristics
  */
 // status: 201 CREATED
}

async function putHelpfulReview(req, res) {
  // params:
  // review_id: integer, required
  // status: 204 NO CONTENT
}

async function putReportedReview(req, res) {
  // params:
  // review_id: integer, required
  // status: 204 NO CONTENT
}

module.exports = {
  getReviews,
  getMeta,
  postReview,
  putHelpfulReview,
  putReportedReview,
};
