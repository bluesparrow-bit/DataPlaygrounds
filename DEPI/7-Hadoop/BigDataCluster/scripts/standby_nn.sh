#!/usr/bin/env bash
# Master 2 (standby NameNode) bootstrap.
# Bootstraps only when the data dir has no VERSION file, i.e. on a real first
# boot. A failed bootstrap leaves no VERSION behind, so the next start retries
# instead of silently skipping setup.
set -euo pipefail

VERSION=/opt/hadoop/dfs/name/current/VERSION

if [ ! -f "$VERSION" ]; then
  echo "[init] first boot: bootstrapping standby from the active NameNode"
  hdfs namenode -bootstrapStandby -force
fi

if [ ! -f "$VERSION" ]; then
  echo "[init] ERROR: standby metadata was not bootstrapped" >&2
  exit 1
fi

hdfs --daemon start namenode
hdfs --daemon start zkfc
exec yarn resourcemanager
