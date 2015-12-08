#!/usr/bin/env bash
#gsl -script:test.gsl rpc_client.xml
gsl -script:pygen.gsl rpc_client.xml
gsl -script:dotgen.gsl rpc_client.xml
dot -Tpng generated/rpcclient.dot > generated/rpcclient.png
gsl -script:pygen.gsl rpc_service.xml
gsl -script:dotgen.gsl rpc_service.xml
dot -Tpng generated/rpcservice.dot > generated/rpcservice.png

