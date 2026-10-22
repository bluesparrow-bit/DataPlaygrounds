# import Python Libraries
import pymssql
from pymongo import MongoClient


# MongoDB connection settings
# On your PC use "localhost", inside Airflow (Docker) use "host.docker.internal"
MONGO_HOST = "host.docker.internal"
MONGO_PORT = 27017
MONGO_USER = "admin"
MONGO_PASSWORD = "Mongo123!"
MONGO_DB = "HotelNormalizedSchema"
MONGO_COLLECTION = "guests"

# SQL Server connection settings
# On your PC use "localhost", inside Airflow (Docker) use "host.docker.internal"
DB_HOST = "host.docker.internal"
DB_PORT = 14330
DB_USER = "sa"
DB_PASSWORD = "YourStrongPassword123!"
TARGET_DB = "HotelBookingsDWH"


# ---- Step 1: Read the guests from MongoDB --------------------------------
mongo_client = MongoClient(host=MONGO_HOST, port=MONGO_PORT, username=MONGO_USER, password=MONGO_PASSWORD)
collection = mongo_client[MONGO_DB][MONGO_COLLECTION]

guests = []
for doc in collection.find({}).sort("guest_id", 1):
    guests.append((doc["guest_id"], doc["guest_name"], doc["country"], doc["loyalty_level"]))

mongo_client.close()

print(f"{len(guests)} guests have been read from MongoDB {MONGO_DB}.{MONGO_COLLECTION}.")


# ---- Step 2: Insert the guests into the data warehouse -------------------
target_conn = pymssql.connect(server=DB_HOST, port=DB_PORT, user=DB_USER,password=DB_PASSWORD, database=TARGET_DB)
target_cursor = target_conn.cursor()

# Insert all the guests
for guest in guests:
    target_cursor.execute(
        "INSERT INTO dbo.dim_guest (guest_id, guest_name, country, loyalty_level) "
        "VALUES (%s, %s, %s, %s)",
        guest
    )

target_conn.commit()
target_cursor.close()
target_conn.close()

print(f"{len(guests)} guests have been inserted into {TARGET_DB}.dbo.dim_guest.")
