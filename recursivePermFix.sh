#!/bin/sh

find /dest/* -exec sh -c '
    dest_file="$1"
    src_file="/src${dest_file#/dest}"
    if [ -e "$src_file" ]; then
        chmod -c --reference="$src_file" "$dest_file" && \
        chown -hc --reference="$src_file" "$dest_file" 
    fi
' sh {} \;
