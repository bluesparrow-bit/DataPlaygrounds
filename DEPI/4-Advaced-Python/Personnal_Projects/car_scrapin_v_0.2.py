import pandas as pd
pd.set_option("display.max_rows", 10)

import time
from selenium import webdriver
from selenium.webdriver.common.by import By
from selenium.webdriver.support import expected_conditions as EC
from selenium.webdriver.support.ui import WebDriverWait

print("Starting a Browser...")
driver = webdriver.Chrome() # (options=chrome_options)
wait = WebDriverWait(driver, 10)
driver.get("https://webscraper.io/test-sites/pagination")

# Fields on the listing pages: Title, Tagline, Year, Country of origin, Mileage, Price, Rarity Rating, Status, Product URL, Thumbnail URL
def page_scarper(driver) -> list:
    cars = []
    car_cards = driver.find_elements(By.CSS_SELECTOR, "div.card.sitemap-card.test-sites-card")

    for car in car_cards:
        title = car.find_element(By.CLASS_NAME, "card-title").text.strip()
        tagline = car.find_element(By.CLASS_NAME, "description").text.strip()
        body_style = driver.find_element(By.CSS_SELECTOR,"a.nav-link.subcategory-link.active").text.strip()
        product_url = car.find_element(By.CSS_SELECTOR, "a.card-head-url").get_attribute("href")
        thumpnail_url = car.find_element(By.CSS_SELECTOR, "img.img-fluid.card-img-top.image.img-responsive").get_attribute("src")
        card_text = car.find_elements(By.CLASS_NAME, "card-text")

        year = card_text[0].text.strip().replace("Year: ",  "")
        country_of_origin = card_text[1].text.strip().replace("Country of origin: ",  "")    
        mileage = card_text[2].text.replace("Mileage:",  "").replace(" ","").replace("km", "")
        
        price = car.find_element(By.CLASS_NAME, "price").text.replace("USD","").replace(" ","")
        rarity_rating = car.find_element(By.CLASS_NAME, "col-6").get_attribute("data-rating")
        
        status_and_count = car.find_element(By.CLASS_NAME, "badge").text.replace(" ","")
        if ":" in status_and_count:
            status =  status_and_count.split(sep=":")[0]
            count = status_and_count.split(sep=":")[1]
        else:
            status = status_and_count
            count = 0
        cars.append({
            "title": title,
            "tagline": tagline,
            "body_style": body_style,
            "product_url": product_url,
            "thumpnail_url": thumpnail_url,
            "year": year,
            "country_of_origin": country_of_origin,
            "mileage": mileage,
            "price": price,
            "rarity_rating": rarity_rating,
            "status": status,
            "count": count,
        })
    return cars

selector = ".category-link.nav-link"
count = len(driver.find_elements(By.CSS_SELECTOR, selector))
scraped_cars = []
page_number = 1

for i in range(count):
    # Re-find elements after each click, since the page may have changed.
    nav_buttons = driver.find_elements(By.CSS_SELECTOR, selector)
    category = WebDriverWait(driver, 10).until(EC.element_to_be_clickable(nav_buttons[i]))
    category.click()
    
    active_nav = driver.find_element(By.CSS_SELECTOR, ".nav-item.active")
    count_sub = active_nav.find_elements(By.CSS_SELECTOR, ".nav-link.subcategory-link")
    
    for i in range(len(count_sub)):
        active_nav = driver.find_element(By.CSS_SELECTOR, ".nav-item.active")
        sub_button = active_nav.find_elements(By.CSS_SELECTOR, ".nav-link.subcategory-link")
        
        subcategory = WebDriverWait(driver, 15).until(EC.element_to_be_clickable(sub_button[i]))
        subcategory.click()
        time.sleep(1) 

        scraped_cars.extend(page_scarper(driver))
        print(f"-> Page {page_number} Scraped, Total cars so far: {len(scraped_cars)}")
        page_number += 1
        
        while True:
            try:
                next_link = driver.find_element(By.CSS_SELECTOR, "a.page-link.next")
                next_link.click()
            except:    
                break
            time.sleep(1)
            scraped_cars.extend(page_scarper(driver))
            print(f"-> Page {page_number} Scraped, Total cars so far: {len(scraped_cars)}")
            page_number += 1
            
driver.quit()

print("Scraping Complete!")

spacer ="\n-----------------------------------\n"
print("Listing Scraped Data Into a Table...")
cars = pd.DataFrame(scraped_cars)

print("Data Listed!")

print(spacer, "Table's Data Types Before Cleaning:", spacer , cars.dtypes, sep="")

print(spacer, "Fixing Data Types For Columns...\n", sep="")
to_numeric = ["year", "mileage", "rarity_rating", "count"]
for col in to_numeric:
    cars[col] = pd.to_numeric(cars[col], errors="coerce")


print(spacer, "Fixing Data Type For The Price Column...", spacer, sep="")
cars["price"] = cars["price"].astype(float).copy()

print(spacer, "Table's Data Types After Cleaning:", spacer , cars.dtypes, sep="")
print(cars.dtypes)

print(f"{spacer}Fix Done!")

print(spacer, "Saving Data to CSV...")
cars.to_csv("data/cars.csv", index=False, encoding="utf-8")
print(f"{spacer}Saved {len(cars)} rows to CSV!")
