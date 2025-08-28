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
  helpfulness INT DEFAULT 0
);

CREATE TABLE IF NOT EXISTS characteristic_reviews (
    id SERIAL PRIMARY KEY,
    characteristic_id INT REFERENCES characteristics(id),
    review_id INT REFERENCES reviews(id),
    value INT
);

CREATE TABLE IF NOT EXISTS photos (
    id SERIAL PRIMARY KEY,
    review_id INT REFERENCES reviews(id),
    url TEXT
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

COPY characteristic_reviews
	FROM '/Users/ruby/Code/RFP/ruby-reviews/src/characteristic_reviews.csv'
  CSV HEADER
  DELIMITER ',';

COPY photos
	FROM '/Users/ruby/Code/RFP/ruby-reviews/src/reviews_photos.csv'
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