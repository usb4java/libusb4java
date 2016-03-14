#!/bin/sh

# Passes on warning
CFLAGS+=" -Wno-error"

cmake .
