# Renegade

## Instructions

1. Create a new virtual environment: 
```
python -m venv .venv
source .venv/bin/activate
```
2. Install dependencies: 
```
pip install -r requirements.txt
```
3. Navigate in to the `dlt` folder:
```
cd dlt
```
4. Configure Secrets:
   - Create a `secrets.toml` file in the `.dlt` directory.
   - Add the following configuration to the `secrets.toml` file:
     ```toml
     # put your secret values and credentials here. do not share this file and do not push it to github

     [destination.filesystem]
     bucket_url = "s3://proj-renegade" 
     # for local testing, you can point it to your local directory
     # bucket_url = "/Users/Yuki/Desktop/Orem Data/Database Tycoon/Renegade/dlt/data"

     [destination.filesystem.credentials]
     aws_access_key_id = "YOUR_AWS_KEY_ID"
     aws_secret_access_key = "YOUR_AWS_SECRET_ACCESS_KEY"

     [sources.rest_api]  # optional, passing this will increase the API call limit
     # if you decide to use the app token, please uncomment the lines 9, 11~13, and 25 in the nyc_open_data_pipeline.py file
     nyc_open_data_app_token = "YOUR_APP_TOKEN"  # optional
     ```


5. Run the pipeline. If you want to run it for testing purposes, modify the `maximum_offset` to limit the data for pagination. 
```
python nyc_open_data_pipeline.py
```
6. Check pipeline info:
```
dlt pipeline nyc_open_data_pipeline info
``` 
or 
```
dlt pipeline nyc_open_data_pipeline show
``` 
to use streamlit