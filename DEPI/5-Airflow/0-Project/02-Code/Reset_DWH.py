# import Python Libraries
import pymssql


# SQL Server connection settings
# On your PC SQL Server is "localhost", inside Airflow (Docker) it is "host.docker.internal"
DB_HOST = "host.docker.internal"
DB_PORT = 14330
DB_USER = "sa"
DB_PASSWORD = "YourStrongPassword123!"
TARGET_DB = "HotelBookingsDWH"

# Tables to empty, in this order:
# the fact table first, because it points to the dimensions (foreign keys)
TABLES = ["fact_booking", "dim_date", "dim_guest", "dim_hotel", "dim_room"]


conn = pymssql.connect(server=DB_HOST, port=DB_PORT, user=DB_USER, password=DB_PASSWORD, database=TARGET_DB)
cursor = conn.cursor()

for table in TABLES:
    # Empty the table (TRUNCATE is not allowed because of the foreign keys, so we use DELETE)
    cursor.execute(f"DELETE FROM dbo.{table};")

    # Reset the identity so the keys start again from 1.
    # Only if the table has an identity column that was already used
    # (on a never-used table, RESEED 0 would make the first key 0 instead of 1)
    cursor.execute(f"""
        IF (SELECT last_value FROM sys.identity_columns
            WHERE object_id = OBJECT_ID('dbo.{table}')) IS NOT NULL
            DBCC CHECKIDENT ('dbo.{table}', RESEED, 0);
    """)

    print(f"dbo.{table} has been emptied and its identity reset.")

conn.commit()
cursor.close()
conn.close()

print(f"{TARGET_DB} is ready for a fresh load.")
