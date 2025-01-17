# Instructions

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

     [sources.rest_api]
     # you don't need these API credentials for dev, but there is a possiblity your IP gets restricted with too many GET requests
     nyc_open_data_api_key_id = "YOUR_API_KEY"
     nyc_open_data_api_key_secret = "YOUR_API_SECRET"

     [destination.filesystem]
     bucket_url = "s3://proj-renegade" 

     [destination.filesystem.credentials]
     aws_access_key_id = "YOUR_AWS_KEY_ID"
     aws_secret_access_key = "YOUR_AWS_SECRET_ACCESS_KEY"


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