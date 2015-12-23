var machinetalk = require('machinetalk');
var machinetalkbrowser = new machinetalk.MachineTalkBrowser();
var Subscribe = require('./machinetalk/subscribe.js');

machinetalkbrowser.on('serviceUp', function(machine, service, dsn) {
  if (service === 'status') {
      console.log('found');
      initializeStatusClient(dsn);
  }
});

machinetalkbrowser.start();

function initializeStatusClient(dsn, topic) {
    var x = new Subscribe('test', 2);
    x.socket_uri = 'task';
    x.start();
}
