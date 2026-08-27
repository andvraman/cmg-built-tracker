#!/usr/bin/env bash
# Serve the chairperson voice prototype.
#
#   ./serve.sh              -> http://localhost:8000  (this Mac only)
#   ./serve.sh --tunnel     -> also opens an https:// URL that works on a phone
#
# Why a tunnel is needed for the phone: iOS and Android refuse microphone access
# unless the page is on https. The localhost exemption applies only to the device
# running the server, so http://<your-mac-ip>:8000 will load on the phone but the
# microphone will be refused. A tunnel gives a real https URL and costs nothing.
set -euo pipefail
cd "$(dirname "$0")"
PORT="${PORT:-8000}"

python3 -m http.server "$PORT" >/dev/null 2>&1 &
SERVER=$!
trap 'kill $SERVER 2>/dev/null || true' EXIT
sleep 1
echo "serving $(pwd) on http://localhost:$PORT"
echo "  spike:  http://localhost:$PORT/spike.html"

if [ "${1:-}" = "--tunnel" ]; then
  if command -v cloudflared >/dev/null 2>&1; then
    echo
    echo "opening an https tunnel — use the trycloudflare.com URL on your phone"
    cloudflared tunnel --url "http://localhost:$PORT"
  elif command -v ngrok >/dev/null 2>&1; then
    echo
    echo "opening an https tunnel — use the ngrok URL on your phone"
    ngrok http "$PORT"
  else
    echo
    echo "No tunnel tool found. Install one of:"
    echo "    brew install cloudflared     # no account needed"
    echo "    brew install ngrok           # account needed"
    echo "Then re-run:  ./serve.sh --tunnel"
    wait $SERVER
  fi
else
  wait $SERVER
fi
