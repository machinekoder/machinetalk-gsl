#!/usr/bin/env bash

mk_dirs () {
    dir=$1
    mkdir -p generated/doc/$dir
    mkdir -p generated/python/$dir
    mkdir -p generated/nodejs/$dir
    mkdir -p generated/js/$dir
    mkdir -p generated/qt/$dir
    mkdir -p generated/uppaal/$dir
    mkdir -p generated/fsm/$dir
}

clean_dirs() {
    dir=$1
    rm -f generated/doc/$dir/*
    rm -f generated/python/$dir/*
    rm -f generated/nodejs/$dir/*
    rm -f generated/js/$dir/*
    rm -f generated/qt/$dir/*
    rm -f generated/uppaal/$dir/*
}

component () {
    dir=$1
    name=$2
    gsl -script:scripts/pygen.gsl models/$dir/$name.xml
    gsl -script:scripts/qtgen.gsl models/$dir/$name.xml
    gsl -script:scripts/jsgen.gsl models/$dir/$name.xml
    gsl -script:scripts/js2gen.gsl models/$dir/$name.xml
    gsl -script:scripts/dotgen.gsl models/$dir/$name.xml
}

protocol () {
    dir=$1
    name=$2
    gsl -script:scripts/docgen.gsl models/$dir/$name.xml
    gsl -script:scripts/uppaalgen.gsl models/$dir/$name.xml
}

mk_dirs common
mk_dirs halremote
mk_dirs param
mk_dirs application
mk_dirs pathview

if [ "$1" = "components" ]; then
component common rpc_client
component common rpc_service
component common subscribe
component common publish
component common sync_client
component halremote halrcomp
component halremote halrcomp_subscribe
component param param_client
component param param_server
component application launcher
component application launcher_subscribe
component application config
component application error
component application error_subscribe
component application command
component application status
component application status_subscribe
component pathview previewclient
component pathview preview_subscribe
fi

if [ "$1" = "protocols" ]; then
protocol common rpc_protocol
protocol common pubsub_protocol
protocol halremote halremote_protocol
protocol param param_protocol
protocol application launcher_protocol
protocol application config_protocol
protocol application command_protocol
protocol application status_protocol
protocol pathview preview_protocol
fi

if [ "$1" = "clean" ]; then
clean_dirs common
clean_dirs application
clean_dirs halremote
clean_dirs param
clean_dirs pathview
fi
