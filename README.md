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
```
cp .dlt/secrets.example .dlt/secrets.toml
```
- Make sure the file is located in `Renegade/dlt/.dlt/secrets.toml`.
- Add secrets like aws credentials, nyc open data app token, etc.
- You can change the `bucket_url` to your local directory for testing purposes. In which case, you don't need to specify the aws credentials.
- You also don't need to specify the nyn api token for development. You only need it to limit the API call limit.


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