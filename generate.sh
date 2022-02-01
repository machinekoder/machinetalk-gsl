#!/usr/bin/env bash

mk_dirs () {
    dir=$1
    mkdir -p generated/doc/$dir
    mkdir -p generated/python/$dir
    mkdir -p generated/nodejs/$dir
    mkdir -p generated/js/$dir
    mkdir -p generated/qt/$dir
    mkdir -p generated/uppaal/$dir
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

mk_dirs machinetalk/common
mk_dirs machinetalk/halremote
mk_dirs machinetalk/param
mk_dirs machinetalk/application
mk_dirs machinetalk/pathview
mk_dirs machinetalk/remotefile

if [ "$1" = "components" ]; then
component machinetalk/common rpc_client
component machinetalk/common rpc_service
component machinetalk/common subscribe
component machinetalk/common simple_subscribe
component machinetalk/common publish
component machinetalk/common sync_client
component machinetalk/halremote halrcomp
component machinetalk/halremote halrcomp_subscribe
component machinetalk/param param_client
component machinetalk/param param_server
component machinetalk/application launcher
component machinetalk/application launcher_subscribe
component machinetalk/application config
component machinetalk/application error
component machinetalk/application error_subscribe
component machinetalk/application command
component machinetalk/application status
component machinetalk/application status_subscribe
component machinetalk/application logbase
component machinetalk/application logservice
component machinetalk/pathview previewclient
component machinetalk/pathview preview_subscribe
component machinetalk/remotefile file
component machinetalk/remotefile file_service

fi

if [ "$1" = "protocols" ]; then
protocol machinetalk/common rpc_protocol
protocol machinetalk/common pubsub_protocol
protocol machinetalk/halremote halremote_protocol
protocol machinetalk/param param_protocol
protocol machinetalk/application launcher_protocol
protocol machinetalk/application config_protocol
protocol machinetalk/application command_protocol
protocol machinetalk/application status_protocol
protocol machinetalk/application log_protocol
protocol machinetalk/pathview preview_protocol
protocol machinetalk/remotefile file_protocol

fi

if [ "$1" = "clean" ]; then
clean_dirs machinetalk/common
clean_dirs machinetalk/application
clean_dirs machinetalk/halremote
clean_dirs machinetalk/param
clean_dirs machinetalk/pathview
clean_dirs machinetalk/remotefile
fi
