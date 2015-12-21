#!/usr/bin/env bash
process () {
name=$1
gsl -script:scripts/pygen.gsl models/$name.xml
gsl -script:scripts/qtgen.gsl models/$name.xml
gsl -script:scripts/dotgen.gsl models/$name.xml
}

mkdir -p generated
rm generated/*
process rpc_client
process rpc_service
process subscribe
process publish
process sync_client
process halrcomp
gsl -script:scripts/docgen.gsl models/rpc_protocol.xml
gsl -script:scripts/docgen.gsl models/pubsub_protocol.xml
gsl -script:scripts/docgen.gsl models/halremote_protocol.xml
