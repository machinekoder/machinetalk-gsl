#!/usr/bin/env bash
process () {
name=$1
gsl -script:scripts/pygen.gsl models/$name.xml
gsl -script:scripts/qtgen.gsl models/$name.xml
gsl -script:scripts/dotgen.gsl models/$name.xml
}

mkdir -p generated/machinetalk
mkdir -p generated/halremote
rm generated/machinetalk/*
rm generated/halremote/*
process rpc_client
process rpc_service
process subscribe
process publish
process sync_client
process halrcomp
process halrcomp_subscribe
gsl -script:scripts/docgen.gsl models/rpc_protocol.xml
gsl -script:scripts/docgen.gsl models/pubsub_protocol.xml
gsl -script:scripts/docgen.gsl models/halremote_protocol.xml
