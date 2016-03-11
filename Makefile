# Makefile for machinekit-gsl

all:
	bash generate.sh

watch:
	ls generate.sh models/*/*.xml scripts/*.gsl | entr bash -c "bash generate.sh"
