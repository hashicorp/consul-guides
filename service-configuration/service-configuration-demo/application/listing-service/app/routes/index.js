const listingRoutes = require('./listing_routes')

module.exports = function(app, db, conf) {
  listingRoutes(app, db, conf);
}