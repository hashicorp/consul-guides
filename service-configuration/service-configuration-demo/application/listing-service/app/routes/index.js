/**
 * Copyright (c) HashiCorp, Inc.
 * SPDX-License-Identifier: MPL-2.0
 */

const listingRoutes = require('./listing_routes')

module.exports = function(app, db, conf) {
  listingRoutes(app, db, conf);
}