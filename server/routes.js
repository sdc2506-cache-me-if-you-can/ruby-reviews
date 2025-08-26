const controllers = require('./controllers.js');
const router = require('express').Router();

router.get('/', async (req, res) => {
  res.send('routes: /reviews, reviews/meta');
});

router.get('/reviews', controllers.getReviews);
router.get('/reviews/meta', controllers.getMeta);
router.post('/reviews', controllers.postReview);
router.put('/reviews/:review_id/helpful', controllers.putHelpfulReview);
router.put('/reviews/:review_id/report', controllers.putReportedReview);

module.exports = router;