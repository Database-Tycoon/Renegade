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
**Recommend using a version of python >= 3.8.1 and < 3.13 for compatibility with `dlt[filesystem]==1.5.0`.**  

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
- By default, the following command will run the pipeline in incremental mode.
```
python nyc_open_data_pipeline.py
```
- If you want to run the pipeline in historical mode, to backfill historical data (up to the time of running the command), you can use the following command:
```
python nyc_open_data_pipeline.py --backfill
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

### Evidence
[Evidence](https://evidence.dev/) is a lightweight BI tool used to make visualizations.

To view the markdown files in this repo, you need to have run sqlmesh and generated the models/data in your `nycdata.db` file. Once this is done, you can:
1. `npm install`  
2. `npm run sources` (in the `evidence/` subdirectory)  
3. `npm run dev`  
This should spin up the server at `localhost:3000` and show Evidence's `index.md` page.  

Refer to the [official documentation](https://docs.evidence.dev/) for more information.