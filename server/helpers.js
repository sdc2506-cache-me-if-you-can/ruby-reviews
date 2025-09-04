const db = require('./db');

async function updateMeta(product_id, rating, recommend) {
  let queryStr = `
    UPDATE product_metareviews
    SET characteristics = chars.characteristics
    FROM
    (
      SELECT product_id, json_agg(json_build_object('name', name, 'id', id, 'value', avg)) as characteristics
      FROM (SELECT p.id AS product_id, c.name, c.id, AVG(cr.value)
            FROM characteristics c
            JOIN products p ON p.id = c.product_id
            LEFT JOIN characteristic_reviews cr ON cr.characteristic_id = c.id
            WHERE p.id = $1
            GROUP BY p.id, c.id, c.name) as subquery
      GROUP BY subquery.product_id
      ORDER BY subquery.product_id ASC
    ) AS chars
    WHERE chars.product_id = product_metareviews.product_id
  `;
  db.query(queryStr, [product_id]);
  let rating_col;
  let rec_col;
  if (rating == 1) {
    rating_col = 'one_count';
  } else if (rating == 2) {
    rating_col = 'two_count';
  } else if (rating == 3) {
    rating_col = 'three_count';
  } else if (rating == 4) {
    rating_col = 'four_count';
  } else if (rating == 5) {
    rating_col = 'five_count';
  } else {
    rating_col = '';
  }
  if (recommend) {
    rec_col = 'recommend_count';
  } else {
    rec_col = 'no_recommend_count';
  }
  queryStr = `
    UPDATE product_metareviews
    SET ${rating_col} = ${rating_col} + 1, ${rec_col} = ${rec_col} + 1
    WHERE product_id=$1
  `;
  db.query(queryStr, [product_id]);
}

module.exports = {
  updateMeta
};