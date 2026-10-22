# import Python Libraries
import pymssql


# SQL Server connection settings
# On your PC SQL Server is "localhost", inside Airflow (Docker) it is "host.docker.internal"
DB_HOST = "host.docker.internal"
DB_PORT = 14330
DB_USER = "sa"
DB_PASSWORD = "YourStrongPassword123!"

SOURCE_DB = "HotelNormalizedSchema"
TARGET_DB = "HotelBookingsDWH"


# ---- Step 1: Read the hotels from the source database --------------------
source_conn = pymssql.connect(server=DB_HOST, port=DB_PORT, user=DB_USER,password=DB_PASSWORD, database=SOURCE_DB)
source_cursor = source_conn.cursor()

source_cursor.execute("""
    SELECT h.hotel_id,
           h.hotel_name,
           h.city,
           h.region
    FROM dbo.hotels AS h
    ORDER BY h.hotel_id;
""")
hotels = source_cursor.fetchall()

source_cursor.close()
source_conn.close()

print(f"{len(hotels)} hotels have been read from {SOURCE_DB}.")


# ---- Step 2: Insert the hotels into the data warehouse -------------------
target_conn = pymssql.connect(server=DB_HOST, port=DB_PORT, user=DB_USER,password=DB_PASSWORD, database=TARGET_DB)
target_cursor = target_conn.cursor()

# Insert all the hotels
for hotel in hotels:
    target_cursor.execute(
        "INSERT INTO dbo.dim_hotel (hotel_id, hotel_name, city, region) "
        "VALUES (%s, %s, %s, %s)",
        hotel
    )

target_conn.commit()
target_cursor.close()
target_conn.close()

print(f"{len(hotels)} hotels have been inserted into {TARGET_DB}.dbo.dim_hotel.")
