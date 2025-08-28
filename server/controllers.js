const db = require('./db');

async function getReviews(req, res) {
  // query params:
  /*
    page: integer (default 1),
    count: integer (default 5),
    sort: text ("newest", "helpful", "relevant"),
    product_id: integer, required
  */
  let page = req.query.page || 0;
  // default first page will translate into 0 offset
  if (page == 1) {
    page = 0;
  }
  const count = req.query.count || 5;
  const sort = req.query.sort || "";
  const product_id = req.query.product_id;

  try {
    let queryStr = `SELECT id AS review_id, rating, date, summary, body, recommend, reviewer_name, response, helpfulness FROM reviews WHERE reported=false AND product_id=${product_id}`;
    if (sort === 'newest') {
      queryStr += ' ORDER BY date DESC';
    } else if (sort === 'helpful') {
      queryStr += ' ORDER BY helpfulness DESC';
    } else if (sort === 'relevant' || '') {
      queryStr += ' ORDER BY helpfulness DESC, date DESC';
    }
    queryStr += ` LIMIT ${count} OFFSET ${count * page}`;
    // reviews as array of objects
    const result = await db.query(queryStr);
    // add in photos
    for (const review of result.rows) {
      queryStr = `SELECT id, url FROM photos WHERE review_id=${review.review_id}`;
      let photos = await db.query(queryStr);
      review.photos = photos.rows || [];
      // could be empty array if no photos found
    }
    res.json({
      product: product_id,
      page: page,
      count: count,
      results: result.rows
    });
  } catch (err) {
    console.error(err);
  }
  // status: 200 OK
}

async function getMeta(req, res) {
  // query params:
  // product_id: integer, required
  // status: 200 OK
  const product_id = req.query.product_id;
  try {
    await db.query('DROP TABLE IF EXISTS product_reviews');
    let queryStr = `SELECT id AS review_id, rating, recommend
    INTO product_reviews
    FROM reviews
    WHERE reported=false
      AND product_id=${product_id}`;
    // get metadata for ratings and recommended
    await db.query(queryStr);
    queryStr = `SELECT rating, COUNT(review_id)
    FROM product_reviews
    GROUP BY rating
    ORDER BY rating`;
    const ratings = await db.query(queryStr);
    queryStr = `SELECT recommend::int, COUNT(review_id)
    FROM product_reviews
    GROUP BY recommend
    ORDER BY recommend`;
    const recommended = await db.query(queryStr);
    // get metadata for characteristics
    await db.query('DROP TABLE IF EXISTS product_characteristic_reviews');
    queryStr = `SELECT characteristics.id, characteristics.product_id, characteristics.name, characteristic_reviews.characteristic_id, characteristic_reviews.value, characteristic_reviews.review_id
    INTO product_characteristic_reviews
    FROM characteristics
    INNER JOIN characteristic_reviews
    ON characteristics.id=characteristic_reviews.characteristic_id
    WHERE characteristics.product_id=${product_id}`;
    await db.query(queryStr);
    queryStr = `SELECT name, characteristic_id AS id, AVG(value) AS value
    FROM product_characteristic_reviews
    GROUP BY characteristic_id, name
    ORDER BY characteristic_id`;
    const characteristics = await db.query(queryStr);
    let result = { product_id: product_id, ratings: {}, recommended: {}, characteristics: {} };

    // structure
    for (const row of ratings.rows) {
      result.ratings[row.rating] = row.count;
    }
    for (const row of recommended.rows) {
      result.recommended[row.recommend] = row.count;
    }
    for (const row of characteristics.rows) {
      result.characteristics[row.name] = {
        id: row.id,
        value: row.value
      };
    }
    res.json(result);
  } catch (err) {
    console.error(err);
  }
  // res.send('/reviews/meta');
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
