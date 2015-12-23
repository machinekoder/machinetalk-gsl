//var machinetalk = require('machinetalk');
//var machinetalkbrowser = new machinetalk.MachineTalkBrowser();
var HalRemoteComponentBase = require('./halremote/remotecomponentbase.js');
var mdns = require('mdns-js');
var url = require('url');
var util = require('util');
//if you have another mdns daemon running, like avahi or bonjour, uncomment following line
mdns.excludeInterface('0.0.0.0');

var halrcompBrowser = mdns.createBrowser('_halrcomp._sub._machinekit._tcp');
var halrcmdBrowser = mdns.createBrowser('_halrcmd._sub._machinekit._tcp');

halrcompBrowser.on('ready', function () {
    halrcompBrowser.discover();
});

halrcmdBrowser.on('ready', function () {
    halrcmdBrowser.discover();
});

function resolveDsn(data) {
    var dsn;
    var service;
    txt = data.txt;
    address = data.addresses[0];
    port = data.port;
    for (var i = 0; i < txt.length; ++i) {
        entries = txt[i].split('=');
        if (entries[0] == 'dsn') {
            dsn = entries[1];
        }
        else if (entries[0] == 'service') {
            service = entries[1];
        }
    }
    dsn = url.parse(dsn);
    dsn.host = address + ':' + port;
    dsn = url.format(dsn);
    return {dsn: dsn, service: service};;
}

halrcompDsn = '';
halrcmdDsn = '';
found = false;
function evalDsn() {
    if ((halrcmdDsn != '') && (halrcompDsn != '') && !found) {
        found = true;
        initializeComponent(halrcmdDsn, halrcompDsn);
    }
}

halrcompBrowser.on('update', function (data) {
    var resolved = resolveDsn(data);
    console.log(resolved);
    if (resolved.service == 'halrcomp') {
        halrcompDsn = resolved.dsn;
    }
    else {
        halrcmdDsn = resolved.dsn;
    }
    evalDsn();
});

halrcmdBrowser.on('update', function (data) {
    //var dsn = resolveDsn(data);
    //halrcmdDsn = dsn;
    //evalDsn();
});

function HalRemoteComponent(debugname, debuglevel) {
    HalRemoteComponent.super_.call(this);
    this.debugname = debugname
    this.debuglevel = debuglevel
}
util.inherits(HalRemoteComponent, HalRemoteComponentBase);

HalRemoteComponent.prototype.addPins = function() {
    console.log('better');
}

function initializeComponent(halrcmdDsn, halrcompDsn) {
    console.log(halrcmdDsn, halrcompDsn);
    var rcomp = new HalRemoteComponent('test', 1);
    rcomp.addHalrcompTopic('anddemo');
    rcomp.halrcompUri = halrcompDsn;
    rcomp.halrcmdUri = halrcmdDsn;
    rcomp.start();
}
