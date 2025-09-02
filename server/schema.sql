DROP DATABASE IF EXISTS reviewsdb;
CREATE DATABASE reviewsdb;

\c reviewsdb

CREATE TABLE IF NOT EXISTS products (
  id INT PRIMARY KEY,
  name TEXT,
  slogan TEXT,
  description TEXT,
  category TEXT,
  default_price INT
);

CREATE TABLE IF NOT EXISTS characteristics (
  id INT PRIMARY KEY,
  product_id INT REFERENCES products(id),
  name TEXT
);

CREATE TABLE IF NOT EXISTS reviews (
  id SERIAL PRIMARY KEY,
  product_id INT REFERENCES products(id),
  rating INT,
  date TIMESTAMP DEFAULT NOW(),
  summary TEXT,
  body TEXT,
  recommend BOOLEAN,
  reported BOOLEAN DEFAULT false,
  reviewer_name TEXT,
  reviewer_email TEXT,
  response TEXT DEFAULT null,
  helpfulness INT DEFAULT 0,
  photos JSONB DEFAULT '[]'::jsonb
);

CREATE INDEX idx_reviews_date ON reviews(date);
CREATE INDEX idx_reviews_helpfulness ON reviews(helpfulness);
CREATE INDEX idx_active_reviews ON reviews(reported, product_id);

CREATE TABLE IF NOT EXISTS photos (
    id SERIAL PRIMARY KEY,
    review_id INT REFERENCES reviews(id),
    url TEXT
);

CREATE TABLE IF NOT EXISTS characteristic_reviews (
    id SERIAL PRIMARY KEY,
    characteristic_id INT REFERENCES characteristics(id),
    review_id INT REFERENCES reviews(id),
    value INT
);

CREATE TABLE IF NOT EXISTS product_metareviews (
  id SERIAL PRIMARY KEY,
  product_id INT REFERENCES products(id),
  one_count INT DEFAULT 0,
  two_count INT DEFAULT 0,
  three_count INT DEFAULT 0,
  four_count INT DEFAULT 0,
  five_count INT DEFAULT 0,
  recommend_count INT DEFAULT 0,
  no_recommend_count INT DEFAULT 0,
  characteristics JSONB DEFAULT '[]'::jsonb
);

CREATE INDEX idx_reviews_product_id ON product_metareviews(product_id);

COPY products
	FROM '/Users/ruby/Code/RFP/ruby-reviews/src/product.csv'
  CSV HEADER
  DELIMITER ',';

COPY characteristics
	FROM '/Users/ruby/Code/RFP/ruby-reviews/src/characteristics.csv'
  CSV HEADER
  DELIMITER ',';

CREATE TABLE IF NOT EXISTS raw_reviews (
  	id INT PRIMARY KEY,
    product_id INT REFERENCES products(id),
    rating INT,
    date BIGINT,
    summary TEXT,
    body TEXT,
    recommend BOOLEAN,
    reported BOOLEAN,
    reviewer_name TEXT,
    reviewer_email TEXT,
    response TEXT,
    helpfulness INT
);

COPY raw_reviews
	FROM '/Users/ruby/Code/RFP/ruby-reviews/src/reviews.csv'
  CSV HEADER
  DELIMITER ',';

INSERT INTO reviews (id, rating, summary, recommend, response, body, date, reviewer_name, reviewer_email, helpfulness, reported, product_id)
SELECT id, rating, summary, recommend, response, body, TO_TIMESTAMP(date / 1000), reviewer_name, reviewer_email, helpfulness, reported, product_id
FROM raw_reviews;

COPY photos
	FROM '/Users/ruby/Code/RFP/ruby-reviews/src/reviews_photos.csv'
  CSV HEADER
  DELIMITER ',';

COPY characteristic_reviews
	FROM '/Users/ruby/Code/RFP/ruby-reviews/src/characteristic_reviews.csv'
  CSV HEADER
  DELIMITER ',';

