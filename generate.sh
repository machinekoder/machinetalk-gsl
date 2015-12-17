#!/usr/bin/env bash
process () {
name=$1
gsl -script:pygen.gsl $name.xml
gsl -script:qtgen.gsl $name.xml
gsl -script:dotgen.gsl $name.xml
}

mkdir -p generated
rm generated/*
process rpc_client
process rpc_service
process subscribe
process publish
process sync_client
process halrcomp
gsl -script:docgen.gsl rpc_protocol.xml
gsl -script:docgen.gsl pubsub_protocol.xml
gsl -script:docgen.gsl halremote_protocol.xml
