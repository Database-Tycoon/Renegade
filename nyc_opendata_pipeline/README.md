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
3. Configure Secrets:
   - Create a `secrets.toml` file in the `.dlt` directory.
   - Add the following configuration to the `secrets.toml` file:
     ```toml
     # put your secret values and credentials here. do not share this file and do not push it to github

     [sources.rest_api]
     nyc_opendata_api_key_id = # please set me up!


4. Run the pipeline. If you want to run it for testing purposes, modify the `maximum_offset` to limit the data for pagination (line 24 in `rest_api_pipeline.py`). 
```
python rest_api_pipeline.py
```
5. Check pipeline info:
```
dlt pipeline rest_api_nyc_311_service_requests info
``` 
or 
```
dlt pipeline rest_api_nyc_311_service_requests show
``` 
to use streamlit