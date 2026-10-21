# Airflow (Docker) to SQL Server: connection troubleshooting

**Goal:** run Airflow in Docker and let a DAG read and write a SQL Server instance that runs directly on the host machine (not in Docker).

**Placeholders used below. Replace them with your own values:**

| Placeholder | Meaning | Example |
|---|---|---|
| `<INSTANCE>` | SQL Server instance name | `SQLEXPRESS` |
| `<DB_NAME>` | Target database | `Test` |
| `<SQL_LOGIN>` | SQL login Airflow will use | `airflow_user` |
| `<PASSWORD>` | Password for that login | (your own, never committed) |
| `<CONN_ID>` | Airflow Connection ID, must match `conn_id` in the DAG | `mssql` |
| `<PORT>` | Static SQL Server port | `1433` |

---

## 0. Setup decisions

- Airflow lives in an `airflow/` folder inside the repo, with its own `.gitignore`.
- Commit: `docker-compose.yaml`, `.env.example`, `.gitignore`, `dags/`.
- Ignore: `.env`, `logs/`, `config/`, `__pycache__/`.
- Install the MSSQL provider by adding this to `airflow/.env`, then `docker compose down && docker compose up -d`:

```
_PIP_ADDITIONAL_REQUIREMENTS=apache-airflow-providers-microsoft-mssql
```

---

## 1. No password with Windows authentication

**Symptom:** you log in to SQL Server with Windows auth and have no password to give Airflow.

**Cause:** Windows auth trusts your logged-in Windows account. The Airflow container runs Linux and cannot use that login.

**Fix:**

1. Enable mixed mode: SSMS, right-click the server, Properties, Security, select "SQL Server and Windows Authentication mode".
2. Restart the SQL Server service:

```powershell
Restart-Service 'MSSQL$<INSTANCE>'
```

3. Create a SQL login and user with the roles Airflow needs:

```sql
CREATE LOGIN <SQL_LOGIN> WITH PASSWORD = '<PASSWORD>';
USE <DB_NAME>;
CREATE USER <SQL_LOGIN> FOR LOGIN <SQL_LOGIN>;
ALTER ROLE db_datareader ADD MEMBER <SQL_LOGIN>;
ALTER ROLE db_datawriter ADD MEMBER <SQL_LOGIN>;
ALTER ROLE db_ddladmin   ADD MEMBER <SQL_LOGIN>;   -- only if DAGs create/alter tables
```

---

## 2. `Unable to connect: TDS server is unavailable or does not exist (<MACHINE_NAME>)`

**Symptom:** the error names your machine, for example `(BLUE)`.

**Cause:** the Connection's Host contains the machine name or `MACHINE\INSTANCE`. A container cannot resolve the host machine's name, and `localhost` inside a container points at the container itself.

**Fix:** in Admin, Connections, edit `<CONN_ID>`:

| Field | Value |
|---|---|
| Connection Type | Microsoft SQL Server |
| Host | `host.docker.internal` |
| Port | `<PORT>` |
| Schema | `<DB_NAME>` |
| Login | `<SQL_LOGIN>` |
| Password | `<PASSWORD>` |

`host.docker.internal` means "the machine Docker runs on" and works on Docker Desktop (Windows/Mac). On Linux, or if it does not resolve, add this under `x-airflow-common` in `docker-compose.yaml`, then restart the stack:

```yaml
extra_hosts:
  - "host.docker.internal:host-gateway"
```

Also check that the DAG's `conn_id` matches `<CONN_ID>` exactly, and that no `AIRFLOW_CONN_...` variable in `.env` overrides the connection.

---

## 3. `Net-Lib error during Connection refused (111)`

**Symptom:** the host name now resolves, but the connection is refused.

**Cause:** nothing is listening on `<PORT>` on the host. SQL Server Express ships with TCP/IP disabled and a random dynamic port.

**Fix, option A (SQL Server Configuration Manager, run as Administrator):**

1. SQL Server Network Configuration, Protocols for `<INSTANCE>`, right-click TCP/IP, Enable.
2. TCP/IP properties, IP Addresses tab, scroll to IPAll.
3. Clear "TCP Dynamic Ports" (leave empty, not 0). Set "TCP Port" to `<PORT>`.
4. Restart the SQL Server service.

**Fix, option B (if Configuration Manager shows no items under Network Configuration).** Run in an Administrator PowerShell:

```powershell
$root = 'HKLM:\SOFTWARE\Microsoft\Microsoft SQL Server'
Get-ChildItem $root | Where-Object { $_.PSChildName -like 'MSSQL*.<INSTANCE>' } | ForEach-Object {
    $tcp = "$($_.PSPath)\MSSQLServer\SuperSocketNetLib\Tcp"
    Set-ItemProperty $tcp -Name Enabled -Value 1
    Set-ItemProperty "$tcp\IPAll" -Name TcpDynamicPorts -Value ''
    Set-ItemProperty "$tcp\IPAll" -Name TcpPort -Value '<PORT>'
    Write-Host "Updated $($_.PSChildName)"
}
Restart-Service 'MSSQL$<INSTANCE>'
```

If it prints nothing, the instance name differs. Run `Get-Service *SQL*` to find it.

**Then allow the port through the firewall (Administrator PowerShell):**

```powershell
New-NetFirewallRule -DisplayName "SQL Server <PORT>" -Direction Inbound -Protocol TCP -LocalPort <PORT> -Action Allow
```

**Verify:**

```powershell
netstat -an | findstr LISTENING | findstr <PORT>
```

```bash
docker compose exec airflow-worker bash -c "timeout 3 bash -c '</dev/tcp/host.docker.internal/<PORT>' && echo OPEN || echo CLOSED"
```

`OPEN` means the network path works.

---

## 4. `The DELETE permission was denied on the object ...` (error 229)

**Symptom:** the connection and login work and early tasks (for example CREATE TABLE) succeed, but a later task fails with a permission error. The same applies to INSERT or UPDATE.

**Cause:** the SQL login can connect but lacks write rights in the database.

**Fix (run in SSMS as an admin):**

```sql
USE <DB_NAME>;
ALTER ROLE db_datawriter ADD MEMBER <SQL_LOGIN>;
ALTER ROLE db_ddladmin   ADD MEMBER <SQL_LOGIN>;
```

**Verify the roles:**

```sql
SELECT r.name AS role_name
FROM sys.database_role_members rm
JOIN sys.database_principals r ON rm.role_principal_id = r.principal_id
JOIN sys.database_principals u ON rm.member_principal_id = u.principal_id
WHERE u.name = '<SQL_LOGIN>';
```

Role changes apply immediately. Clear the failed task in the Airflow UI or trigger the DAG again.

---

## How to read these errors (the order matters)

| Error | Meaning | Look at |
|---|---|---|
| Host not resolved (20009 with a machine name) | Wrong host | Connection Host |
| Connection refused (111) | Nothing listening on the port | SQL Server TCP/IP config, firewall |
| Login failed (18456) | Wrong user or password, or mixed mode off | SQL login, authentication mode |
| Permission denied (229) | Connected and logged in, missing rights | Database roles |

Each new error means the previous layer is solved.

---

## Notes

- `default_args` in a DAG (`retries`, `retry_delay`) only sets shared task settings. It is not related to connection errors, but with `retries: 1` a failing task waits for the retry delay before showing as failed. Set `retries` to `0` while debugging.
- Keep passwords out of git: enter them in the Airflow UI or the ignored `.env`, never in `.env.example` or DAG files.
