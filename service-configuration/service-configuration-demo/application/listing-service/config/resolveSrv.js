const dns = require('dns');

function resolveDB(addr, port) {
  return new Promise( function(resolve, reject) {
    if (isConsulAddr(addr)) {
      var db_port
      dns.setServers(['127.0.0.1:8600'])
      dns.resolveSrv(addr, function(err, srv) {
        if (err) {
          reject(err);
        } else {
          db_port = srv[0].port
          dns.resolve4(addr, function (err, rec) {
            resolve(buildDSN(rec[0], db_port))
          })

        }
      })
    } else {
      resolve(buildDSN(addr, port))
    }
  })
}

function buildDSN(addr, port) {
  return 'mongodb://'+ addr + ':' + port
}

function isConsulAddr(addr) {
  return addr.endsWith('consul')
}

module.exports = resolveDB
