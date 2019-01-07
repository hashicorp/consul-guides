const express     = require('express')
const MongoClient = require('mongodb').MongoClient
const bodyParser  = require('body-parser')
const db          = require('./config/db');
//const resolveDB   = require('./config/resolveSrv')

const app = express()

const PORT = process.env.LISTING_PORT || 8000;
const ADDR = process.env.LISTING_ADDR || '127.0.0.1';

app.use(bodyParser.urlencoded({ extended: true }));

function connectDB() {
  // TODO: add auth later (Vault)
  // require('./config/resolveSrv')(db.db_addr, db.db_port).then( (dsn) => {
  //var db_proxy_addr = 'mongodb://localhost:8001'
  var dsn = "mongodb://" + db.db_user + ":" + db.db_pw + "@" + db.db_addr + ":" + db.db_port + "/admin"
  //var dsn = "mongodb://" + db.db_addr + ":" + db.db_port
  console.log("Connecting to: " + dsn)
  MongoClient.connect(dsn, { useNewUrlParser: true }, function(err, database) {
    if (err) {
      console.log(err)
      console.log("Waiting 5 seconds and trying again...")
      setTimeout(connectDB, 5000)
    } else {
      app.emit('dbConnected', (database))
    }
  })
}

connectDB()

app.on('dbConnected', (database) => {
  // TODO: load this from a file or env (consul)
  dbConn = database.db(db.db_name)
  require('./app/routes')(app, dbConn, {collection: db.db_col});
  app.listen(PORT, ADDR, () => {
    console.log('We are live on ' + PORT);
  })
})
