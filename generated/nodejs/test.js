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
    HalRemoteComponent.super_.apply(this, [debugname, debuglevel]);
    this.debugname = debugname
    this.debuglevel = debuglevel

    this.pins = {} // pinsbyname
    this.pinsbyhandle = {}
}
util.inherits(HalRemoteComponent, HalRemoteComponentBase);

HalRemoteComponent.prototype.addPins = function() {
    console.log('should add pins here');
}

HalRemoteComponent.prototype.removePins = function() {
    console.log('should remove pins here');
}

HalRemoteComponent.prototype.unsyncPins = function() {
    console.log('unsyncing pins');
}

HalRemoteComponent.prototype.synced = function() {
    console.log('now synced');
}

HalRemoteComponent.prototype.bind = function() {
    console.log('time to bind the component');
    this.noBind();
}

HalRemoteComponent.prototype.pinUpdate = function(rpin, lpin) {

    if (rpin.halfloat !== null) {
        lpin.value = rpin.halfloat;
        lpin.synced = true;
    }
    else if (rpin.halbit !== null) {
        lpin.value = rpin.halbit;
        lpin.synced = true;
    }
    else if (rpin.hals32 !== null) {
        lpin.value = rpin.hals32;
        lpin.synced = true;
    }
    else if (rpin.halu32 !== null) {
        lpin.value = rpin.halu32;
        lpin.synced = true;
    }
}

HalRemoteComponent.prototype.halrcompFullUpdateReceived = function(topic, rx) {
    console.log('full update received');

    var comp = rx.comp[0];
    for (var i = 0; i < comp.pin.length; ++i) {
        var rpin = comp.pin[i];
        var name = rpin.name.split('.')[1];
        if (this.pins[name] === undefined) {  // new pin
            this.pins[name] = {type: rpin.type,
                               direction: rpin.dir,
                               synced: false}
        }
        this.pinsbyhandle[rpin.handle] = this.pins[name]; // create reference
        this.pinUpdate(rpin, this.pins[name]);
    }
}

HalRemoteComponent.prototype.halrcompIncrementalUpdateReceived = function(topic, rx) {
    console.log('incremental update received');

    for (var i = 0; i < rx.pin.length; ++i) {
        var rpin = rx.pin[i];
        this.pinUpdate(rpin, this.pinsbyhandle[rpin.handle]);
    }
}

function initializeComponent(halrcmdDsn, halrcompDsn) {
    console.log(halrcmdDsn, halrcompDsn);
    var rcomp = new HalRemoteComponent('test', 0);
    rcomp.addHalrcompTopic('anddemo');
    rcomp.halrcompUri = halrcompDsn;
    rcomp.halrcmdUri = halrcmdDsn;
    rcomp.start();
}
