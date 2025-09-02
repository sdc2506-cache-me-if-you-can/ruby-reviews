const db = require('./db');

async function calculateMeta(product_id) {
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
  `;
  db.query(queryStr, [product_id]);
  queryStr = `
    UPDATE product_metareviews
    SET one_count = counts.one_count, two_count = counts.two_count, three_count = counts.three_count, four_count = counts.four_count, five_count = counts.five_count, recommend_count = counts.recommend_count, no_recommend_count = counts.no_recommend_count
    FROM
    (
      SELECT product_id,
      COUNT(CASE WHEN rating = 1 THEN 1 END) as one_count,
      COUNT(CASE WHEN rating = 2 THEN 1 END) as two_count,
      COUNT(CASE WHEN rating = 3 THEN 1 END) as three_count,
      COUNT(CASE WHEN rating = 4 THEN 1 END) as four_count,
      COUNT(CASE WHEN rating = 5 THEN 1 END) as five_count,
      COUNT(CASE WHEN recommend = true THEN 1 END) as recommend_count,
      COUNT(CASE WHEN recommend = false THEN 1 END) as no_recommend_count
      FROM reviews
      WHERE product_id=$1
      GROUP BY product_id
    ) AS counts
    WHERE counts.product_id = product_metareviews.product_id
  `;
  db.query(queryStr, [product_id]);
}

module.exports = {
  calculateMeta
};