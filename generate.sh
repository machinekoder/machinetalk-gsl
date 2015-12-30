#!/usr/bin/env bash
process () {
dir=$1
name=$2
mkdir -p generated/doc/$dir
mkdir -p generated/python/$dir
mkdir -p generated/nodejs/$dir
mkdir -p generated/qt/$dir
gsl -script:scripts/pygen.gsl models/$dir/$name.xml
gsl -script:scripts/qtgen.gsl models/$dir/$name.xml
gsl -script:scripts/jsgen.gsl models/$dir/$name.xml
gsl -script:scripts/dotgen.gsl models/$dir/$name.xml
}

process machinetalk rpc_client
process machinetalk rpc_service
process machinetalk subscribe
process machinetalk publish
process machinetalk sync_client
process halremote halrcomp
process halremote halrcomp_subscribe
process param param_client
process param param_server
process application launcher
process application launcher_subscribe
process application config
gsl -script:scripts/docgen.gsl models/machinetalk/rpc_protocol.xml
gsl -script:scripts/docgen.gsl models/machinetalk/pubsub_protocol.xml
gsl -script:scripts/docgen.gsl models/halremote/halremote_protocol.xml
gsl -script:scripts/docgen.gsl models/param/param_protocol.xml
gsl -script:scripts/docgen.gsl models/application/launcher_protocol.xml
gsl -script:scripts/docgen.gsl models/application/config_protocol.xml
