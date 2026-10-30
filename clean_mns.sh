#!/bin/bash

find ./dataset -type f -name "*.mns" -exec sed -i '' \
    -e '/^\*.:/d' \
    -e '/^\*-/d' \
    -e '/\*M/d' \
    -e '/^\.$/d' \
    -e '/^!/d' \
    -e '/^\*k\[\]/d' \
    -e 's/[ip]//g' \
    -e 's/^\*custos:\(.*\)$/\*custos\1/' \
    {} +
