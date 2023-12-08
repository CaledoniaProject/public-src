var system = require('system');
var args = system.args;

var server = args[1]
var data = 'password=' + args[2]
var id = server.replace(/.*\//, '')
var page = require('webpage').create()
page.customHeaders = {
  Cookie: ''
};
page.viewportSize = {
  width: 1024,
  height: 768
};
page.open(server, 'post', data, function(status) {
  if (status !== 'success') {
    console.log('Unable to save', id);
  } else {
    console.log('Wrote', id)
    page.render('png/' + id + '.png');
  }
  phantom.exit();
});
