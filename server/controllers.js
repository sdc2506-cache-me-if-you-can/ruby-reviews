const db = require('./db');
const helpers = require('./helpers');

async function getReviews(req, res) {
  try {
    let page = req.query.page || 0;
    // default first page will translate into 0 offset
    if (page == 1) {
      page = 0;
    }
    const count = req.query.count || 5;
    const sort = req.query.sort || "";
    const product_id = req.query.product_id;

    let order_by = '';
    if (sort === 'newest') {
      order_by = 'date DESC';
    } else if (sort === 'helpful') {
      order_by = 'helpfulness DESC';
    } else {
      order_by = 'helpfulness DESC, date DESC';
    }
    let queryStr = `SELECT reviews.id AS review_id, rating, date, summary, body, recommend, reviewer_name, response, helpfulness, photos
    FROM reviews
    WHERE product_id=$1 AND reported = false
    ORDER BY ${order_by} LIMIT $2 OFFSET $3`;
    const result = await db.query(queryStr, [product_id, count, count * page]);

    res.json({
      product: product_id,
      page: page,
      count: count,
      // results: result.rows
      results: result.rows.map((row) => {
        if (!row.photos) {
          row.photos = [];
        }
        return row;
      })
    });
  } catch (err) {
    console.error(err);
    res.sendStatus(404);
  }
}

async function getMeta(req, res) {
  try {
    const product_id = req.query.product_id;

    // build json
    let result = { product_id: product_id, ratings: {}, recommended: {}, characteristics: {} };
    let queryStr = 'SELECT * FROM product_metareviews WHERE product_id=$1';
    const meta = await db.query(queryStr, [product_id]);
    // ratings
    let ratings = {};
    ratings[1] = meta.rows[0].one_count;
    ratings[2] = meta.rows[0].two_count;
    ratings[3] = meta.rows[0].three_count;
    ratings[4] = meta.rows[0].four_count;
    ratings[5] = meta.rows[0].five_count;
    result.ratings = ratings;
    // recommended
    let recommended = {};
    recommended[0] = meta.rows[0].no_recommend_count;
    recommended[1] = meta.rows[0].recommend_count;
    result.recommended = recommended;
    let characteristics = {};
    // characteristics
    meta.rows[0].characteristics.forEach((characteristic) => {
      characteristics[characteristic.name] = {id: characteristic.id, value: characteristic.value};
    });
    result.characteristics = characteristics;
    res.json(result);
  } catch (err) {
    console.error(err);
    res.sendStatus(404);
  }
}

async function postReview(req, res) {
  try {
    const {product_id, rating, summary, body, recommend, name, email, photos, characteristics} = req.body;

    // add new entry to reviews
    let queryStr = 'INSERT INTO reviews (product_id, rating, summary, body, recommend, reviewer_name, reviewer_email) VALUES ($1, $2, $3, $4, $5, $6, $7) RETURNING id';
    const newReview = await db.query(queryStr, [product_id, rating, summary, body, recommend, name, email]);
    // const newReview = await db.query(`SELECT *
    //   FROM reviews
    //   ORDER BY id DESC
    //   LIMIT 1`);
    // add entries to characteristics_reviews
    for (const [key, value] of Object.entries(characteristics)) {
      queryStr = 'INSERT INTO characteristic_reviews (characteristic_id, review_id, value) VALUES ($1, $2, $3)';
      await db.query(queryStr, [key, newReview.rows[0].id, value]);
    }
    // add entries to photos
    for (const photoURL of photos) {
      queryStr = 'INSERT INTO photos (review_id, url) VALUES ($1, $2)';
      await db.query(queryStr, [newReview.rows[0].id, photoURL]);
    }

    // add photos to new review
    queryStr = `
    UPDATE reviews
    SET photos = (
      json_agg
    )
    FROM (
      SELECT json_agg(json_build_object('id', photos.id, 'url', photos.url)) FILTER (WHERE photos.id IS NOT NULL)
      FROM photos
      WHERE review_id=$1
    )
    WHERE id=$1
    `;
    db.query(queryStr, [newReview.rows[0].id]);
    helpers.calculateMeta(product_id);
    res.sendStatus(201);
  } catch (err) {
    console.error(err);
    res.sendStatus(404);
  }
}

async function putReviewHelpful(req, res) {
  try {
    let queryStr = 'UPDATE reviews SET helpfulness = helpfulness + 1 WHERE id = $1';
    await db.query(queryStr, [req.params.review_id]);
    res.sendStatus(204);
  } catch (err) {
    console.error(err);
    res.sendStatus(404);
  }
}

async function putReviewReported(req, res) {
  try {
    let queryStr = 'UPDATE reviews SET reported = true WHERE id = $1';
    await db.query(queryStr, [req.params.review_id]);
    res.sendStatus(204);
  } catch (err) {
    console.error(err);
    res.sendStatus(404);
  }
}

module.exports = {
  getReviews,
  getMeta,
  postReview,
  putReviewHelpful,
  putReviewReported,
};
