import requests
from requests.auth import HTTPBasicAuth
import time

# Start timing
start_time = time.time()

basic = HTTPBasicAuth(
    "3in5zb1gedi0j893qyr6bxsh2", "33fs0ejzgw9yp2h6be9u82h7s6u7aa0edp0yll8e6xb9zf9tl2"
)

# Define the base URL and endpoint
base_url = "https://data.cityofnewyork.us/resource/"
endpoint = "erm2-nwe9"

params = {
    "$limit": 1000,
    "$offset": 0,
}
# Construct the full URL
url = f"{base_url}{endpoint}"

# Make the GET request
response = requests.get(url, auth=basic)

# Check if the request was successful
if response.status_code == 200:
    # Parse the JSON response
    data = response.json()
    # Print the data
    print(data)
else:
    print(f"Failed to retrieve data: {response.status_code}")

# End timing
end_time = time.time()
print(f"Time took to process: {round(end_time - start_time)} seconds")
