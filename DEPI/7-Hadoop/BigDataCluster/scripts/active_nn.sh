#!/usr/bin/env bash
# Master 1 (active NameNode) bootstrap.
# Idempotent on purpose: the real evidence of "already formatted" is the
# VERSION file inside the bind-mounted data dir. No marker file, so wiping the
# data dir can never leave the cluster in a fake "done" state.
set -euo pipefail

VERSION=/opt/hadoop/dfs/name/current/VERSION

if [ ! -f "$VERSION" ]; then
  echo "[init] first boot: formatting NameNode and HA state"
  hdfs zkfc -formatZK -force
  hdfs namenode -format -force
fi

if [ ! -f "$VERSION" ]; then
  echo "[init] ERROR: NameNode metadata was not created" >&2
  exit 1
fi

hdfs --daemon start namenode
hdfs --daemon start zkfc
exec yarn resourcemanager
