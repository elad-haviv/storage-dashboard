#!/bin/sh
set -eu
: "${API_ADMIN_KEY:?Missing Garage admin token}"
: "${OAUTH2_PROXY_CLIENT_ID:?Missing Google client ID}"
: "${OAUTH2_PROXY_CLIENT_SECRET:?Missing Google client secret}"
: "${OAUTH2_PROXY_COOKIE_SECRET:?Missing cookie secret}"
HOST=127.0.0.1 PORT=3909 /usr/local/bin/garage-webui &
UI_PID=$!
/usr/local/bin/oauth2-proxy --config=/etc/oauth2-proxy.cfg &
AUTH_PID=$!
trap 'kill "$UI_PID" "$AUTH_PID" 2>/dev/null || true; wait || true' EXIT
trap 'exit 0' TERM INT
while kill -0 "$UI_PID" 2>/dev/null && kill -0 "$AUTH_PID" 2>/dev/null; do
  sleep 2 & wait $! || true
done
exit 1
