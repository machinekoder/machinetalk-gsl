#!/usr/bin/env bash
mkdir -p generated
rm generated/*
#gsl -script:test.gsl rpc_client.xml
gsl -script:pygen.gsl rpc_client.xml
gsl -script:qtgen.gsl rpc_client.xml
gsl -script:dotgen.gsl rpc_client.xml
dot -Tpng generated/machinetalk_rpc_client.dot > generated/machinetalk_rpc_client.png
gsl -script:pygen.gsl rpc_service.xml
gsl -script:dotgen.gsl rpc_service.xml
dot -Tpng generated/machinetalk_rpc_service.dot > generated/machinetalk_rpc_service.png

