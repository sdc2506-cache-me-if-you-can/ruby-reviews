### SDC Ratings and Reviews API
Server Development Capstone Project for Hack Reactor Atelier

### Description
Webservice that retrieves relevant ratings and reviews data for a specific product. Meant to be used in conjuction with a products service. Optimized for high volumes of traffic.

# Getting Started
## Dependencies
Install dependencies by running `npm install`
Set up a `.env` with `PORT`, `DB_USER`, `DB_PASS`, and `DB_NAME` variables. Use a user that has admin permissions to create databases.

Current dependencies are:
- dotenv
- express
- pg (Node-postgres)

## ETL
To perform the ETL process, you will need the applicable csv files.
1) Download the csv files.
2) Replace the file paths in `schema.sql` with your own paths.
3) Run `psql -U [USER] -d postgres -f server/schema.sql`. You may be asked to enter a password. This process may take a couple minutes.

## Start
Start the service by running `npm start`

## Documentation
* `GET /reviews` takes a product_id and optional parameters page, count, and sort and returns a list of reviews that does not include reported reviews
* `GET /reviews/meta` takes a product_id and returns metadata for that product
* `POST /reviews/` takes in JSON data and saves it in applicable tables in the database
* `PUT /reviews/:review_id/helpful` takes a review_id and increments the helpfulness count for that review entry in the database
* `PUT /reviews/:review_id/report` takes a review_id and set the reported field in the review entry to be true. This does not delete the entry but marks it for exclusion from GET requests to `/reviews`