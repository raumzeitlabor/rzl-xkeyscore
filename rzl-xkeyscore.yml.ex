Database: {
  dsn: 'DBI:mysql:database=xkeyscore;host=db.rzl',
  user: 'xkeyscore',
  passwd: '0000'
}

MQTT: {
  host: 'localhost',
  timeout: 3,
  keepalive: 10,
  cleansession: 1,
  clientid: 'xkeyscore',
  blacklist: [
    '/service/status/presence'
    '/service/fnordcredit'
  ]
}
