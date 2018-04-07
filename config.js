var util = require('util');
var path = require('path');
var hfc = require('fabric-client');

hfc.setConfigSetting('network-connection-profile-path',path.join(__dirname, 'artifacts', 'network-config.yaml'));
hfc.setConfigSetting('fredrick-connection-profile-path',path.join(__dirname, 'artifacts', 'fredrick.yaml'));
hfc.setConfigSetting('alice-connection-profile-path',path.join(__dirname, 'artifacts', 'alice.yaml'));
hfc.setConfigSetting('bob-connection-profile-path',path.join(__dirname, 'artifacts', 'bob.yaml'));

// some other settings the application might need to know
hfc.addConfigFile(path.join(__dirname, 'config.json'));
