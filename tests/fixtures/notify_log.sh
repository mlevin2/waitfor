#!/bin/sh
# For tests: appends "title|body" to $NOTIFY_LOG
[ -n "${NOTIFY_LOG-}" ] || exit 0
printf '%s\n' "$1 | $2" >>"$NOTIFY_LOG"
