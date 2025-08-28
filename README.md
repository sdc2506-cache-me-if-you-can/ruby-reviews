### SDC Ratings and Reviews API
Server Development Capstone Project for Hack Reactor Atelier

### Description
Webservice that retrieves relevant ratings and reviews data for a specific product. Meant to be used in conjuction with a products service.

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
3) Run `psql -U [DB_NAME] -d postgres -f server/schema.sql`. You may be asked to enter a password. This process currently takes about 7 minutes.

## Start
Start the service by running `npm start`

## Documentation
* `GET /reviews` takes a product_id and optional parameters page, count, and sort and returns a list of reviews that does not include reported reviews
* `GET /reviews/meta` takes a product_id and returns metadata for that product