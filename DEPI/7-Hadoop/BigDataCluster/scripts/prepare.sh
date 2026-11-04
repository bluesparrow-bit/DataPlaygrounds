#!/usr/bin/env bash
# One-command start: fixes bind-mount ownership, then brings the cluster up.
# Safe to run as many times as you like. Needs no sudo (docker group is enough).
set -euo pipefail
cd "$(dirname "$0")/.."

mkdir -p volumes/master1/namenode volumes/master2/namenode volumes/jn1

# The containers run as uid 1002, which is a member of gid 1001 ("hadoop").
# Give your own user ownership (so you can still browse the data) and the
# container group write access. The setgid bit makes new files inherit gid 1001.
HOST_UID="$(id -u)"
docker run --rm -v "$PWD/volumes:/v" --user 0 \
  --entrypoint /bin/sh ysfetman/bdss-hadoop-base:3.4.2 -c \
  "chown -R ${HOST_UID}:1001 /v/master1/namenode /v/master2/namenode /v/jn1 &&
   chmod -R 2775 /v/master1/namenode /v/master2/namenode /v/jn1"

docker compose up -d "$@"
