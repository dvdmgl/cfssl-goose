#!/bin/sh
set -e

if [ "$1" = 'cfssl' ]; then
	exec su-exec cfssl "$@"
fi

exec "$@"
