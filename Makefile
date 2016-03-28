# Makefile for machinekit-gsl

all: components protocols

components:
	bash generate.sh components

protocols:
	bash generate.sh protocols

watch:
	ls generate.sh models/*/*.xml scripts/*.gsl | entr bash -c "bash generate.sh components"

clean:
	bash generate.sh clean
