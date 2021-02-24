var express    = require('express')
var app        = express()
var bodyParser = require('body-parser');
var multer     = require('multer'); 

app.use(bodyParser.json()); // for parsing application/json
app.use(bodyParser.urlencoded({ extended: true })); // for parsing application/x-www-form-urlencoded
app.use(multer()); // for parsing multipart/form-data

app.post ('/', function (req, res) {

})

app.get ('/', function (req, res) {

})

var server = app.listen(3000, function () {
    var host = server.address().address
    var port = server.address().port

    console.log('App listening at http://%s:%s', host, port)
})
