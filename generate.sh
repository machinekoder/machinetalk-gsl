#!/usr/bin/env bash
process () {
name=$1
gsl -script:scripts/pygen.gsl models/$name.xml
gsl -script:scripts/qtgen.gsl models/$name.xml
gsl -script:scripts/jsgen.gsl models/$name.xml
gsl -script:scripts/dotgen.gsl models/$name.xml
}

mkdir -p generated/machinetalk
mkdir -p generated/halremote
mkdir -p generated/param
rm generated/machinetalk/*
rm generated/halremote/*
rm generated/param/*
process rpc_client
process rpc_service
process subscribe
process publish
process sync_client
process halrcomp
process halrcomp_subscribe
process param_client
process param_server
gsl -script:scripts/docgen.gsl models/rpc_protocol.xml
gsl -script:scripts/docgen.gsl models/pubsub_protocol.xml
gsl -script:scripts/docgen.gsl models/halremote_protocol.xml
gsl -script:scripts/docgen.gsl models/param_protocol.xml
