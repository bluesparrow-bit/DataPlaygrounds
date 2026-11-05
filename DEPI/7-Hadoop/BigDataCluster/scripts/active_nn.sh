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
else
  # ZooKeeper has no persistent volume, so `docker compose down` can wipe the
  # HA znode while the NameNode metadata survives. Without -force this call
  # only creates the znode when it is missing and is a no-op otherwise.
  echo "[init] metadata found: ensuring HA znode exists"
  hdfs zkfc -formatZK
fi

if [ ! -f "$VERSION" ]; then
  echo "[init] ERROR: NameNode metadata was not created" >&2
  exit 1
fi

hdfs --daemon start namenode
hdfs --daemon start zkfc
exec yarn resourcemanager
