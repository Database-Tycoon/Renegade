# Instructions

1. Create a new virtual environement: 
```
python -m venv .venv
source .venv/bin/activate
```
2. Install dependencies: 
```
pip install -r requirements.txt
```
1. Run the pipeline. If you want to run it for testing purpose, modify the `maximum_offset` to limit the data for pagination (line 22 in `rest_api_pipeline.py`). 
```
python rest_api_pipeline.py
```
1. Check pipeline info:
```
dlt pipeline rest_api_nyc_311_service_requests info
``` 
or 
```
dlt pipeline rest_api_nyc_311_service_requests show
``` 
to use streamlit