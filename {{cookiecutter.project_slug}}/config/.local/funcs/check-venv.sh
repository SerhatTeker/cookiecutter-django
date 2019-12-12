#!/bin/bash

set -o errexit
set -o pipefail
set -o nounset

if [ -d $VENV_DIR ];then
    :
else
    echo -e "${COLOR_RED}\$VENV_DIR not found. Build it first"
fi
