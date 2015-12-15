#!/usr/bin/env bash
process () {
name=$1
gsl -script:pygen.gsl $name.xml
gsl -script:qtgen.gsl $name.xml
gsl -script:dotgen.gsl $name.xml
gsl -script:docgen.gsl $name.xml
#dot -Tpng generated/machinetalk_$name.dot > generated/machinetalk_$name.png
}

mkdir -p generated
rm generated/*
#gsl -script:test.gsl rpc_client.xml
process rpc_client
process rpc_service
process subscribe
process publish
process sync_client
process halrcomp
