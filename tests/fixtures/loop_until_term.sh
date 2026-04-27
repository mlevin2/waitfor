#!/usr/bin/env bash
set -euo pipefail

term=0
trap 'term=1' TERM INT

while [[ "$term" -eq 0 ]]; do
  sleep 0.2
done
