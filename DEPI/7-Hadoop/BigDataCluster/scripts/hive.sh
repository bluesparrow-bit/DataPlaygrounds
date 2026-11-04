#!/usr/bin/env bash
# Hive bootstrap. Every step is checked against the real artefacts it creates,
# so a failure is retried on the next start instead of being masked by a marker.
set -euo pipefail

# 1. Tez on HDFS (skip when already uploaded)
if ! hdfs dfs -test -e /apps/tez/apache-tez-0.10.5-bin.tar.gz || \
   ! hdfs dfs -test -e /apps/tez/tez; then
  echo "[init] uploading Tez to HDFS"
  hdfs dfs -mkdir -p /apps/tez
  hdfs dfs -put -f /opt/apache-tez-0.10.5-bin.tar.gz /apps/tez
  hdfs dfs -put -f /opt/tez /apps/tez
fi

# 2. Hive directories (mkdir -p keeps restarts safe)
echo "[init] ensuring Hive directories"
hdfs dfs -mkdir -p /user/hive/warehouse /user/hive/external /tmp
hdfs dfs -mkdir -p hdfs:///user/iceberg/warehouse/default
hdfs dfs -chmod 1777 /tmp

# 3. Metastore schema (schematool -info fails when the schema is missing)
if ! schematool -dbType postgres -info >/dev/null 2>&1; then
  echo "[init] initialising Hive metastore schema"
  schematool -dbType postgres -initSchema
fi

# 4. Ship Hive jars to the Spark workers (non-fatal: Hive works without them)
for w in worker1 worker2 worker3 worker4; do
  scp -o StrictHostKeyChecking=no -r /opt/hive/lib/* "$w":/opt/spark/hive/jars \
    || echo "[warn] could not copy Hive jars to $w" >&2
done

hive --service metastore 2>&1 | tee /opt/hive/logs/metastore.log &
rm -f /opt/hive/hiveserver2.pid 2>/dev/null || true
exec hive --service hiveserver2
