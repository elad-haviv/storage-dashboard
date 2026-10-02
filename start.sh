#!/bin/sh
set -eu
: "${API_ADMIN_KEY:?Missing Garage admin token}"
: "${OAUTH2_PROXY_CLIENT_ID:?Missing Google client ID}"
: "${OAUTH2_PROXY_CLIENT_SECRET:?Missing Google client secret}"
: "${OAUTH2_PROXY_COOKIE_SECRET:?Missing cookie secret}"
HOST=127.0.0.1 PORT=3909 /usr/local/bin/garage-webui &
UI_PID=$!
# Verify Garage connectivity before exposing the login gateway.
READY=0
for ATTEMPT in 1 2 3 4 5 6 7 8 9 10; do
  if curl -fsS --max-time 10 http://127.0.0.1:3909/api/buckets -o /dev/null; then
    READY=1
    break
  fi
  sleep 2
done
if [ "$READY" -ne 1 ]; then
  echo "Garage dashboard backend connectivity check failed" >&2
  kill "$UI_PID" 2>/dev/null || true
  exit 1
fi
echo "Garage dashboard bucket API connectivity verified"
/usr/local/bin/oauth2-proxy --config=/etc/oauth2-proxy.cfg &
AUTH_PID=$!
trap 'kill "$UI_PID" "$AUTH_PID" 2>/dev/null || true; wait || true' EXIT
trap 'exit 0' TERM INT
while kill -0 "$UI_PID" 2>/dev/null && kill -0 "$AUTH_PID" 2>/dev/null; do
  sleep 2 & wait $! || true
done
exit 1
