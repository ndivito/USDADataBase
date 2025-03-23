import requests
import time

API_KEY = api_key = open("API_KEY.txt").read().strip()  # Your USDA API key
BASE_URL = "https://api.nal.usda.gov/fdc/v1/foods/list"
FDC_DETAIL_PAGE_BASE = "https://fdc.nal.usda.gov/fdc-app.html#/food-details"

def fetch_foods_list(page_number: int, page_size: int = 200) -> list:
    """
    Fetch a page of foods from USDA using the /foods/list endpoint.
    Returns a list of dicts (each representing a food item).
    An empty list means no more items.
    """
    # The USDA /foods/list endpoint requires a POST with JSON body specifying pageSize, pageNumber, etc.
    params = {
        "api_key": API_KEY
    }
    # Body for the POST request
    body = {
        "pageNumber": page_number,
        "pageSize": page_size,
        "sortBy": "fdcId",
        "sortOrder": "asc"
    }

    response = requests.post(BASE_URL, params=params, json=body)
    response.raise_for_status()
    return response.json()  # List of food items (or empty if no more pages)

def main():
    # Adjust these if needed:
    page_size = 200         # Max allowed by USDA for /foods/list is typically 200
    page_number = 1
    max_pages = None        # Set to None to keep going until empty; or set a number to limit

    # Optionally, write to file instead of just printing:
    # output_file = open("usda_urls.txt", "w", encoding="utf-8")

    while True:
        print(f"Fetching page {page_number}...")
        foods = fetch_foods_list(page_number, page_size)
        if not foods:
            print("No more foods returned. Stopping.")
            break

        for item in foods:
            fdc_id = item.get("fdcId")
            # Construct the detail page URL
            detail_url = f"{FDC_DETAIL_PAGE_BASE}/{fdc_id}"
            print(detail_url)
            # output_file.write(detail_url + "\n")

        page_number += 1

        # Optional: if you have a max page limit, stop once reached
        if max_pages and page_number > max_pages:
            break

        # (Recommended) Sleep briefly to avoid hitting rate limits
        time.sleep(0.5)

    # output_file.close()
    print("Done listing USDA product URLs.")

if __name__ == "__main__":
    main()