SELECT setval('reviews_id_seq'::regclass, (SELECT id
FROM reviews
ORDER BY id DESC
LIMIT 1));

SELECT setval('characteristic_reviews_id_seq'::regclass, (SELECT id
FROM characteristic_reviews
ORDER BY id DESC
LIMIT 1));

SELECT setval('photos_id_seq'::regclass, (SELECT id
FROM photos
ORDER BY id DESC
LIMIT 1));

INSERT INTO product_metareviews
(product_id, characteristics)
(
  SELECT product_id, json_agg(json_build_object('name', name, 'id', id, 'value', avg)) as characteristics
  FROM (SELECT p.id AS product_id, c.name, c.id, AVG(cr.value)
        FROM characteristics c
        JOIN products p ON p.id = c.product_id
        LEFT JOIN characteristic_reviews cr ON cr.characteristic_id = c.id
        GROUP BY p.id, c.id, c.name) as subquery
  GROUP BY subquery.product_id
  ORDER BY subquery.product_id ASC
);

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
  GROUP BY product_id
) AS counts
WHERE counts.product_id = product_metareviews.product_id;

UPDATE reviews
SET photos = (
  json_agg
)
FROM (
  SELECT json_agg(json_build_object('id', photos.id, 'url', photos.url)) FILTER (WHERE photos.id IS NOT NULL),
  	reviews.id
  FROM reviews
  LEFT JOIN photos
  ON photos.review_id = reviews.id
  GROUP BY reviews.id
) AS subquery
WHERE subquery.id = reviews.id AND reviews.id < 1000000;
UPDATE reviews
SET photos = (
  json_agg
)
FROM (
  SELECT json_agg(json_build_object('id', photos.id, 'url', photos.url)) FILTER (WHERE photos.id IS NOT NULL),
  	reviews.id
  FROM reviews
  LEFT JOIN photos
  ON photos.review_id = reviews.id
  GROUP BY reviews.id
) AS subquery
WHERE subquery.id = reviews.id AND reviews.id >= 1000000 AND reviews.id < 2000000;
UPDATE reviews
SET photos = (
  json_agg
)
FROM (
  SELECT json_agg(json_build_object('id', photos.id, 'url', photos.url)) FILTER (WHERE photos.id IS NOT NULL),
  	reviews.id
  FROM reviews
  LEFT JOIN photos
  ON photos.review_id = reviews.id
  GROUP BY reviews.id
) AS subquery
WHERE subquery.id = reviews.id AND reviews.id >= 2000000 AND reviews.id < 3000000;
UPDATE reviews
SET photos = (
  json_agg
)
FROM (
  SELECT json_agg(json_build_object('id', photos.id, 'url', photos.url)) FILTER (WHERE photos.id IS NOT NULL),
  	reviews.id
  FROM reviews
  LEFT JOIN photos
  ON photos.review_id = reviews.id
  GROUP BY reviews.id
) AS subquery
WHERE subquery.id = reviews.id AND reviews.id >= 3000000 AND reviews.id < 4000000;
UPDATE reviews
SET photos = (
  json_agg
)
FROM (
  SELECT json_agg(json_build_object('id', photos.id, 'url', photos.url)) FILTER (WHERE photos.id IS NOT NULL),
  	reviews.id
  FROM reviews
  LEFT JOIN photos
  ON photos.review_id = reviews.id
  GROUP BY reviews.id
) AS subquery
WHERE subquery.id = reviews.id AND reviews.id >= 4000000 AND reviews.id < 5000000;
UPDATE reviews
SET photos = (
  json_agg
)
FROM (
  SELECT json_agg(json_build_object('id', photos.id, 'url', photos.url)) FILTER (WHERE photos.id IS NOT NULL),
  	reviews.id
  FROM reviews
  LEFT JOIN photos
  ON photos.review_id = reviews.id
  GROUP BY reviews.id
) AS subquery
WHERE subquery.id = reviews.id AND reviews.id >= 5000000;