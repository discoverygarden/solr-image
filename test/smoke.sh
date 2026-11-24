#!/usr/bin/env bash
# Smoke test: Solr starts (with a known test credential substituted for the
# production one), the islandora8 core loads, and the JMX exporter serves metrics.
# Usage: test/smoke.sh <image>
set -euo pipefail
IMAGE="${1:?usage: $0 <image>}"
NAME="solr-smoke-$$"
PORT="${SMOKE_PORT:-18983}"
# Known test credential (Solr's documented default hash for "SolrRocks"), so the
# smoke test does not depend on the production password.
AUTH="drupal:SolrRocks"
SECURITY_JSON='{"authentication":{"blockUnknown":true,"class":"solr.BasicAuthPlugin","credentials":{"drupal":"IV0EHq1OnNrj6gvRCwvFwTrZ1+z1oBbnQdiVC3otuq0= Ndd7LKvVBAaZIF0QAVi1ekCfAJXr1GGfLtRUXhgrF8c="}}}'
WORKDIR="$(mktemp -d)"
trap 'rc=$?; [ $rc -ne 0 ] && docker logs "$NAME" >&2 2>&1; docker rm -f "$NAME" >/dev/null 2>&1; rm -rf "$WORKDIR"; exit $rc' EXIT

# The shipped security.json must block unauthenticated access.
docker run --rm --entrypoint cat "$IMAGE" /var/solr/data/security.json | grep -q '"blockUnknown": *true' \
  || { echo "FAIL: shipped security.json does not set blockUnknown" >&2; exit 1; }
echo "ok: shipped security.json blocks unknown users"

printf '%s' "$SECURITY_JSON" > "$WORKDIR/security.json"
chmod 644 "$WORKDIR/security.json"
docker run -d --name "$NAME" -p "${PORT}:8983" \
  -v "$WORKDIR/security.json:/var/solr/data/security.json:ro" "$IMAGE" >/dev/null

echo "waiting for Solr..."
for _ in $(seq 1 120); do
  [ "$(curl -s -o /dev/null -w '%{http_code}' "http://localhost:${PORT}/solr/admin/info/system" || true)" = "401" ] && up=1 && break
  [ "$(docker inspect -f '{{.State.Running}}' "$NAME")" = "true" ] || { echo "FAIL: container exited" >&2; exit 1; }
  sleep 1
done
[ "${up:-0}" = "1" ] || { echo "FAIL: Solr never answered (expected 401 from blockUnknown)" >&2; exit 1; }
echo "ok: Solr up, unauthenticated requests rejected"

curl -sf -u "$AUTH" "http://localhost:${PORT}/solr/admin/info/system?wt=json" | grep -q '"solr-spec-version"' \
  || { echo "FAIL: authenticated system info failed" >&2; exit 1; }
echo "ok: basic auth works"

for _ in $(seq 1 60); do
  status="$(curl -sf -u "$AUTH" "http://localhost:${PORT}/solr/admin/cores?action=STATUS&core=islandora8&wt=json" || true)"
  echo "$status" | grep -q '"instanceDir"' && core=1 && break
  sleep 1
done
[ "${core:-0}" = "1" ] || { echo "FAIL: islandora8 core not loaded: $status" >&2; exit 1; }
echo "ok: islandora8 core loaded"

[ "$(curl -s -u "$AUTH" -o /dev/null -w '%{http_code}' "http://localhost:${PORT}/solr/islandora8/select?q=*:*&rows=0")" = "200" ] \
  || { echo "FAIL: select on islandora8 failed" >&2; exit 1; }
echo "ok: select query on islandora8"

# Capture first: grep -q closing the pipe early would trip pipefail via curl.
metrics="$(docker exec "$NAME" curl -sf http://localhost:3001/metrics)"
grep -qE '^(jvm|java_lang)_' <<<"$metrics" \
  || { echo "FAIL: JMX exporter metrics missing on :3001" >&2; exit 1; }
echo "ok: JMX exporter serving metrics"
echo "smoke test passed"
