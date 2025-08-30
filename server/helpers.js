const db = require('./db');

async function makeMetaTable(product_id) {
  await db.query('DROP TABLE IF EXISTS product_reviews');
  let queryStr = `SELECT id AS review_id, rating, recommend
  INTO product_reviews
  FROM reviews
  WHERE reported=false
    AND product_id=$1`;
  await db.query(queryStr, [product_id]);
  await db.query('CREATE INDEX idx_product_reviews_rating ON product_reviews(rating)');
  await db.query('CREATE INDEX idx_product_reviews_recommend ON product_reviews(recommend)');
}

async function getRatingsMeta() {
    // assuming product_reviews exists
    let queryStr = `
      SELECT rating, COUNT(review_id)
      FROM product_reviews
      GROUP BY rating
      ORDER BY rating`;
    const ratings = await db.query(queryStr);
    return ratings.rows;
}

async function getRecommendedMeta() {
  // assuming product_reviews exists
  queryStr = `
    SELECT recommend::int, COUNT(review_id)
    FROM product_reviews
    GROUP BY recommend
    ORDER BY recommend`;
  const recommended = await db.query(queryStr);
  return recommended.rows;
}

async function getCharacteristicsMeta(product_id) {
    await db.query('DROP TABLE IF EXISTS product_characteristic_reviews');
    queryStr = `SELECT characteristics.id, characteristics.product_id, characteristics.name, characteristic_reviews.characteristic_id, characteristic_reviews.value, characteristic_reviews.review_id
    INTO product_characteristic_reviews
    FROM characteristics
    INNER JOIN characteristic_reviews
    ON characteristics.id=characteristic_reviews.characteristic_id
    WHERE characteristics.product_id=$1`;
    await db.query(queryStr, [product_id]);
    await db.query('CREATE INDEX idx_product_characteristic_reviews_characteristic_name ON product_characteristic_reviews(name)');
    queryStr = `SELECT name, characteristic_id AS id, AVG(value) AS value
    FROM product_characteristic_reviews
    GROUP BY characteristic_id, name
    ORDER BY characteristic_id`;
    const characteristics = await db.query(queryStr);
    return characteristics.rows;
}

module.exports = {
  makeMetaTable,
  getRatingsMeta,
  getRecommendedMeta,
  getCharacteristicsMeta
} ;