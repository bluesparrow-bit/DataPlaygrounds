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
  # The NameNode metadata survives restarts, but the HA znode may not (fresh
  # `zk-data` volume, `down -v`, manual cleanup). Ensure it exists without
  # wiping it.
  #
  # Never call bare `hdfs zkfc -formatZK` here: when the znode already exists
  # it asks "Proceed formatting ...? (Y or N)". Container stdin is /dev/null,
  # so Hadoop's confirmPrompt() reads EOF and retries forever ("Invalid
  # input:"), leaving master1 stuck before the NameNode ever starts.
  #
  # -nonInteractive turns that prompt into exit code ERR_CODE_FORMAT_DENIED
  # (2), which for us means "already formatted, leave it alone".
  echo "[init] metadata found: ensuring HA znode exists"
  if hdfs zkfc -formatZK -nonInteractive; then
    echo "[init] HA znode created"
  else
    rc=$?
    if [ "$rc" -eq 2 ]; then
      echo "[init] HA znode already exists: keeping failover state"
    else
      echo "[init] ERROR: zkfc -formatZK failed (exit $rc)" >&2
      exit "$rc"
    fi
  fi
fi

if [ ! -f "$VERSION" ]; then
  echo "[init] ERROR: NameNode metadata was not created" >&2
  exit 1
fi

hdfs --daemon start namenode
hdfs --daemon start zkfc
exec yarn resourcemanager
