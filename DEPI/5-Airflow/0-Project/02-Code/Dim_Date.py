# import Python Libraries
import pandas as pd
from pathlib import Path
from selenium import webdriver
from selenium.webdriver.common.by import By

# Project folder = one level above 02-Code (works on Windows and in Airflow/Docker)
BASE_DIR = Path(__file__).resolve().parent.parent

# WebSite Url
HTML_FILE = BASE_DIR / "01-Source" / "dim_date.html"

# Open Edge without a window (Airflow runs in Docker, which has no screen)
options = webdriver.EdgeOptions()
options.add_argument("--headless")
options.add_argument("--no-sandbox")
options.add_argument("--disable-dev-shm-usage")

# Open Edge and load the page
driver = webdriver.Edge(options=options)
driver.get(HTML_FILE.as_uri())
print("The website has been successfully opened.")

# Read the column names
headers = []
header_cells = driver.find_elements(By.CSS_SELECTOR, "table#dim_date thead th")
for th in header_cells:
    headers.append(th.text)

print("The headers has been successfully extracted from the website.")

# Read every row from the table
data = []
rows = driver.find_elements(By.CSS_SELECTOR, "table#dim_date tbody tr")
for row in rows:
    cells = row.find_elements(By.TAG_NAME, "td")
    values = []
    for cell in cells:
        values.append(cell.text)

    data.append(values)
    
print("The data has been successfully extracted from the website.")

# Close the browser
driver.quit()

print("The browser has been successfully closed.")

# CSV Output File
CSV_FILE = BASE_DIR / "03-Output" / "dim_date.csv"

# Convert the data to a DataFrame and save it as CSV
df = pd.DataFrame(data, columns=headers)
df.to_csv(CSV_FILE, index=False, encoding="utf-8")

print(f"The data has been successfully written to {CSV_FILE}.")