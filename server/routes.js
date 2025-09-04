require('dotenv').config();
const controllers = require('./controllers');
const router = require('express').Router();
const path = require('path');

router.get('/', async (req, res) => {
  res.send('routes: /reviews, reviews/meta');
});

router.get(`/${process.env.LOADER}`, (req, res) => {
  res.sendFile(path.join(__dirname, '..', '/tests', process.env.LOADER));
});
router.get('/reviews', controllers.getReviews);
router.get('/reviews/meta', controllers.getMeta);
router.post('/reviews', controllers.postReview);
router.put('/reviews/:review_id/helpful', controllers.putReviewHelpful);
router.put('/reviews/:review_id/report', controllers.putReviewReported);

module.exports = router;