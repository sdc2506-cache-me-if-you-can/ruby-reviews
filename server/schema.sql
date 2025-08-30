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