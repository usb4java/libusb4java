#!/bin/sh

# Passes on warning
CFLAGS="-Wno-error"

set -e

cmake .
