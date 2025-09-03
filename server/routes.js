const controllers = require('./controllers');
const router = require('express').Router();
const path = require('path');

router.get('/', async (req, res) => {
  res.send('routes: /reviews, reviews/meta');
});

router.get('/loaderio-ada5397f8066e6f74bfeca25f781179e.txt', (req, res) => {
  res.sendFile(path.join(__dirname, '..', '/tests', 'loaderio.txt'));
});
router.get('/reviews', controllers.getReviews);
router.get('/reviews/meta', controllers.getMeta);
router.post('/reviews', controllers.postReview);
router.put('/reviews/:review_id/helpful', controllers.putReviewHelpful);
router.put('/reviews/:review_id/report', controllers.putReviewReported);

module.exports = router;