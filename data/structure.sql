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

CREATE INDEX idx_photos_review_id ON photos(review_id);

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

