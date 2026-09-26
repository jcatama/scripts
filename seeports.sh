#!/usr/bin/env bash
# ports.sh - list listening TCP ports with the process, its executable, and its working dir (macOS)
# Usage:
#   ./ports.sh          all listening ports (your processes)
#   ./ports.sh 3000     only port 3000
#   sudo ./ports.sh     include system/root processes

set -u

filter="${1:-}"

if ! command -v lsof >/dev/null 2>&1; then
  echo "lsof not found" >&2
  exit 1
fi

rows=$(
  lsof +c 0 -nP -iTCP -sTCP:LISTEN -Fpcn 2>/dev/null | awk '
    /^p/ { pid = substr($0, 2); next }
    /^c/ { cmd = substr($0, 2); next }
    /^n/ {
      addr = substr($0, 2)
      port = addr; sub(/.*:/, "", port)
      key = port SUBSEP pid
      if (!(key in seen)) {
        seen[key] = 1; order[++n] = key; c[key] = cmd; a[key] = addr
      } else if (index(a[key], addr) == 0) {
        a[key] = a[key] ", " addr
      }
    }
    END {
      for (i = 1; i <= n; i++) {
        k = order[i]; split(k, kp, SUBSEP)
        printf "%s\t%s\t%s\t%s\n", kp[1], kp[2], c[k], a[k]
      }
    }
  ' | sort -t $'\t' -k1,1n
)

if [ -n "$filter" ]; then
  rows=$(printf '%s\n' "$rows" | awk -F '\t' -v p="$filter" '$1 == p')
fi

if [ -z "$rows" ]; then
  echo "No listening ports found${filter:+ on $filter}."
  exit 0
fi

printf '%s\n' "$rows" | while IFS=$'\t' read -r port pid cmd addr; do
  exe=$(ps -p "$pid" -o comm= 2>/dev/null)
  cwd=$(lsof -a -p "$pid" -d cwd -Fn 2>/dev/null | awk '/^n/ { print substr($0, 2) }')
  args=$(ps -p "$pid" -o args= 2>/dev/null | cut -c1-120)

  echo "Port $port  |  $cmd (PID $pid)"
  echo "  listen: $addr"
  echo "  exe:    ${exe:-?}"
  echo "  dir:    ${cwd:-?}"
  echo "  cmd:    ${args:-?}"
  echo
done
