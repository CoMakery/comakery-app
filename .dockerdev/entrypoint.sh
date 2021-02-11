#!/bin/bash

if [ -f /app/tmp/pids/server.pid ]; then
  rm /app/tmp/pids/server.pid
fi

if [ ! -f .env ]; then
  cp .env.required .env
fi

exec "$@"
