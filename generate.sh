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

protocol () {
    dir=$1
    name=$2
    gsl -script:scripts/docgen.gsl models/$dir/$name.xml
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
process application error
process application error_subscribe
process application command

protocol machinetalk rpc_protocol
protocol machinetalk pubsub_protocol
protocol halremote halremote_protocol
protocol param param_protocol
protocol application launcher_protocol
protocol application config_protocol
protocol application command_protocol

