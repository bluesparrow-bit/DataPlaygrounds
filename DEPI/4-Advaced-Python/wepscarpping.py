import time
import pandas as pd
from selenium import webdriver
from selenium.webdriver.common.by import By
from selenium.webdriver.common.keys import Keys
from selenium.webdriver.common.action_chains import ActionChains
from selenium.webdriver.support.ui import WebDriverWait, Select
from selenium.webdriver.support import expected_conditions as EC
from IPython.display import Image


driver = webdriver.Firefox()

wait = WebDriverWait(driver, 10)

driver.set_window_size(1050, 1440)

# One book
RATING_MAP = {"One": 1, "Two": 2, "Three": 3, "Four": 4, "Five": 5}

driver.get("https://books.toscrape.com/")
book = driver.find_element(By.CSS_SELECTOR, "article.product_pod")

# the visible text is cut with "...", the full title is in the title attribute
title = book.find_element(By.CSS_SELECTOR, "h3 a").get_attribute("title")
price = book.find_element(By.CSS_SELECTOR, "p.price_color").text
rating_word = book.find_element(By.CSS_SELECTOR, "p.star-rating").get_attribute("class").split()[-1]
availability = book.find_element(By.CSS_SELECTOR, "p.availability").text.strip()

print("Title:       ", title)
print("Price:       ", price)
print("Rating:      ", RATING_MAP[rating_word])
print("Availability:", availability)

# One page
def scrape_page(driver):
    """Return a list of dicts (title, price, rating, availability, link), one per book on the open page."""
    books = []
    for book in driver.find_elements(By.CSS_SELECTOR, "article.product_pod"):
        link_el = book.find_element(By.CSS_SELECTOR, "h3 a")
        rating_word = book.find_element(By.CSS_SELECTOR, "p.star-rating").get_attribute("class").split()[-1]
        books.append({
            "title": link_el.get_attribute("title"),
            "price": book.find_element(By.CSS_SELECTOR, "p.price_color").text,
            "rating": RATING_MAP[rating_word],
            "availability": book.find_element(By.CSS_SELECTOR, "p.availability").text.strip(),
            "link": link_el.get_attribute("href"),
        })
    return books

driver.get("https://books.toscrape.com/")
page_books = scrape_page(driver)
print(len(page_books), "books on the first page")
print(page_books[0])

# Many pages 
all_books = []
driver.get("https://books.toscrape.com/")

for page in range(1, 6):
    all_books.extend(scrape_page(driver))
    print(f"Page {page} scraped, total so far: {len(all_books)}")

    if page < 5:
        driver.find_element(By.CSS_SELECTOR, "li.next a").click()
        time.sleep(1)  # wait 1 second between pages

driver.quit()

# Clean
df = pd.DataFrame(all_books)

# "£51.77" -> 51.77
df["price"] = df["price"].str.replace(r"[^\d.]", "", regex=True).astype(float)

df["in_stock"] = df["availability"].str.contains("In stock", case=False)

# cheap: < 20, medium: 20 to < 40, expensive: >= 40
df["price_level"] = pd.cut(
    df["price"],
    bins=[float("-inf"), 20, 40, float("inf")],
    labels=["cheap", "medium", "expensive"],
    right=False,
)

df.head()

# Save
df.to_csv("C:\\Users\\Moham\\Documents\\VS\\PythonWorkSpace\\DEPI\\4-Advaced-Python\\data\\books.csv", index=False, encoding="utf-8")
print("Saved", len(df), "rows to books.csv")