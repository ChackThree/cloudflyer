#!/bin/bash

exec /dockerstartup/vnc_startup.sh  > /dev/null 2>&1 &

cd /app
/app/venv/bin/python -m cloudflyer -K dev
