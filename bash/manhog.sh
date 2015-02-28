#!/bin/bash
find /usr/share/man/ -type f -ls | sort -k 7 -r -n | head -n 1 | awk -F' ' '{print $11}' | sed 's/.*\///'