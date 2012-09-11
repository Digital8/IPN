express = require 'express'
routes = require './routes'
http = require 'http'
fs = require 'fs'
ipn = require 'paypal-ipn'

app = express()

app.configure ->
  app.set 'views', __dirname + '/views'
  app.set 'view engine', 'jade'
  app.use express.favicon()
  app.use express.logger('dev')
  app.use express.bodyParser()
  app.use express.methodOverride()
  app.use app.router
  app.use express.static(__dirname + '/public')

app.configure 'development', ->
  app.use express.errorHandler()

app.get '/', routes.index

app.all '/ipn', (req, res) ->
  ipn.verify req.body, (err, msg) ->
    if err
      console.log "Error: #{msg}"
      res.end()
    else
      fs.writeFile './ipn.txt', JSON.stringify(req.body), ->
        console.log msg
        res.end()

http.createServer(app).listen 3003, ->
  console.log "IPN SERVER STARTED"
