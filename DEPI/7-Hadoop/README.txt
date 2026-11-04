## BigDataCluster — required changes (PC repo)

The stack must be started with `./scripts/prepare.sh`, NOT plain
`docker compose up -d`, because the bind-mounted HDFS dirs must be writable by
the container user (uid 1002, member of gid 1001 "hadoop").

### Files the PC repo must contain
- scripts/active_nn.sh      (new, executable)   -> copied over /scripts/active_nn.sh
- scripts/standby_nn.sh     (new, executable)   -> copied over /scripts/standby_nn.sh
- scripts/hive.sh           (new, executable)   -> copied over /scripts/hive.sh
- scripts/prepare.sh        (new, executable)   -> fixes ownership + docker compose up -d
- docker-compose.yml        (updated)

### docker-compose.yml changes
1. master1 volumes:
     - ./scripts/active_nn.sh:/scripts/active_nn.sh:ro
2. master2 volumes:
     - ./scripts/standby_nn.sh:/scripts/standby_nn.sh:ro
3. hive volumes:
     - ./scripts/hive.sh:/scripts/hive.sh:ro
4. master1 + master2 healthcheck (replace the old marker-file test):
     test: ["CMD-SHELL", "test -f /opt/hadoop/dfs/name/current/VERSION && nc -z 127.0.0.1 8020"]
     interval: 5s
     timeout: 3s
     retries: 60
     start_period: 30s

### Start / repair
    cd DEPI/7-Hadoop/BigDataCluster
    chmod +x scripts/*.sh
    ./scripts/prepare.sh

### Notes
- The old `.formatted` / `.bootstrapped` marker files are ignored now.
  The scripts use `current/VERSION` as the only proof of a successful setup,
  so a wiped data dir self-heals instead of silently staying "done".
- Do NOT copy HDFS runtime data (namenode/journal) from this laptop to the PC:
  clusterID/storageID are machine-specific. Only notebooks/ and data/ are portable.
- Use 127.0.0.1 (not localhost) in healthchecks: the container resolves
  localhost to IPv6 ::1, but HDFS binds IPv4 only.
- Web UIs: master1 active http://localhost:19870, master2 standby http://localhost:29870.