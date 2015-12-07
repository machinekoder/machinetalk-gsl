#!/usr/bin/env bash
gsl -script:test.gsl rpc_client.xml
gsl -script:pygen.gsl rpc_client.xml
gsl -script:dotgen.gsl rpc_client.xml
dot -Tpng rpcclient.dot > rpcclient.png

