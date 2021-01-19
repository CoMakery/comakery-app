#!/bin/bash

if [ ! -f .env ]; then
  cp .env.required .env
fi

exec "$@"
