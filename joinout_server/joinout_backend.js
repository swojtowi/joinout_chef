// based on http://pixelhandler.com/posts/develop-a-restful-api-using-nodejs-with-express-and-mongoose
// http://synthmedia.co.uk/blog/basic-nodejs-api-with-restify-and-save#.U3HaaXV53IA
mongoose = require('mongoose');

var port = 8080;

// Database
mongoose.connect('mongodb://localhost/test');

// create schema and model
var Schema = mongoose.Schema;  
var User = new Schema({  
    user_id: { type: String, required: true },  
    user_name: { type: String, unique: true },  
    user_creation_date: { type: Date, default: Date.now },
    user_last_activity_date: { type: Date, required: true }
});

var UserModel = mongoose.model('User', User);  

var Call = new Schema({  
    origin_id: { type: String, required: true },  
    terminating_id: { type: String, required: true },  
    event_type: { type: String, required: true },
    event_date: { type: Date, default: Date.now }
});
var CallModel = mongoose.model('Call', Call); 


var ClientError = new Schema({  
    errorUrl: { type: String},  
    errorMessage: { type: String },  
    stackTrace: { type: String },
    cause: { type: String },
    errorTimestamp: { type: Date, default: Date.now }
});
var ClientErrorModel = mongoose.model('ClientError', ClientError); 


// create a server
var restify = require('restify'),
    server = restify.createServer({
        name: 'JoinOut Rest'
    });
server.use(restify.gzipResponse());
server.use(restify.bodyParser());

//setup cors
restify.CORS.ALLOW_HEADERS.push('accept');
restify.CORS.ALLOW_HEADERS.push('sid');
restify.CORS.ALLOW_HEADERS.push('lang');
restify.CORS.ALLOW_HEADERS.push('origin');
restify.CORS.ALLOW_HEADERS.push('withcredentials');
restify.CORS.ALLOW_HEADERS.push('x-requested-with');
server.use(restify.CORS());
server.use(restify.fullResponse());
function unknownMethodHandler(req, res) {
  if (req.method.toLowerCase() === 'options') {
      console.log('received an options method request');
    var allowHeaders = ['Accept', 'Accept-Version', 'Content-Type', 'Api-Version', 'Origin', 'X-Requested-With']; // added Origin & X-Requested-With

    if (res.methods.indexOf('OPTIONS') === -1) res.methods.push('OPTIONS');

    res.header('Access-Control-Allow-Credentials', true);
    res.header('Access-Control-Allow-Headers', allowHeaders.join(', '));
    res.header('Access-Control-Allow-Methods', res.methods.join(', '));
    res.header('Access-Control-Allow-Origin', req.headers.origin);

    return res.send(204);
  }
  else
    return res.send(new restify.MethodNotAllowedError());
}
server.on('MethodNotAllowed', unknownMethodHandler);


// GET a List of Users
// curl http://localhost:8080/users
server.get('/users', function (req, res){
  return UserModel.find(function (err, products) {
    if (!err) {
      return res.send(products);
    } else {
      return console.log(err);
    }
  });
});


// CREATE a Single User
// curl -i -X POST  http://localhost:8080/users -d '{ "user_name":"John Rabmo", "user_id":"997" }'
server.post('/users', function (req, res){
  var product;
  var json = JSON.parse(req.body);

  product = new UserModel({
    user_id:json.user_id,
    user_name:json.user_name,
    user_last_activity_date:new Date()
  });
  product.save(function (err) {
    if (!err) {
      return console.log("created");
    } else {
      return console.log(err);
    }
  });
  return res.send(product);
});

// UPDATE a Single User (update its last_activity_date)
// curl -i -X PUT  http://193.187.64.99:8080/users/08908808883279562
// other possibility described here: http://mongoosejs.com/docs/2.7.x/docs/updating-documents.html
server.put('/users/:id', function (req, res){
        UserModel.findOne({ user_id:req.params.id }, function (err, user){
          user.user_last_activity_date = new Date() ;
          user.save(function (err) {
                if (!err) {
                  return console.log("updated");
                } else {
                  return console.log(err);
                }
          });
        });
  return res.send("200 OK");
});

// GET all calls
//curl http://localhost:8080/calls
server.get('/calls', function (req, res){
  return CallModel.find(function (err, calls) {
    if (!err) {
      return res.send(calls);
    } else {
      return console.log(err);
    }
  });
});


// Store information about call
//curl -i -X POST  http://localhost:8080/calls/aa1/bb1 -d '{ "event_type":"start call"}'
server.post('/calls/:origid/:termid', function (req, res){
	 var call;
	  var json = JSON.parse(req.body);

	  call = CallModel({
		  origin_id:req.params.origid,  
		  terminating_id:req.params.termid,  
		  event_type:json.event_type
	  });
	  call.save(function (err) {
	    if (!err) {
	      return console.log("logged");
	    } else {
	      return console.log(err);
	    }
	  });
	  return res.send(call);
});


// Store error logs
//curl -i -X POST  http://localhost:8080/errors -d '{ "errorUrl":"http://www.wp.pl", "errorMessage":"File not found","stackTrace":"Some stacktrace","cause":"Some cause"}'
server.post('/errors', function (req, res){
	  var json = JSON.parse(req.body);

	  client_err = ClientErrorModel({
		  errorUrl:json.errorUrl,  
		  errorMessage:json.errorMessage,  
		  stackTrace:json.stackTrace,  
		  cause:json.cause
	  });
	  client_err.save(function (err) {
	    if (!err) {
	      return console.log("Client Error logged");
	    } else {
	      return console.log(err);
	    }
	  });
	  return res.send(client_err);
});

// GET all errors
//curl http://localhost:8080/errors
server.get('/errors', function (req, res){
  return ClientErrorModel.find(function (err, client_err) {
    if (!err) {
      return res.send(client_err);
    } else {
      return console.log(err);
    }
  });
});

server.listen(port);
console.log('Starting Joinout Backend on port: ' + port);
