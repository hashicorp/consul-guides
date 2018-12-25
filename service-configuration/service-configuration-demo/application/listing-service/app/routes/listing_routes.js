module.exports = function(app, db, conf) {

  app.get('/listing/healthz', (req, res) => {
    res.sendStatus(200)
  }),

  app.get('/listing/:id', (req, res) => {
    var details = {'listing_id': req.params.id };
    console.log("Retrieving record for ", details)
    db.collection(conf.collection).findOne(details, (err, item) => {
      console.log("found item:", item)
      if (err) {
        res.send({'error': 'Could not retrieve listing from database'})
      } else if (null == item) {
        res.send({'error': 'Record not found in database with listing_id = ' + details.listing_id})
      } else {
        res.send(item)
      }
    })
  }),

  app.get('/listing', (req, res) => {
    console.log("listing")
    db.collection(conf.collection).find({}, {'_id': false, 'limit':10}).toArray( (err, item) => {
      if (err || null == item) {
        res.send({'error': 'Could not retrieve listing from database'})
      } else {
        res.send(item)
      }
    })
  }),

  app.get('/metadata', (req, res) => {
    console.log("metadata")

    var db_username = process.env.username
    var db_pw = process.env.password
    var version = process.env.version

    var pw_len = db_pw.length
    var mask_len = pw_len - 4
    var m = ""
    for (i = 0; i < mask_len; i++) {
      m+="X"
    }
    var masked_pw = m + db_pw.substring(pw_len-4, pw_len)

    metadata_dict = {
     "version" : version,
     "DB_USER": db_username,
     "DB_PW": masked_pw
    }

    res.send(metadata_dict)

  }),

  app.post('/listing', (req, res) =>{
    var listing = { text: req.body.body, title: req.body.title};
    db.collection(conf.collection).insert(listing, (err, result) => {
      if (err) {
        res.send({'error': 'Failed to create record'})
      } else {
        res.send(result.ops[0])
      }
    })
  })
};
